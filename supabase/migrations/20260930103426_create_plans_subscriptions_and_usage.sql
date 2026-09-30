create extension if not exists pg_cron;

create table public.plans (
    id text primary key,
    name text not null,
    daily_note_limit integer check (daily_note_limit > 0),
    note_cooldown_seconds integer not null check (note_cooldown_seconds >= 0)
);

insert into public.plans (id, name, daily_note_limit, note_cooldown_seconds)
values ('free', 'Free', 10, 30);

create table public.subscriptions (
    user_id uuid primary key references public.profiles (id) on delete cascade,
    plan_id text not null references public.plans (id),
    started_at timestamptz not null default now(),
    expires_at timestamptz
);

create index subscriptions_plan_id_idx on public.subscriptions (plan_id);

create table public.usage_counters (
    user_id uuid primary key references public.profiles (id) on delete cascade,
    notes_sent_today integer not null default 0 check (notes_sent_today >= 0)
);

alter table public.plans enable row level security;
alter table public.subscriptions enable row level security;
alter table public.usage_counters enable row level security;

revoke all on table public.plans from anon, authenticated;
revoke all on table public.subscriptions from anon, authenticated;
revoke all on table public.usage_counters from anon, authenticated;

insert into public.subscriptions (user_id, plan_id)
select id, 'free' from public.profiles;

insert into public.usage_counters (user_id)
select id from public.profiles;

create function private.create_subscription_and_usage()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.subscriptions (user_id, plan_id)
    values (new.id, 'free');

    insert into public.usage_counters (user_id)
    values (new.id);

    return new;
end;
$$;

revoke all on function private.create_subscription_and_usage() from public, anon, authenticated;

create trigger create_subscription_and_usage
after insert on public.profiles
for each row execute function private.create_subscription_and_usage();

create function private.enforce_note_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    plan public.plans;
    notes_sent integer;
begin
    if tg_op = 'INSERT' and exists (
        select 1
        from public.notes
        where couple_id = new.couple_id and author_id = new.author_id
    ) then
        return new;
    end if;

    select plans.* into plan
    from public.subscriptions
    join public.plans on plans.id = subscriptions.plan_id
    where subscriptions.user_id = new.author_id
        and (subscriptions.expires_at is null or subscriptions.expires_at > now());

    if not found then
        select * into strict plan
        from public.plans
        where id = 'free';
    end if;

    if tg_op = 'UPDATE'
        and old.updated_at > now() - make_interval(secs => plan.note_cooldown_seconds) then
        raise exception 'note_too_soon' using errcode = 'P0001';
    end if;

    insert into public.usage_counters (user_id)
    values (new.author_id)
    on conflict (user_id) do nothing;

    select notes_sent_today into notes_sent
    from public.usage_counters
    where user_id = new.author_id
    for update;

    if plan.daily_note_limit is not null and notes_sent >= plan.daily_note_limit then
        raise exception 'daily_note_limit_reached' using errcode = 'P0001';
    end if;

    update public.usage_counters
    set notes_sent_today = notes_sent_today + 1
    where user_id = new.author_id;

    return new;
end;
$$;

revoke all on function private.enforce_note_limit() from public, anon, authenticated;

create trigger enforce_note_limit
before insert or update of text on public.notes
for each row execute function private.enforce_note_limit();

select cron.schedule(
    'reset-usage-counters',
    '0 0 * * *',
    $$update public.usage_counters set notes_sent_today = 0 where notes_sent_today > 0$$
);

create function private.current_plan(member_id uuid)
returns public.plans
language sql
stable
security definer
set search_path = ''
as $$
    select coalesce(
        (
            select plans
            from public.subscriptions
            join public.plans on plans.id = subscriptions.plan_id
            where subscriptions.user_id = member_id
                and (subscriptions.expires_at is null or subscriptions.expires_at > now())
        ),
        (select plans from public.plans where id = 'free')
    );
$$;

revoke all on function private.current_plan(uuid) from public, anon, authenticated;

create or replace function private.enforce_note_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    plan public.plans := private.current_plan(new.author_id);
    notes_sent integer;
begin
    if tg_op = 'INSERT' and exists (
        select 1
        from public.notes
        where couple_id = new.couple_id and author_id = new.author_id
    ) then
        return new;
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

create function private.note_quota()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
    caller_id uuid := auth.uid();
    plan public.plans;
    notes_sent integer;
    last_note_at timestamptz;
    utc_now timestamp := now() at time zone 'utc';
begin
    if caller_id is null then
        raise exception 'not_authenticated' using errcode = '42501';
    end if;

    plan := private.current_plan(caller_id);

    select coalesce(max(notes_sent_today), 0) into notes_sent
    from public.usage_counters
    where user_id = caller_id;

    select max(updated_at) into last_note_at
    from public.notes
    where author_id = caller_id;

    return jsonb_build_object(
        'daily_limit', plan.daily_note_limit,
        'notes_left', greatest(plan.daily_note_limit - notes_sent, 0),
        'cooldown_seconds', plan.note_cooldown_seconds,
        'cooldown_seconds_left', coalesce(
            greatest(
                ceil(plan.note_cooldown_seconds - extract(epoch from now() - last_note_at)),
                0
            )::integer,
            0
        ),
        'reset_seconds_left', ceil(
            extract(epoch from date_trunc('day', utc_now) + interval '1 day' - utc_now)
        )::integer
    );
end;
$$;

revoke all on function private.note_quota() from public, anon, authenticated;
grant execute on function private.note_quota() to authenticated;

create function public.note_quota()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
    select private.note_quota();
$$;

revoke all on function public.note_quota() from public, anon, authenticated;
grant execute on function public.note_quota() to authenticated;

create function private.partner_name()
returns text
language sql
stable
security definer
set search_path = ''
as $$
    select profiles.name
    from public.couple_members
    join public.profiles on profiles.id = couple_members.user_id
    where couple_members.couple_id = (select private.current_couple_id())
        and couple_members.user_id <> (select auth.uid());
$$;

revoke all on function private.partner_name() from public, anon, authenticated;
grant execute on function private.partner_name() to authenticated;

create function public.partner_name()
returns text
language sql
stable
security invoker
set search_path = ''
as $$
    select private.partner_name();
$$;

revoke all on function public.partner_name() from public, anon, authenticated;
grant execute on function public.partner_name() to authenticated;

create function public.send_note(text text)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
    couple_id uuid := (select private.current_couple_id());
begin
    if couple_id is null then
        raise exception 'not_paired' using errcode = 'P0001';
    end if;

    insert into public.notes (couple_id, author_id, text)
    values (couple_id, (select auth.uid()), send_note.text)
    on conflict on constraint notes_pkey do update
    set text = excluded.text;

    return private.note_quota();
end;
$$;

revoke all on function public.send_note(text) from public, anon, authenticated;
grant execute on function public.send_note(text) to authenticated;

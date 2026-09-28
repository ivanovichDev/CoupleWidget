create table public.couples (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz not null default now()
);

create table public.couple_members (
    couple_id uuid not null references public.couples (id) on delete cascade,
    user_id uuid not null unique references public.profiles (id) on delete cascade,
    primary key (couple_id, user_id)
);

create table public.notes (
    couple_id uuid not null,
    author_id uuid not null,
    text text not null check (char_length(text) between 1 and 500),
    updated_at timestamptz not null default now(),
    primary key (couple_id, author_id),
    foreign key (couple_id, author_id) references public.couple_members (couple_id, user_id) on delete cascade
);

alter table public.couples enable row level security;
alter table public.couple_members enable row level security;
alter table public.notes enable row level security;

revoke all on table public.couples from anon, authenticated;
revoke all on table public.couple_members from anon, authenticated;
revoke all on table public.notes from anon, authenticated;

grant select on table public.couples to authenticated;
grant select on table public.couple_members to authenticated;
grant select on table public.notes to authenticated;
grant insert (couple_id, author_id, text) on table public.notes to authenticated;
grant update (couple_id, author_id, text) on table public.notes to authenticated;

create function private.current_couple_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
    select couple_id from public.couple_members where user_id = (select auth.uid());
$$;

revoke all on function private.current_couple_id() from public, anon, authenticated;
grant usage on schema private to authenticated;
grant execute on function private.current_couple_id() to authenticated;

create policy "Members can read their couple"
on public.couples for select
to authenticated
using (id = (select private.current_couple_id()));

create policy "Members can read the members of their couple"
on public.couple_members for select
to authenticated
using (couple_id = (select private.current_couple_id()));

create policy "Members can read the notes of their couple"
on public.notes for select
to authenticated
using (couple_id = (select private.current_couple_id()));

create policy "Authors can create their note"
on public.notes for insert
to authenticated
with check (author_id = (select auth.uid()) and couple_id = (select private.current_couple_id()));

create policy "Authors can update their note"
on public.notes for update
to authenticated
using (author_id = (select auth.uid()))
with check (author_id = (select auth.uid()) and couple_id = (select private.current_couple_id()));

create function private.touch_note()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
    new.updated_at := now();
    return new;
end;
$$;

create trigger touch_note
before update on public.notes
for each row execute function private.touch_note();

create function private.delete_couple_without_member()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    delete from public.couples where id = old.couple_id;
    return old;
end;
$$;

create trigger delete_couple_without_member
after delete on public.couple_members
for each row execute function private.delete_couple_without_member();

create function private.join_couple(invite_code text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
    caller_id uuid := auth.uid();
    partner_id uuid;
    existing_couple_id uuid;
    new_couple_id uuid;
begin
    if caller_id is null then
        raise exception 'not_authenticated' using errcode = '42501';
    end if;

    select id into partner_id
    from public.profiles
    where pairing_code = upper(btrim(invite_code));

    if partner_id is null then
        raise exception 'invite_code_not_found' using errcode = 'P0001';
    end if;

    if partner_id = caller_id then
        raise exception 'own_invite_code' using errcode = 'P0001';
    end if;

    perform 1
    from public.profiles
    where id in (caller_id, partner_id)
    order by id
    for update;

    select couple_id into existing_couple_id
    from public.couple_members
    where user_id = caller_id;

    if existing_couple_id is not null then
        return existing_couple_id;
    end if;

    if exists (select 1 from public.couple_members where user_id = partner_id) then
        raise exception 'partner_already_paired' using errcode = 'P0001';
    end if;

    insert into public.couples default values
    returning id into new_couple_id;

    insert into public.couple_members (couple_id, user_id)
    values (new_couple_id, caller_id), (new_couple_id, partner_id);

    return new_couple_id;
end;
$$;

revoke all on function private.touch_note() from public, anon, authenticated;
revoke all on function private.delete_couple_without_member() from public, anon, authenticated;
revoke all on function private.join_couple(text) from public, anon, authenticated;
grant execute on function private.join_couple(text) to authenticated;

create function public.join_couple(invite_code text)
returns uuid
language sql
security invoker
set search_path = ''
as $$
    select private.join_couple(invite_code);
$$;

revoke all on function public.join_couple(text) from public, anon, authenticated;
grant execute on function public.join_couple(text) to authenticated;

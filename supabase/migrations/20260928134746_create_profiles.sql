create schema if not exists private;

revoke all on schema private from public, anon, authenticated;

create table public.profiles (
    id uuid primary key references auth.users (id) on delete cascade,
    name text check (char_length(name) between 1 and 100),
    birth_date date,
    pairing_code text not null unique check (pairing_code ~ '^[ABCDEFGHJKMNPQRSTUVWXYZ23456789]{6}$'),
    created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

revoke all on table public.profiles from anon, authenticated;
grant select on table public.profiles to authenticated;
grant update (name, birth_date) on table public.profiles to authenticated;

create policy "Users can read their own profile"
on public.profiles for select
to authenticated
using ((select auth.uid()) = id);

create policy "Users can update their own profile"
on public.profiles for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

create function private.validate_profile()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
    if new.birth_date is not null
        and (new.birth_date > current_date - interval '13 years'
            or new.birth_date < current_date - interval '150 years') then
        raise exception 'birth_date is out of the allowed range'
            using errcode = 'check_violation';
    end if;
    return new;
end;
$$;

create trigger validate_profile
before insert or update on public.profiles
for each row execute function private.validate_profile();

create function private.new_pairing_code()
returns text
language plpgsql
volatile
set search_path = ''
as $$
declare
    alphabet constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    code text := '';
    random_byte int;
begin
    while char_length(code) < 6 loop
        random_byte := get_byte(extensions.gen_random_bytes(1), 0);
        if random_byte < 248 then
            code := code || substr(alphabet, random_byte % 31 + 1, 1);
        end if;
    end loop;
    return code;
end;
$$;

create function private.create_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    attempt int := 0;
begin
    loop
        begin
            insert into public.profiles (id, pairing_code)
            values (new.id, private.new_pairing_code());
            return new;
        exception when unique_violation then
            attempt := attempt + 1;
            if attempt >= 10 then
                raise;
            end if;
        end;
    end loop;
end;
$$;

revoke all on function private.validate_profile() from public, anon, authenticated;
revoke all on function private.new_pairing_code() from public, anon, authenticated;
revoke all on function private.create_profile() from public, anon, authenticated;

create trigger create_profile
after insert on auth.users
for each row execute function private.create_profile();

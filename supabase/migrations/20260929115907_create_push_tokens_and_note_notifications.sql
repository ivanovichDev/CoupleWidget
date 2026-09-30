create extension if not exists pg_net with schema extensions;

create table public.push_tokens (
    token text primary key check (token ~ '^[0-9a-f]{64,200}$'),
    user_id uuid not null references public.profiles (id) on delete cascade,
    environment text not null check (environment in ('sandbox', 'production')),
    updated_at timestamptz not null default now()
);

create index push_tokens_user_id_idx on public.push_tokens (user_id);

alter table public.push_tokens enable row level security;

revoke all on table public.push_tokens from anon, authenticated;

create function private.register_push_token(token text, environment text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
    caller_id uuid := auth.uid();
begin
    if caller_id is null then
        raise exception 'not_authenticated' using errcode = '42501';
    end if;

    insert into public.push_tokens (token, user_id, environment)
    values (register_push_token.token, caller_id, register_push_token.environment)
    on conflict on constraint push_tokens_pkey do update
    set user_id = excluded.user_id,
        environment = excluded.environment,
        updated_at = now();
end;
$$;

revoke all on function private.register_push_token(text, text) from public, anon, authenticated;
grant execute on function private.register_push_token(text, text) to authenticated;

create function public.register_push_token(token text, environment text)
returns void
language sql
security invoker
set search_path = ''
as $$
    select private.register_push_token(token, environment);
$$;

revoke all on function public.register_push_token(text, text) from public, anon, authenticated;
grant execute on function public.register_push_token(text, text) to authenticated;

create function private.send_note_notification()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    project_url text;
    push_secret text;
    author_name text;
    recipients jsonb;
begin
    select decrypted_secret into project_url
    from vault.decrypted_secrets
    where name = 'project_url';

    select decrypted_secret into push_secret
    from vault.decrypted_secrets
    where name = 'note_push_secret';

    if project_url is null or push_secret is null then
        return null;
    end if;

    select jsonb_agg(jsonb_build_object('token', push_tokens.token, 'environment', push_tokens.environment))
    into recipients
    from public.couple_members
    join public.push_tokens on push_tokens.user_id = couple_members.user_id
    where couple_members.couple_id = new.couple_id
        and couple_members.user_id <> new.author_id;

    if recipients is null then
        return null;
    end if;

    select name into author_name
    from public.profiles
    where id = new.author_id;

    perform net.http_post(
        url := project_url || '/functions/v1/send-note-notification',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'X-Note-Push-Secret', push_secret
        ),
        body := jsonb_build_object(
            'recipients', recipients,
            'note', jsonb_build_object(
                'author_name', coalesce(author_name, ''),
                'text', new.text,
                'updated_at', extract(epoch from new.updated_at)
            )
        )
    );

    return null;
end;
$$;

revoke all on function private.send_note_notification() from public, anon, authenticated;

create trigger send_note_notification
after insert or update of text on public.notes
for each row execute function private.send_note_notification();

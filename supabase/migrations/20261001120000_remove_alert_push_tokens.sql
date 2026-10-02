delete from public.push_tokens
where kind <> 'widget' or widget_secret is null;

alter table public.push_tokens
drop constraint push_tokens_widget_secret_kind,
drop column kind,
alter column widget_secret set not null;

drop function public.register_push_token(text, text, text, text);
drop function private.register_push_token(text, text, text, text);

create function private.register_push_token(widget_token text, widget_secret text, environment text)
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

    delete from public.push_tokens
    where push_tokens.widget_secret = register_push_token.widget_secret
        and push_tokens.token <> register_push_token.widget_token;

    insert into public.push_tokens (token, user_id, environment, widget_secret)
    values (
        register_push_token.widget_token,
        caller_id,
        register_push_token.environment,
        register_push_token.widget_secret
    )
    on conflict on constraint push_tokens_pkey do update
    set user_id = excluded.user_id,
        environment = excluded.environment,
        widget_secret = excluded.widget_secret,
        updated_at = now();
end;
$$;

revoke all on function private.register_push_token(text, text, text) from public, anon, authenticated;
grant execute on function private.register_push_token(text, text, text) to authenticated;

create function public.register_push_token(widget_token text, widget_secret text, environment text)
returns void
language sql
security invoker
set search_path = ''
as $$
    select private.register_push_token(widget_token, widget_secret, environment);
$$;

revoke all on function public.register_push_token(text, text, text) from public, anon, authenticated;
grant execute on function public.register_push_token(text, text, text) to authenticated;

create or replace function private.latest_partner_note(widget_secret text)
returns table (author_name text, text text, updated_at double precision)
language sql
stable
security definer
set search_path = ''
as $$
    select
        coalesce(profiles.name, ''),
        notes.text,
        extract(epoch from notes.updated_at)::double precision
    from public.push_tokens
    join public.couple_members on couple_members.user_id = push_tokens.user_id
    join public.notes
        on notes.couple_id = couple_members.couple_id
        and notes.author_id <> couple_members.user_id
    join public.profiles on profiles.id = notes.author_id
    where push_tokens.widget_secret = latest_partner_note.widget_secret
    limit 1;
$$;

create or replace function private.send_note_notification()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    project_url text;
    push_secret text;
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

    select jsonb_agg(jsonb_build_object(
        'token', push_tokens.token,
        'environment', push_tokens.environment
    ))
    into recipients
    from public.couple_members
    join public.push_tokens on push_tokens.user_id = couple_members.user_id
    where couple_members.couple_id = new.couple_id
        and couple_members.user_id <> new.author_id;

    if recipients is null then
        return null;
    end if;

    perform net.http_post(
        url := project_url || '/functions/v1/send-note-notification',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'X-Note-Push-Secret', push_secret
        ),
        body := jsonb_build_object('recipients', recipients)
    );

    return null;
end;
$$;

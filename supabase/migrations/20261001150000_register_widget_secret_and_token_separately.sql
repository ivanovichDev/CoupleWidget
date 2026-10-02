alter table public.push_tokens
drop constraint push_tokens_pkey,
drop constraint push_tokens_widget_secret_key,
add primary key (widget_secret),
alter column token drop not null,
add constraint push_tokens_token_key unique (token);

drop function public.register_push_token(text, text, text);
drop function private.register_push_token(text, text, text);

create function private.register_widget_secret(widget_secret text, environment text, widget_token text default null)
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

    if register_widget_secret.widget_token is not null then
        update public.push_tokens
        set token = null
        where push_tokens.token = register_widget_secret.widget_token
            and push_tokens.widget_secret <> register_widget_secret.widget_secret;
    end if;

    insert into public.push_tokens (widget_secret, user_id, environment, token)
    values (
        register_widget_secret.widget_secret,
        caller_id,
        register_widget_secret.environment,
        register_widget_secret.widget_token
    )
    on conflict on constraint push_tokens_pkey do update
    set user_id = excluded.user_id,
        environment = excluded.environment,
        token = coalesce(excluded.token, push_tokens.token),
        updated_at = now();
end;
$$;

revoke all on function private.register_widget_secret(text, text, text) from public, anon, authenticated;
grant execute on function private.register_widget_secret(text, text, text) to authenticated;

create function public.register_widget_secret(widget_secret text, environment text, widget_token text default null)
returns void
language sql
security invoker
set search_path = ''
as $$
    select private.register_widget_secret(widget_secret, environment, widget_token);
$$;

revoke all on function public.register_widget_secret(text, text, text) from public, anon, authenticated;
grant execute on function public.register_widget_secret(text, text, text) to authenticated;

create function private.set_widget_push_token(widget_secret text, widget_token text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    update public.push_tokens
    set token = null
    where push_tokens.token = set_widget_push_token.widget_token
        and push_tokens.widget_secret <> set_widget_push_token.widget_secret;

    update public.push_tokens
    set token = set_widget_push_token.widget_token,
        updated_at = now()
    where push_tokens.widget_secret = set_widget_push_token.widget_secret;
end;
$$;

revoke all on function private.set_widget_push_token(text, text) from public, anon, authenticated;
grant execute on function private.set_widget_push_token(text, text) to anon;

create function public.set_widget_push_token(widget_secret text, widget_token text)
returns void
language sql
security invoker
set search_path = ''
as $$
    select private.set_widget_push_token(widget_secret, widget_token);
$$;

revoke all on function public.set_widget_push_token(text, text) from public, anon, authenticated;
grant execute on function public.set_widget_push_token(text, text) to anon;

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
        and couple_members.user_id <> new.author_id
        and push_tokens.token is not null;

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

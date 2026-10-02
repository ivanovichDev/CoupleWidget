alter table public.push_tokens
drop constraint push_tokens_user_id_key;

create index push_tokens_user_id_idx on public.push_tokens (user_id);

create or replace function private.register_widget_secret(widget_secret text, environment text, widget_token text default null)
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

create function private.clear_push_token(widget_token text, push_secret text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
    expected_secret text;
begin
    select decrypted_secret into expected_secret
    from vault.decrypted_secrets
    where name = 'note_push_secret';

    if expected_secret is null or clear_push_token.push_secret is distinct from expected_secret then
        raise exception 'forbidden' using errcode = '42501';
    end if;

    update public.push_tokens
    set token = null,
        updated_at = now()
    where push_tokens.token = clear_push_token.widget_token;
end;
$$;

revoke all on function private.clear_push_token(text, text) from public, anon, authenticated;
grant execute on function private.clear_push_token(text, text) to anon;

create function public.clear_push_token(widget_token text, push_secret text)
returns void
language sql
security invoker
set search_path = ''
as $$
    select private.clear_push_token(widget_token, push_secret);
$$;

revoke all on function public.clear_push_token(text, text) from public, anon, authenticated;
grant execute on function public.clear_push_token(text, text) to anon;

select cron.schedule(
    'delete-stale-widget-registrations',
    '30 0 * * *',
    $$delete from public.push_tokens where token is null and updated_at < now() - interval '30 days'$$
);

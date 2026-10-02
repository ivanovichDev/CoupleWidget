delete from public.push_tokens
where (user_id, updated_at, widget_secret) not in (
    select distinct on (user_id) user_id, updated_at, widget_secret
    from public.push_tokens
    order by user_id, updated_at desc
);

drop index public.push_tokens_user_id_idx;

alter table public.push_tokens
add constraint push_tokens_user_id_key unique (user_id);

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

    delete from public.push_tokens
    where push_tokens.user_id = caller_id
        and push_tokens.widget_secret <> register_widget_secret.widget_secret;

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

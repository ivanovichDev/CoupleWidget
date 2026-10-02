alter table public.push_tokens
add column widget_secret text unique check (widget_secret ~ '^[0-9a-f]{64}$'),
add constraint push_tokens_widget_secret_kind check (kind = 'widget' or widget_secret is null);

drop function public.register_push_token(text, text, text);
drop function private.register_push_token(text, text, text);

create function private.register_push_token(
    token text,
    kind text,
    environment text,
    widget_secret text default null
)
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

    if register_push_token.widget_secret is not null then
        delete from public.push_tokens
        where push_tokens.widget_secret = register_push_token.widget_secret
            and push_tokens.token <> register_push_token.token;
    end if;

    insert into public.push_tokens (token, user_id, kind, environment, widget_secret)
    values (
        register_push_token.token,
        caller_id,
        register_push_token.kind,
        register_push_token.environment,
        register_push_token.widget_secret
    )
    on conflict on constraint push_tokens_pkey do update
    set user_id = excluded.user_id,
        kind = excluded.kind,
        environment = excluded.environment,
        widget_secret = excluded.widget_secret,
        updated_at = now();
end;
$$;

revoke all on function private.register_push_token(text, text, text, text) from public, anon, authenticated;
grant execute on function private.register_push_token(text, text, text, text) to authenticated;

create function public.register_push_token(
    token text,
    kind text,
    environment text,
    widget_secret text default null
)
returns void
language sql
security invoker
set search_path = ''
as $$
    select private.register_push_token(token, kind, environment, widget_secret);
$$;

revoke all on function public.register_push_token(text, text, text, text) from public, anon, authenticated;
grant execute on function public.register_push_token(text, text, text, text) to authenticated;

create function private.latest_partner_note(widget_secret text)
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
        and push_tokens.kind = 'widget'
    limit 1;
$$;

revoke all on function private.latest_partner_note(text) from public, anon, authenticated;
grant usage on schema private to anon;
grant execute on function private.latest_partner_note(text) to anon;

create function public.latest_partner_note(widget_secret text)
returns table (author_name text, text text, updated_at double precision)
language sql
stable
security invoker
set search_path = ''
as $$
    select * from private.latest_partner_note(widget_secret);
$$;

revoke all on function public.latest_partner_note(text) from public, anon, authenticated;
grant execute on function public.latest_partner_note(text) to anon;

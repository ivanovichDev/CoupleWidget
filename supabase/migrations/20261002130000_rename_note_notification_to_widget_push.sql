drop trigger send_note_notification on public.notes;
drop function private.send_note_notification();

create function private.send_widget_push()
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
    where name = 'SEND_WIDGET_PUSH_SECRET';

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
        url := project_url || '/functions/v1/send-widget-push',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'X-Send-Widget-Push-Secret', push_secret
        ),
        body := jsonb_build_object('recipients', recipients)
    );

    return null;
end;
$$;

revoke all on function private.send_widget_push() from public, anon, authenticated;

create trigger send_widget_push
after insert or update of text on public.notes
for each row execute function private.send_widget_push();

create or replace function private.clear_push_token(widget_token text, push_secret text)
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
    where name = 'SEND_WIDGET_PUSH_SECRET';

    if expected_secret is null or clear_push_token.push_secret is distinct from expected_secret then
        raise exception 'forbidden' using errcode = '42501';
    end if;

    update public.push_tokens
    set token = null,
        updated_at = now()
    where push_tokens.token = clear_push_token.widget_token;
end;
$$;

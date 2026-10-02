# Widget Pushes

A new note reaches the partner's Home Screen widget through a WidgetKit push. The push reloads the widget, which then fetches the note from the backend. The application shows no notifications. The sequence is described in [Widget Updates](widget-updates.md).

## Delivery

1. The widget receives its WidgetKit push token in `NoteWidgetPushHandler` and sends it with the widget secret to the `set_widget_push_token` database function. The application registers the widget secret and the token that it reads from `WidgetCenter.currentPushInfo` with `register_widget_secret`.
2. Writing a note fires the `send_widget_push` trigger on `public.notes`. The trigger collects the push tokens of the partner and calls the `send-widget-push` Edge Function through `pg_net`, so the write never waits for the network.
3. The trigger skips widget secrets that have no push token yet. The Edge Function signs a provider token with the APNs key and sends a WidgetKit push to every widget token. A token that APNs reports as dead is emptied through `clear_push_token`.
4. The push reloads the widget, and the widget fetches the latest note with `latest_partner_note`.

## Delivery Limits

The system budgets WidgetKit pushes, performs them opportunistically, and drops the ones that exceed the budget, so a push is a hint and not a guarantee. The widget stays correct without it: it reloads and fetches the note when the application becomes active, and it retries a failed request after 15 minutes. The Edge Function sends one push for every note, so the limits of the plan bound the number of pushes. A plan must keep a non-zero cooldown, otherwise nothing limits the pushes that the system budgets.

## Payload

The WidgetKit push uses the `widgets` push type and the `com.ivanovich.couplewidget.push-type.widgets` topic, and carries no content:

```json
{
    "aps": {
        "content-changed": true
    }
}
```

## App Group

The application and the widget extension share the `group.com.ivanovich.couplewidget` App Group. It holds two files, both managed by `NoteCache`:

- The latest note as a JSON file with a schema version.
- The widget secret.

## Capabilities

- The widget extension has the `aps-environment` entitlement, because it receives the WidgetKit push token.
- The application has no `aps-environment` entitlement. It never registers for remote notifications, never asks for notification permission, and reads the token of the widget from `WidgetCenter.currentPushInfo`.
- Both targets have the App Group entitlement, which `NoteCache` uses.

## Push Tokens

`public.push_tokens` stores one row per widget installation with the widget secret, its owner, the widget push token, and the APNs environment. The token is empty until the widget delivers it. Debug builds register `sandbox` tokens and release builds register `production` tokens. The table has no policies and is written only by `register_widget_secret`, which assigns the secret to the signed-in user, and by `set_widget_push_token`, which sets the token of an existing secret.

## Edge Function Secrets

The `send-widget-push` function reads these variables:

- `APNS_KEY_ID` is the identifier of the APNs authentication key.
- `APNS_TEAM_ID` is the identifier of the developer team that owns the key.
- `APNS_PRIVATE_KEY_BASE64` is the `.p8` file encoded with base64 as one line.
- `APNS_TOPIC` is the bundle identifier of the application.
- `SEND_WIDGET_PUSH_SECRET` is the shared secret that the database sends in the `X-Send-Widget-Push-Secret` header.

The function also reads `SUPABASE_URL` and `SUPABASE_ANON_KEY`, which Supabase provides to every Edge Function, and calls `clear_push_token` with `SEND_WIDGET_PUSH_SECRET`. It does not verify JWTs and accepts only requests with the shared secret.

## Database Secrets

The trigger reads two Vault secrets:

- `project_url` is the base URL of the Supabase API as seen from the database.
- `SEND_WIDGET_PUSH_SECRET` is the same value as the Edge Function variable of the same name.

When a secret is missing, the trigger skips the push and the note is saved as usual.

A hosted project has no seed, so both secrets are created once by hand. `SEND_WIDGET_PUSH_SECRET` is created in Vault with `vault.create_secret`, and the Edge Function variables are set with `supabase secrets set`. A Vault secret cannot be renamed with an update of `vault.secrets`. Use `vault.update_secret` with a new name.

## Local Setup

Locally the Edge Function reads its variables from `supabase/functions/.env`, which is not committed. Create the file with the variables listed above and encode the key:

```bash
base64 -i AuthKey_KEYID.p8 | pbcopy
```

`supabase/seed.sql` creates the Vault secrets for the local stack during `supabase db reset`. The local `project_url` is `http://kong:8000`, the address of the API gateway inside the Docker network. `SEND_WIDGET_PUSH_SECRET` in `supabase/functions/.env` must match the Vault secret of the same name in the seed file.

Restart the stack after changing the variables:

```bash
supabase stop && supabase start
```

Pushes are tested on a physical device. A physical device reaches the local stack through the network address of the Mac, so `SUPABASE_URL` in `Staging.xcconfig` points to that address while testing on a device. Enable WidgetKit Developer Mode in Settings, Developer, to remove the reload budget of the widget while testing.

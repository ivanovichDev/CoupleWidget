# Notifications

A new note reaches the partner as a notification, and a WidgetKit push that follows it reloads the Home Screen widget. The widget never talks to the backend. It shows the latest note stored in the App Group container.

## Delivery

1. The widget receives its WidgetKit push token in `NoteWidgetPushHandler` and stores it in the App Group container. The application registers for remote notifications on the home screen and stores both the device token and the widget token with the `register_push_token` database function.
2. Writing a note fires the `send_note_notification` trigger on `public.notes`. The trigger collects the push tokens of the partner and calls the `send-note-notification` Edge Function through `pg_net`, so the write never waits for the network.
3. The Edge Function signs a provider token with the APNs key and sends an alert notification to every device token. The title is the name of the author, the body is the note, and `mutable-content` is set.
4. The notification service extension receives the notification before it is shown and stores the note in `NoteCache`.
5. One second after the notifications, the Edge Function sends a WidgetKit push to every widget token.
6. The WidgetKit push reloads the widget, and the widget reads the latest note from `NoteCache`.

A reload requested from the notification service extension is scheduled by the system as a background task and can run up to 15 minutes later. The WidgetKit push is the signal that reloads the widget without that delay. The one-second delay gives the notification service extension time to store the note before the widget reads it.

## Payloads

The alert notification carries the note:

```json
{
    "aps": {
        "alert": {
            "title": "Anna",
            "body": "Miss you"
        },
        "sound": "default",
        "mutable-content": 1
    },
    "note": {
        "author_name": "Anna",
        "updated_at": 1790683609.123456
    }
}
```

The WidgetKit push uses the `widgets` push type and the `com.ivanovich.couplewidget.push-type.widgets` topic, and carries no content:

```json
{
    "aps": {
        "content-changed": true
    }
}
```

The note text is sent once, as the alert body, because APNs accepts at most 4 KB. `updated_at` is the time of the note in seconds since 1970. `NoteCache` accepts a note only when its `updated_at` is newer than the stored one, so notifications that arrive out of order never replace a newer note.

## App Group

The application, the widget extension, and the notification service extension share the `group.com.ivanovich.couplewidget` App Group. `NoteCache` keeps the latest note there as a JSON file with a schema version, and the WidgetKit push token of the widget as a text file.

## Push Tokens

`public.push_tokens` stores one row per token with its owner, its kind, and its APNs environment. The kind is `alert` for the device token of the application and `widget` for the WidgetKit push token. Debug builds register `sandbox` tokens and release builds register `production` tokens. The table has no policies and is written only by `register_push_token`, which assigns the token to the signed-in user.

## Edge Function Secrets

The `send-note-notification` function reads these variables:

- `APNS_KEY_ID` is the identifier of the APNs authentication key.
- `APNS_TEAM_ID` is the identifier of the developer team that owns the key.
- `APNS_PRIVATE_KEY_BASE64` is the `.p8` file encoded with base64 as one line.
- `APNS_TOPIC` is the bundle identifier of the application.
- `NOTE_PUSH_SECRET` is the shared secret that the database sends in the `X-Note-Push-Secret` header.

The function does not verify JWTs and accepts only requests with the shared secret.

## Database Secrets

The trigger reads two Vault secrets:

- `project_url` is the base URL of the Supabase API as seen from the database.
- `note_push_secret` is the same value as `NOTE_PUSH_SECRET`.

When a secret is missing, the trigger skips the notification and the note is saved as usual.

## Local Setup

Locally the Edge Function reads its variables from `supabase/functions/.env`, which is not committed. Create the file with the variables listed above and encode the key:

```bash
base64 -i AuthKey_KEYID.p8 | pbcopy
```

`supabase/seed.sql` creates the Vault secrets for the local stack during `supabase db reset`. The local `project_url` is `http://kong:8000`, the address of the API gateway inside the Docker network. `NOTE_PUSH_SECRET` in `supabase/functions/.env` must match `note_push_secret` in the seed file.

Restart the stack after changing the variables:

```bash
supabase stop && supabase start
```

Notifications are tested on a physical device. `xcrun simctl push` does not run the notification service extension, so it cannot update the widget. A physical device reaches the local stack through the network address of the Mac, so `SUPABASE_URL` in `Staging.xcconfig` points to that address while testing on a device. Enable WidgetKit Developer Mode in Settings, Developer, to remove the reload budget of the widget while testing.

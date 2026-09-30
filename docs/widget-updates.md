# Widget Updates

The widget shows a new note within about a second of the partner writing it, even when the application is closed. Two pushes deliver it: an alert notification carries the note, and a WidgetKit push reloads the widget.

## Pipeline

```
notes row written
    │
    ▼
send_note_notification trigger ──pg_net──▶ send-note-notification Edge Function
                                               │
                     ┌─────────────────────────┴──────────────────────────┐
                     ▼                                                    ▼
       alert notification with the note                     WidgetKit push, one second later
                     │                                                    │
                     ▼                                                    ▼
      Notification Service Extension                           widget timeline reload
      writes the note to NoteCache  ─────────────────────────▶ widget reads NoteCache
```

1. A write to `public.notes` fires a trigger that calls the Edge Function asynchronously, so the write never waits for APNs.
2. The Edge Function sends an alert notification with the note to the partner's device token.
3. The Notification Service Extension receives it before it is shown and stores the note in `NoteCache` in the App Group container.
4. One second later the Edge Function sends a WidgetKit push to the partner's widget token.
5. The push reloads the widget, and the widget renders the note from `NoteCache`.

## Why Two Pushes

- A WidgetKit push carries no data, so it cannot deliver the note by itself.
- A reload requested from the Notification Service Extension is scheduled by iOS as a background task and can run up to 15 minutes later.
- The WidgetKit push reloads the widget immediately. The one-second delay lets the extension store the note first.

## Tokens

- The application registers its device token for alert notifications.
- The widget receives its WidgetKit push token in `NoteWidgetPushHandler` and stores it in the App Group. The application registers it when it opens.
- Both tokens are stored in `public.push_tokens` with the kind `alert` or `widget`.

## Consistency

`NoteCache` keeps only the newest note by `updated_at`, so pushes that arrive out of order never replace a newer note. The widget never talks to the backend.

The payloads, secrets, and local setup are described in [Notifications](notifications.md).

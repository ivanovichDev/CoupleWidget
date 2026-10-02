# Widget Updates

The widget shows a new note within about a second of the partner writing it, even when the application is closed. The application sends no notifications and never asks for notification permission. A WidgetKit push tells the widget to reload, and the widget fetches the note itself.

## Pipeline

```
notes row written
    │
    ▼
send_widget_push trigger ──pg_net──▶ send-widget-push Edge Function
                                         │
                                         ▼
                               WidgetKit push to the partner's widget
                                         │
                                         ▼
                               widget timeline reload
                                         │
                                         ▼
                 widget calls latest_partner_note with its widget secret
                                         │
                                         ▼
                 widget saves the note to NoteCache and renders it
```

1. A write to `public.notes` fires a trigger that calls the Edge Function asynchronously, so the write never waits for APNs.
2. The Edge Function sends a WidgetKit push to every widget token of the partner.
3. The push reloads the widget, and `getTimeline` runs `FetchPartnerNoteUseCase`, which calls the `latest_partner_note` database function.
4. The widget stores the note in `NoteCache` and renders it. When the request fails, the widget renders the note that `NoteCache` already holds.

## Why the Widget Fetches the Note

- A WidgetKit push carries no data, so it cannot deliver the note by itself.
- A WidgetKit push needs no notification permission, so the note reaches the widget whether or not the user allows notifications.
- A reload requested by the system without a push can run up to 15 minutes late. The push reloads the widget immediately.

## Widget Token and Widget Secret

- The application creates a random widget secret once and stores it in the App Group.
- When the user is signed in, the application registers the secret with `register_widget_secret`. The registration carries the APNs environment and the WidgetKit push token, which the application reads from `WidgetCenter.currentPushInfo`. It registers when it opens the home screen and every time it becomes active.
- The widget receives its WidgetKit push token in `NoteWidgetPushHandler` and sends it with its secret to `set_widget_push_token`.
- `public.push_tokens` stores one row per widget installation with the widget secret, the owner, the push token, and the APNs environment. The push token is empty until the widget delivers it. A user with several devices has one row for each of them.

The token is delivered through two paths so that it is never lost. The widget sends a new token itself, because that is the moment the system creates it. The application sends the current token every time it becomes active, so a token that the widget failed to deliver, or a widget added before the user signed in, reaches the server the next time the user opens the application. The token is never stored on the device.

## Dead Tokens and Stale Rows

- When APNs answers a widget push with `410` or `BadDeviceToken`, the Edge Function calls `clear_push_token`. The function empties the token of the row and keeps the row and its secret, because the widget may still be alive and deliver a new token later.
- `clear_push_token` accepts only the `SEND_WIDGET_PUSH_SECRET` of the Edge Function, and it can do nothing except empty a token.
- A `pg_cron` job deletes every row with an empty token that has not been updated for 30 days. The application updates its row every time it becomes active, so only the rows of removed installations disappear.

`set_widget_push_token` only updates a row that already exists for the secret, so an unknown secret changes nothing. The widget cannot use the session of the application, because a refresh token is valid only once and two processes refreshing the same session would invalidate it. The widget secret never expires and is not refreshed. It identifies one widget installation.

## Reading the Note

`latest_partner_note` receives the widget secret and returns the latest note written by the partner of the secret owner. A request with an unknown secret returns no rows. `latest_partner_note` and `set_widget_push_token` are the only functions that the `anon` role can call, and the tables stay closed to it.

## Recovery

A widget with a timeline that never reloads on its own stays stale when a push is lost, so the widget and the application recover on their own:

- When the request in `getTimeline` fails, the widget renders the cached note and asks the system to reload the timeline in 15 minutes. A request that succeeds, even with no note, keeps the timeline without a scheduled reload.
- The application reloads all widget timelines every time it becomes active, so opening the application always brings the widget up to date.

## Consistency

`NoteCache` keeps only the newest note by `updated_at`, so a response that arrives late never replaces a newer note.

The secrets and local setup are described in [Widget Pushes](widget-pushes.md).

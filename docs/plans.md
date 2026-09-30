# Plans and Usage

Every user has a plan that limits how often notes can be written. The limits apply to every write of a note, including a write with the same text, and are checked by the `enforce_note_limit` trigger before the note is saved.

- `public.plans` describes the plans. `daily_note_limit` is the number of notes per day, and `null` means no limit. `note_cooldown_seconds` is the minimum time between two notes of the same author. The only plan is `free` with 10 notes per day and a cooldown of 30 seconds.
- `public.subscriptions` assigns a plan to every user. A row with the `free` plan and no `expires_at` is created together with the profile. A user whose subscription has expired gets the limits of the `free` plan.
- `public.usage_counters` holds `notes_sent_today` for every user. The row is created together with the profile.
- The cooldown is measured from `updated_at` of the author's current note, so the first note of an author has no cooldown.
- A write within the cooldown fails with `note_too_soon`.
- A write after the daily limit is reached fails with `daily_note_limit_reached`.
- The `reset-usage-counters` pg_cron job sets `notes_sent_today` to zero every day at 00:00 UTC.

The tables are closed to the application and are written only by the database. A rejected write sends no notification.

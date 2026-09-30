# Database

The database keeps profiles, couples, and notes in the `public` schema. Every table has row level security, and every rule below is enforced by the database itself, so a client cannot bypass it.

## Profiles

A row in `public.profiles` is created by a trigger when Supabase Auth creates a user. The row receives a pairing code at that moment:

- The code has six characters from `ABCDEFGHJKMNPQRSTUVWXYZ23456789`, which excludes characters that are easy to confuse.
- The code is generated from cryptographically secure random bytes.
- A unique constraint guarantees that no two users share a code. The trigger generates a new code when a collision occurs.
- The code never changes.

The user completes the profile during onboarding. The name is trimmed at both ends and must not be empty. The birth date is stored as a `date` without time and must correspond to an age from 13 to 150 years. The rules are checked by `CompleteProfileUseCase` and again by the database.

A user can read their own profile and update only its name and birth date.

## Couples

A couple is a row in `public.couples` with its two users in `public.couple_members`. A unique constraint on `couple_members.user_id` keeps every user in at most one couple.

A couple is created only by the `join_couple` function, which receives the partner's pairing code:

- An unknown code fails with `invite_code_not_found`.
- The caller's own code fails with `own_invite_code`.
- A partner who is already in a couple fails with `partner_already_paired`.
- A caller who is already in a couple receives the existing couple.

The function locks both profiles before it checks them, so two users cannot pair with the same partner at the same time.

Couples keep no history. When a member row is deleted, a trigger deletes the whole couple together with the other member and the notes of the couple.

## Notes

Every member of a couple has at most one note in `public.notes`, identified by the couple and the author. A new note replaces the previous one through an upsert. The partner reads the note of the other member, and only the author can write it. The database accepts up to 500 characters and updates `updated_at` on every change.

The application writes the note with the `send_note` function, which finds the couple of the signed-in user and returns the updated quota described in [Plans and Usage](plans.md). The `partner_name` function returns the name of the other member of the couple.

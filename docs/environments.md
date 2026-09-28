# Environments

The application runs against one of two backends. Staging is a local Supabase stack on the developer's Mac. Production is the hosted Supabase project used for TestFlight and App Store releases.

## Configuration Files

Each environment has one configuration file in `Configurations/`:

- `Staging.xcconfig` points to the local Supabase stack.
- `Production.xcconfig` points to the hosted Supabase project.

Both files define `SUPABASE_URL` and `SUPABASE_KEY`. The key is the publishable key of the project. The secret key is never added to the application. The values reach the code through the `SupabaseURL` and `SupabaseKey` entries of `Info.plist`, which `AppConfiguration` reads at launch.

The environment files are not committed. `Configurations/Example.xcconfig` shows the expected settings. After cloning the repository, copy it to `Staging.xcconfig` and `Production.xcconfig` and fill in the values:

```bash
cp Configurations/Example.xcconfig Configurations/Staging.xcconfig
cp Configurations/Example.xcconfig Configurations/Production.xcconfig
```

A URL in an `.xcconfig` file is written as `https:/$()/project-ref.supabase.co`, because `//` starts a comment in this format. The Staging values are printed by `supabase status` after the local stack starts.

## Build Configurations

Every environment has a debug and a release build configuration:

- `Debug-Staging` and `Release-Staging` use `Staging.xcconfig`.
- `Debug-Production` and `Release-Production` use `Production.xcconfig`.

Debug configurations build without optimization. Release configurations build with whole-module optimization.

## Schemes

- `CoupleWidget (Staging)` runs and tests with `Debug-Staging`, and profiles and archives with `Release-Staging`.
- `CoupleWidget (Production)` runs and tests with `Debug-Production`, and profiles and archives with `Release-Production`.

## Local Supabase

The local stack is described by `supabase/config.toml` and uses ports 55320 to 55329, so it can run next to other local Supabase projects. The API is available at `http://127.0.0.1:55321` and Studio at `http://127.0.0.1:55323`.

Start the stack from the repository root:

```bash
supabase start
```

Recreate the database from the migrations in `supabase/migrations`:

```bash
supabase db reset
```

Sign in with Apple works against the local stack because the application uses the native flow. The application receives an identity token from Apple and exchanges it with Supabase Auth, which verifies the token with the public keys of Apple. No redirect URL is involved. The Apple provider in `config.toml` uses the bundle identifier as its client ID and needs no secret.

The Staging address works in the iOS Simulator. A physical device reaches the stack only through the local network address of the Mac.

## Profiles

A row in `public.profiles` is created by a trigger when Supabase Auth creates a user. The row receives a pairing code at that moment:

- The code has six characters from `ABCDEFGHJKMNPQRSTUVWXYZ23456789`, which excludes characters that are easy to confuse.
- The code is generated from cryptographically secure random bytes.
- A unique constraint guarantees that no two users share a code. The trigger generates a new code when a collision occurs.
- The code never changes.

The user completes the profile during onboarding. The name is trimmed at both ends and must not be empty. The birth date is stored as a `date` without time and must correspond to an age from 13 to 150 years. The rules are checked by `CompleteProfileUseCase` and again by the database.

A user can read their own profile and update only its name and birth date.

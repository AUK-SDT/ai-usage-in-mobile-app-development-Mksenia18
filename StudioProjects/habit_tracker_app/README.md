# Habit Garden Tracker

Habit Garden Tracker is a portfolio-ready Flutter application where each habit
is represented as a growing plant. Completing habits levels up plants, improves
garden health, and progresses weekly missions.

## Project Concept

- Purpose: help users build consistency with a visual "garden growth" metaphor.
- Real use case: daily/weekly habit tracking with progress and streak feedback.
- Scope: multi-screen Flutter app with Cubit state management and Firebase CRUD.

## Features

- Habit CRUD: create, edit, complete, and delete habits with categories.
- Gamified plant evolution: `Seed -> Sprout -> Flower -> Tree` with XP and health.
- Auto-wither system: plants lose health for missed days and streak resets.
- Animated garden cards: smooth growth/wither visual transitions.
- Dynamic missions: mission chains continue with harder generated goals.
- Reward reveal flow: post-claim modal + active reward panel.
- Habit history timeline from real completion timestamps.
- Authentication: Email/Password + Google Sign-In.
- Realtime user-scoped Firestore sync.

## Tech Stack

- Flutter (Material 3 UI)
- `flutter_bloc` (Cubit for state management)
- Firebase Core + Firebase Auth + Cloud Firestore

## Architecture

The app uses a layered structure with separated responsibilities:

- UI layer: screens and widgets.
- State layer: `AuthCubit` and `HabitCubit` with immutable states.
- Data layer: `HabitRepository`, `FirebaseHabitService`, `FirebaseAuthService`.
- Domain model: `Habit`, `AppUser`, `PlantState`, `Mission`.

Data flow:

1. `AuthGate` listens to `AuthCubit` and decides auth/app flow.
2. On sign-in, `HabitCubit` binds to current user id.
3. Repository subscribes to user-scoped Firestore stream.
4. Cubits emit loading/success/error updates.
5. UI rebuilds reactively across all screens.

## Portfolio Screenshots

Add your final screenshots here before publishing:

- `assets/portfolio/login_screen.png`
- `assets/portfolio/garden_screen.png`
- `assets/portfolio/plant_details_screen.png`
- `assets/portfolio/missions_screen.png`
- `assets/portfolio/history_screen.png`
- `assets/portfolio/statistics_screen.png`

Suggested capture set:

1. Sign-in screen with saved account suggestions.
2. Garden with mixed healthy and withering plants.
3. Plant details with active history button.
4. Weekly missions with progressive targets.
5. Reward modal after claim.
6. Statistics screen with totals.

## Folder Structure

```text
lib/
  constants/
  cubit/
  models/
  repositories/
  screens/
  services/
  widgets/
```

## Firebase Setup

1. Create a Firebase project in [Firebase Console](https://console.firebase.google.com/).
2. Enable **Authentication** providers:
   - Email/Password
   - Google
3. Enable Cloud Firestore.
4. Add Android/iOS app IDs to Firebase project.
5. Add SHA-1/SHA-256 for Android if you use Google Sign-In.
6. Configure FlutterFire for this project:
   - `dart pub global activate flutterfire_cli`
   - `flutterfire configure`
7. Ensure generated Firebase config files are present for your platforms.

Firestore collection used by the app:

- `users/{uid}/habits/{habitId}` (fields from `Habit.toMap()`).

## Run Locally

```bash
flutter pub get
flutter run
```

## Quality Checklist

- Cubits handle auth session + realtime habits stream transitions.
- Repository uses user-scoped realtime stream + explicit error mapping.
- UI includes loading, error, and empty states.
- Code is formatted and analyzed with Flutter lints.

## Verification

Run static analysis and tests:

```bash
flutter analyze
flutter test
```

Manual smoke test:

1. Sign up/sign in with Email/Password.
2. Sign in with Google.
3. Add a habit in "Plant New Habit".
4. Open habit details and complete it.
5. Edit and delete a habit.
6. Restart app and verify current user data persists in Firestore.
7. Skip a day (or adjust test data) and verify plant health withers.
8. Complete missions and verify new mission targets appear.

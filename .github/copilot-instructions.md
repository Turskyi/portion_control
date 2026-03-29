# Portion Control – Copilot Instructions

## Commands

```bash
# First-time / after dependency changes
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test --coverage --test-randomize-ordering-seed random

# Run a single test file
flutter test test/application_services/blocs/home/home_bloc_test.dart

# Format check (CI enforces this)
dart format --set-exit-if-changed .

# Lint
flutter analyze .
```

> CI requires `dart run build_runner build` before `flutter pub get` — the `env.g.dart` and `database.g.dart` generated files must exist.

---

## Architecture: Onion Layers

The app is strictly layered. Inner layers must never depend on outer ones.

```
domain/                   ← No Flutter, no external packages
  models/                 ← @immutable value objects (manual copyWith/fromMap/toMap)
  enums/
  services/
    repositories/         ← Interfaces: I{Name}Repository
    interactors/          ← Interfaces: I{Name}UseCase

application_services/     ← Depends on domain services and domain models only
  blocs/{name}/           ← home_bloc.dart + home_event.dart + home_state.dart
  interactors/            ← Concrete use case implementations

infrastructure/           ← Depends on application core (application services, domain services and domain models) only
  repositories/           ← Concrete: {Name}Repository implements I{Name}Repository
  data_sources/local/     ← LocalDataSource (SharedPreferences + Drift)
    database/             ← Drift tables, generated code

ui/                       ← Depends on application core (application services, domain services and domain models) only
  {feature}/
    {feature}_page.dart
    widgets/

di/                       ← Composition root
  dependencies.dart       ← Manual DI container (getter factories, no caching)
  app_blocs.dart          ← App-wide BLoC instances
  injector.dart           ← Async initialization entry point
```

---

## BLoC Pattern

Each BLoC lives in `application_services/blocs/{name}/` with three files linked via `part`/`part of`:

```dart
// event.dart
part of 'home_bloc.dart';

@immutable
sealed class HomeEvent { const HomeEvent(); }

final class LoadEntries extends HomeEvent { const LoadEntries(); }
final class SubmitBodyWeight extends HomeEvent {
  const SubmitBodyWeight(this.bodyWeight);
  final double bodyWeight;
}

// state.dart
part of 'home_bloc.dart';

@immutable
sealed class HomeState { /* shared fields in base class */ }

final class HomeLoading extends HomeState { ... }
final class HomeLoaded extends HomeState { ... }
```

- Always emit a loading state before async operations.
- Always emit an explicit error state for failures.
- BLoCs are provided to routes via `MultiBlocProvider` / `BlocProvider.value` in `lib/router/routes.dart`.
- Trigger initial load events at the route level (e.g., `blocs.homeBloc.add(const LoadEntries())`).

---

## Routing

Named routes using `Navigator` — **no go_router or auto_route**.

- Route names are defined in `lib/router/app_route.dart` as an enum (`AppRoute`).
- Route builders live in `lib/router/routes.dart` → `getRouteMap()`.
- Navigate with `Navigator.pushNamed(context, AppRoute.stats.path)`.

---

## Models

**No Freezed.** All domain models are written manually:

```dart
@immutable
class BodyWeight {
  const BodyWeight({required this.id, required this.weight, required this.date});
  factory BodyWeight.fromMap(Map<String, Object?> map) { ... }
  BodyWeight copyWith({int? id, double? weight, DateTime? date}) { ... }
}
```

- Use `@immutable` from `package:flutter/foundation.dart`.
- Override `toString()` only in debug mode (`if (kDebugMode)`).
- **Avoid `dynamic`** — use `Object?` instead (e.g., `Map<String, Object?>` not `Map<String, dynamic>`).

---

## Persistence

| Use case                                                              | Package                                   |
|-----------------------------------------------------------------------|-------------------------------------------|
| User prefs / settings / flags                                         | `SharedPreferences` via `LocalDataSource` |
| Structured data (food entries, body weights, portion control history) | Drift (`AppDatabase`)                     |

`LocalDataSource` is the single facade over both; repositories depend on it exclusively — never access `SharedPreferences` or `AppDatabase` directly from a BLoC or use case.

---

## Code Generation

Run `dart run build_runner build --delete-conflicting-outputs` after any change to:
- `lib/infrastructure/data_sources/local/database/database.dart` (Drift → `database.g.dart`)
- `lib/env/env.dart` + `.env` file (envied → `env.g.dart`)

**Freezed is not used.** Do not introduce it.

---

## Dependency Injection

- All dependencies are constructor-injected.
- `Dependencies` in `lib/di/dependencies.dart` acts as a factory container — every getter creates a new instance. Do not add caching/singletons there without intent.
- `AppBlocs` holds long-lived BLoC instances shared across routes.
- No service locators. Do not introduce them.

---

## Naming Conventions

| Concept                   | Pattern                                    | Example                             |
|---------------------------|--------------------------------------------|-------------------------------------|
| Repository interface      | `I{Name}Repository`                        | `IBodyWeightRepository`             |
| Repository implementation | `{Name}Repository`                         | `BodyWeightRepository`              |
| Use case interface        | `I{Name}UseCase`                           | `ICalculatePortionControlUseCase`   |
| Use case implementation   | `{Name}UseCase`                            | `CalculatePortionControlUseCase`    |
| BLoC events               | PascalCase verbs (no required suffix)      | `LoadEntries`, `SubmitBodyWeight`   |
| BLoC states               | PascalCase + loading/loaded/error variants | `HomeLoading`, `HomeLoaded`         |
| Boolean getters           | `is…` / `has…`                             | `isEmpty`, `hasWeightIncreaseProof` |
| Private members           | `_camelCase`                               | `_preferences`                      |
| Constants                 | `kCamelCase`                               | `kMaxDailyFoodLimit`                |

---

## Testing

- **BLoC tests**: use `bloc_test` package.
- Register fallback values in `setUpAll()` for mocktail.
- Shared dummy data lives in `test/dummy_constants.dart`.
- Translation test helper: `test/helpers/translate_test_helper.dart`.
- Test database helper: `test/helpers/test_database.dart`.

```bash
# Run one test file
flutter test test/application_services/blocs/home/home_bloc_test.dart

# Run one test by name
flutter test --name "emits HomeLoaded when entries load successfully"
```

---

## Localization

- Translations live in `assets/i18n/` (JSON files per language).
- Use `flutter_translate` (git fork of the package) — **not** `flutter_intl` or `gen-l10n`.
- Access strings via `translate('key')` inside widgets.
- Add new keys to all language files simultaneously.

---

## Environment Variables

- Secrets go in `.env` (not committed). Copy `.env.example` and fill in the values.
- Accessed via the generated `Env` class: `Env.resendApiKey`.
- CI injects the `.env` file from a base64-encoded GitHub secret (`ENV`).

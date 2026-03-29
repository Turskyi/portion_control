# Portion Control Flutter App - Architecture Rules

## Project Overview

Portion Control is a Flutter fitness app using Onion Architecture with:

- Domain layer (models, services, interfaces)
- Application Services layer (BLoCs, use cases)
- Infrastructure layer (repositories, data sources)
- UI layer (widgets, screens)

## Core Architecture Rules

### 1. Onion Architecture Layers

- `domain/`: interfaces, value objects, models, enums
  - `domain/services/repositories/` for repository interfaces (`I*Repository`)
  - `domain/services/interactors/` for use case interfaces (`I*UseCase`)
  - `domain/models/` for immutable domain models
  - `domain/enums/` for enums
- `application_services/`: BLoCs, concrete use cases, orchestration
  - `application_services/blocs/` for BLoCs
  - `application_services/interactors/` for concrete use case implementations
- `infrastructure/`: repositories, data sources, database code
  - `infrastructure/repositories/` for repository implementations
  - `infrastructure/data_sources/` for data access
  - `infrastructure/database/` for Drift setup
- `ui/`: screens and widgets only

### 2. Dependency Injection Pattern

- Inject all dependencies through constructors
- Use `lib/di/injector.dart` as the DI entry point
- Use `lib/di/dependencies.dart` for dependency containers
- Use `lib/di/app_blocs.dart` for shared app-wide BLoCs
- Do not introduce global service locators or mutable globals
- Perform async initialization in `injectDependencies()` before app startup

### 3. BLoC Pattern Requirements

- Each BLoC lives in `application_services/blocs/{bloc_name}/`
- Keep events immutable
- Emit loading states before expensive operations
- Emit explicit error states for failures

### 4. Repository Pattern

- Define repository interfaces in `domain/services/repositories/`
- Implement repositories in `infrastructure/repositories/`
- Repositories depend on data sources
- UI must not access data sources directly

### 5. Use Cases

- Define interfaces in `domain/services/interactors/`
- Implement concrete use cases in `application_services/interactors/`
- Keep each use case small and focused on one business rule

### 6. Persistence

- Use `shared_preferences` for simple key-value state
- Use Drift for structured persistent data
- Wrap persistence and platform access in error handling

### 7. Localization

- Keep translations in `assets/i18n/`

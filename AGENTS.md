# Agent Guidelines & Development Standards (`AGENTS.md`)

This document outlines the architectural patterns, coding conventions, and project standards for the `auth_flow_app` codebase. All automated agents and developers working on this project must strictly adhere to these rules.

---

## 1. Core Architecture & Tech Stack

- **Framework**: Flutter (Dart SDK `^3.9.2`)
- **Architecture**: Clean Architecture (omitting UseCases by design in this project)
- **State Management**: `flutter_bloc` (BLoC pattern using `Event` and `State`)
- **Dependency Injection**: `get_it` (centralized in `lib/core/di/injection_container.dart`)
- **Functional Error Handling**: `dartz` (`Either<Failure, T>` for expected failures)
- **Backend & Auth**: `supabase_flutter` with configuration loaded via `flutter_dotenv` (`config.env`)

---

## 2. Directory Structure

```text
lib/
├── core/
│   ├── di/
│   │   └── injection_container.dart      # Centralized GetIt DI configuration
│   ├── error/
│   │   ├── exceptions.dart               # Data layer exception classes (AppException)
│   │   └── failures.dart                 # Domain/Presentation layer failure classes (Failure)
│   └── network/
│       └── supabase/
│           ├── auth_client.dart          # Supabase client wrapper interface
│           └── auth_client_impl.dart     # Supabase client wrapper implementation
│
├── features/
│   └── <feature_name>/
│       ├── data/
│       │   ├── datasources/              # Remote/local data sources (interfaces & impls)
│       │   ├── models/                   # Data models extending Domain Entities (JSON/Supabase parsing)
│       │   └── repositories/             # Repository implementations (handling exceptions -> Failures)
│       ├── domain/
│       │   ├── entities/                 # Pure domain entity classes extending Equatable
│       │   └── repositories/             # Abstract repository contracts (returning Either<Failure, T>)
│       │   # NOTE: No usecases/ directory by design
│       └── presentation/
│           ├── bloc/
│           │   └── <slice>/              # BLoC, Events, and States for each feature slice
│           │       ├── <slice>_bloc.dart
│           │       ├── <slice>_event.dart
│           │       └── <slice>_state.dart
│           └── screens/                  # Flutter UI screens and views
└── main.dart                             # Application entrypoint & global providers
```

---

## 3. Architectural Rules & Layer Responsibilities

### **UseCases (Project Convention)**
- By design, this project currently omits the UseCase layer to streamline data flow and reduce boilerplate.
- Do NOT introduce UseCases or a `domain/usecases/` directory without explicit approval. Note that omitting UseCases is a project-specific architectural decision, not a universal requirement of Clean Architecture.
- BLoCs interact directly with abstract **Domain Repository** interfaces.

### **Domain Layer (`lib/features/<feature>/domain/`)**
- Core business rules, domain entities, and repository contracts belong in the Domain layer when applicable.
- `entities/`: Pure Dart models representing core business concepts. Extending `Equatable` is an established project convention for value equality.
- `repositories/`: Abstract repository interfaces defining data access contracts. Asynchronous data methods conventionally return `Future<Either<Failure, T>>`.

### **Data Layer (`lib/features/<feature>/data/`)**
- `datasources/`: Contract interfaces (`*DataSource`) and implementations (`*DataSourceImpl`). Interacts directly with core network clients (`AuthClient`, Supabase SDK, HTTP, etc.). Throws `AppException` subclasses for expected operational errors.
- `models/`: Classes extending domain entities (e.g., `UserModel extends UserEntity`). Contain factory constructors for deserialization (`fromSupabaseUser`, `fromJson`), `toJson()`, and `copyWith()`.
- `repositories/`: Concrete implementations (`*RepositoryImpl`) of domain repository interfaces. Responsible for data access execution and mapping expected data/network exceptions into `Failure` objects.
  - Catches expected `AppException`s and maps them into corresponding `Failure` objects wrapped in `Left(Failure)`.
  - Wraps successful responses in `Right(result)`.

### **Presentation Layer (`lib/features/<feature>/presentation/`)**
- BLoCs handle presentation state management, event handling, and UI orchestration, delegating data operations directly to Domain Repository interfaces.
- `bloc/<slice>/`: Contains `<slice>_bloc.dart`, `<slice>_event.dart`, and `<slice>_state.dart`.
  - BLoCs receive `Event`s, invoke methods on injected domain repositories, fold the returned `Either`, and emit corresponding `State`s (`Initial`, `Loading`, `Success`, `Error`, etc.).
  - Events and States conventionally extend `Equatable`.
- `screens/`: Flutter UI components.
  - Obtains BLoCs via `GetIt` (`sl<YourBloc>()`) inside `BlocProvider` or `MultiBlocProvider`.
  - Listens to side effects (e.g. snackbars, navigation) via `BlocListener` / `MultiBlocListener`.
  - Builds UI declaratively via `BlocBuilder`.
  - **UI Task Rule**: For UI tasks, reuse existing widgets, BLoCs, routes/navigation, and architecture. Do not modify Data or Domain layers unless necessary and approved.

---

## 4. Error Handling & Exception Flow

1. **DataSource Layer**: Operations that fail due to expected operational errors throw subclasses of `AppException` defined in `lib/core/error/exceptions.dart`:
   - `AuthException`
   - `ServerException`
   - `ValidationException`
   - `NetworkException`
   - `CacheException`

2. **Repository Implementation Layer**: Handle expected failures through `Either<Failure, T>`. Methods wrap calls in `try / catch` blocks for known operational exceptions (`AppException` subclasses), converting them to appropriate `Failure` types defined in `lib/core/error/failures.dart`:
   ```dart
   try {
     final user = await _dataSource.signIn(email: email, password: password);
     return Right(user);
   } on AuthException catch (e) {
     return Left(AuthFailure(e.message));
   } on ServerException catch (e) {
     return Left(ServerFailure(e.message));
   } on NetworkException catch (e) {
     return Left(NetworkFailure(e.message));
   } on ValidationException catch (e) {
     return Left(ValidationFailure(e.message));
   }
   ```
   *Note: Catch known operational exceptions (`AppException` subclasses) explicitly and map them to appropriate `Failure` types. Do not catch generic exceptions to disguise unexpected programming bugs (such as type mismatches or unhandled state errors) as `ServerFailure`.*

3. **BLoC Layer**: Processes `Either` responses using `fold`:
   ```dart
   final result = await repository.signInWithEmail(email: event.email, password: event.password);
   result.fold(
     (failure) => emit(EmailAuthError(message: failure.message)),
     (user) => emit(EmailAuthSuccess(user: user)),
   );
   ```

---

## 5. Dependency Injection Guidelines

All dependencies are registered in `lib/core/di/injection_container.dart`:

- **Network Clients & Data Sources**: Registered as `LazySingleton`.
  ```dart
  sl.registerLazySingleton<AuthClient>(() => AuthClientImpl(Supabase.instance.client.auth));
  sl.registerLazySingleton<EmailAuthDataSource>(() => EmailAuthDataSourceImpl(sl()));
  ```
- **Repositories**: Registered as `LazySingleton` bound to their abstract domain interface.
  ```dart
  sl.registerLazySingleton<EmailAuthRepository>(
    () => EmailAuthRepositoryImpl(emailAuthDataSource: sl()),
  );
  ```
- **BLoCs**: Registered as `Factory` to ensure new instances are provided per scope when needed.
  ```dart
  sl.registerFactory(() => EmailAuthBloc(emailAuthRepository: sl()));
  ```

---

## 6. Naming & Coding Conventions

- **File Naming**: `snake_case` (e.g., `email_auth_repository_impl.dart`, `user_entity.dart`).
- **Class Naming Suffixes**:
  - Entity: `<Name>Entity`
  - Model: `<Name>Model`
  - DataSource Interface: `<Name>DataSource`
  - DataSource Impl: `<Name>DataSourceImpl`
  - Repository Interface: `<Name>Repository`
  - Repository Impl: `<Name>RepositoryImpl`
  - Bloc: `<Name>Bloc`
  - Event: `<Name>Event` (and event implementations: `SignInWithEmailEvent`)
  - State: `<Name>State` (and state implementations: `EmailAuthLoading`, `EmailAuthError`)
  - Page/Screen: `<Name>Page` or `<Name>Screen` / `<Name>View`
- **Immutability & Conventions**:
  - Always prefer `const` constructors where possible.
  - `Equatable` and `Either` return types are established project conventions in this codebase; apply them consistently across domain entities, states, events, and repository methods without treating them as universal language requirements.
- **Parameter Passing**: Use required named parameters for methods with multiple arguments (e.g. `({required String email, required String password})`).

---

## 7. Configuration & Secrets

- Environment variables are loaded from `config.env` using `flutter_dotenv`.
- **Do NOT** hardcode Supabase URLs, keys, or credentials directly in source files.
- Access environment configuration via `dotenv.env['KEY_NAME']`.
- **Security Rule**: Never inspect, expose, print, or commit sensitive configuration files or credentials.

---

## 8. Development Commandments for AI Agents

1. **Do NOT introduce UseCases without approval**: Respect the project's design choice to omit UseCases, while recognizing it as a project convention rather than a universal Clean Architecture mandate.
2. **Preserve layer responsibilities**: BLoCs handle presentation state and UI orchestration; Repository implementations handle data access and error mapping; Domain holds core business rules when applicable.
3. **Do NOT modify Data/Domain for UI tasks**: For UI tasks, reuse existing widgets, BLoCs, navigation, and architecture. Do not alter Data or Domain layers unless necessary and approved.
4. **Handle expected failures cleanly**: Use `Either<Failure, T>` for expected failures, avoiding silent misclassification of unexpected programming defects as `ServerFailure`.
5. **Never expose secrets**: Never inspect, print, expose, or commit sensitive configuration files or credentials.
6. **Always register new dependencies in `injection_container.dart`**.

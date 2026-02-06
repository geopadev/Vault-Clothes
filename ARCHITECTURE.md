# Architecture Guidelines (MVVM)

**Status**: Strict Enforcement
**Stack**: Flutter (View) + Firebase (Backend)

This project follows a **Feature-First Layered MVVM** architecture. All code must reside within its designated layer. Deviations are considered technical debt and strictly prohibited.

## 1. High-Level Layers

```
[ View Layer ]  <--- (Observes) ---- [ ViewModel Layer ] ---- (Calls) ---> [ Manager/Service Layer ] ---- (Calls) ---> [ Data/Repository Layer ]
      |                                      |                                         |                                            |
(Passive UI)                           (State Holder)                             (Business Logic)                             (Database/API)
```

## 2. Layer Definitions & Boundaries

### 🟢 View Layer (Presentation)

- **Path**: `lib/features/*/views/`
- **Responsibility**: Rendering UI, capturing user gestures, adhering to Design System.
- **Allowed**:
  - Reading State from `ViewModel`.
  - Dispatching events to `ViewModel` (e.g., `viewModel.submitOrder()`).
  - Using Flutter Widgets.
- **❌ VIOLATIONS (Strictly Forbidden)**:
  - Calling `Firebase`, `http`, or `Database` directly.
  - Containing business logic (e.g., `if (price > 100) ...` inside a widget build method is bad; move to VM).
  - Storing app state in `StatefulWidget` (use `ViewModel` instead).

### 🟢 ViewModel Layer (Interface)

- **Path**: `lib/features/*/viewmodels/`
- **Responsibility**: Binding View to Logic. Transforming data for the UI. Managing loading/error states.
- **Allowed**:
  - Importing `Services` / `Managers`.
  - Exposing Streams / Notifiers for the View.
- **❌ VIOLATIONS (Strictly Forbidden)**:
  - Importing `material.dart` or `cupertino.dart` (UI Classes).
  - Passing `BuildContext` into a ViewModel (Memory Leak Risk).
  - Directly accessing Firestore/instances (must go through Manager/Service).

### 🟢 Manager / Service Layer (Business Logic)

- **Path**: `lib/features/*/services/`
- **Responsibility**: The "Brain". Complex logic, calculations, orchestration of multiple data sources.
- **Allowed**:
  - Calling `Repositories` / `DatabaseConnector`.
  - Manipulating Feature Models.
- **❌ VIOLATIONS (Strictly Forbidden)**:
  - Knowing about the UI (View or ViewModel).
  - Handling user navigation.

### 🟢 Data Access Layer (Repository)

- **Path**: `lib/core/services/` (Global) or `lib/features/*/services/`
- **Responsibility**: CRUD operations. Abstracting the data source (Firebase).
- **Allowed**:
  - Direct `FirebaseFirestore` / `FirebaseAuth` calls.
  - Parsing raw JSON into Models.
- **❌ VIOLATIONS (Strictly Forbidden)**:
  - Containing business rules (e.g., "User can't buy if balance is low" belongs in Manager, not Repository).

## 3. Communication Rules

| Initiation    | Target        | Legal?   | Reason                            |
| :------------ | :------------ | :------- | :-------------------------------- |
| **View**      | **ViewModel** | ✅ YES   | User Intent / Event               |
| **View**      | **Manager**   | ❌ NO    | Spying on Logic                   |
| **ViewModel** | **Manager**   | ✅ YES   | Delegate Logic                    |
| **ViewModel** | **Repo**      | ⚠️ AVOID | Use Manager (unless trivial)      |
| **Manager**   | **Repo**      | ✅ YES   | Fetch/Save Data                   |
| **Repo**      | **Manager**   | ❌ NO    | Circular Dependency               |
| **Manager**   | **ViewModel** | ❌ NO    | Logic shouldn't know presentation |

## 4. Flutter + Firebase Specifics

- **Firebase Models**: All Firestore documents must be converted to strong Dart Models (`.fromJson`) in the Repository layer before reaching the ViewModel.
- **Streams**: `StreamBuilder` in the View should consume streams exposed by the `ViewModel`, not direct Firestore streams.

## 5. Testing Requirements

- **View**: Widget Tests (Mock the ViewModel).
- **ViewModel**: Unit Tests (Mock the Manager).
- **Manager**: Unit Tests (Mock the Repo).
- **Repo**: Integration Tests (Emulators).

# Contributing to Vault-Clothes

## Development Workflow

### 1. Branching Strategy

- **Main**: Production-ready code.
- **Develop**: Integration branch.
- **Feature Branches**: `feat/feature-name`.
- **Bugfix Branches**: `fix/bug-name`.
- **Rule**: Keep history linear. Rebase feature branches on top of `develop` before merging.

### 2. Architecture (MVVM)

All contributions must follow the strict Layered MVVM architecture:

- **View**: `/lib/ui/` - Contains Screens and Widgets.
- **ViewModel**: `/lib/viewmodels/` - State management and View-Logic binding.
- **Managers**: `/lib/managers/` - Business logic (e.g., `CartManager`, `TrustInfoManager`).
- **Data/Repository**: `/lib/services/` or `/lib/repositories/` - (e.g., `DatabaseConnector`).

**Prohibited**:

- Making DB calls directly from the UI.
- Placing business logic inside `setState` in a generic StatefulWidget.

### 3. Testing Requirements

- **Mandatory**: Every Pull Request MUST include tests for the new code.
- **Coverage**: Target high coverage for Managers and Validations.
- **Command**: Run `flutter test` before pushing.

### 4. Code Style

- Follow standard Dart/Flutter linting rules defined in `analysis_options.yaml`.
- Use `dart format .` before committing.

## Setup

1.  Clone repo.
2.  `flutter pub get`
3.  Ensure Firebase config is present (ask Lead if missing).

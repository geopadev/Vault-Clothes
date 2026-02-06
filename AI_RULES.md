# AI Rules & Behavioral Guidelines

This file defines the strict operating procedures for any AI assistant working on the **Vault-Clothes** repository.

## 0. The Golden Rule: Authority of Documentation

- **Supreme Authority**: `REQUIREMENTS.md` and `ARCHITECTURE.md` are the absolute sources of truth.
- **Conflict Resolution**:
  - If a User Prompt conflicts with these files -> **Warn the user** (unless explicitly told to ignore).
  - If `AI_RULES.md` conflicts with them -> Obey `REQUIREMENTS.md` / `ARCHITECTURE.md`.
  - If ambiguity arises between them -> **STOP AND ASK**. Do not guess.

## 1. Architectural Enforcement (MVVM)

- **Layered Architecture**: You must strictly adhere to the following separation of concerns:
  - **Presentation (View)**: Flutter Widgets. _Passive_. No business logic. Updates purely based on ViewModel state.
  - **Interface (ViewModel)**: Handles user input from View, calls Managers, updates State.
  - **Business Logic (Managers)**: `UserAccountManager`, `TrustInfoManager`, `ListingManagementManager`, `ViewListingManager`, `CartManager`, `OrderManager`, `WishlistManager`, `ChatManager`, `NotificationManager`.
  - **Data Access (Repository/Connector)**: `DatabaseConnector`. **Single Point of Truth** for all DB interactions.
- **Validation**: Before generating code, verify which layer the file belongs to. NEVER mix business logic into UI widgets.

## 2. Testing Constraints

- **Zero-Feature Debt**: Do not implement a feature without generating the corresponding test file.
- **Test Types**:
  - **Unit Tests**: For Managers and Utility logic.
  - **Widget Tests**: For specific UI components.
  - **Integration Tests**: For critical user flows (e.g., Login -> Search -> Cart).
- **Verification**: Always run `flutter test` after code generation to ensure no regressions.

## 3. Git & Version Control

- **NO AUTO-COMMITS**: You are strictly forbidden from running `git commit` automatically. Formulate the commit message and ask the user to commit, or present the command for verification.
- **Clean History**: Suggest rebasing or squashing if a PR contains messy checkpoints.
- **Commit Messages**: Follow standard conventional commits (e.g., `feat: add wishlist manager`, `fix: search latency`).

## 4. Requirement Compliance (Team4C)

- **Accessibility**: All UI components must comply with WCAG 2.1 AA (Semantics, Contrast, labeling).
- **Constraints**: Ensure search logic is optimized for performance (<2s response).
- **Privacy**: Do not log PII. Ensure strict separation of user data access controls.

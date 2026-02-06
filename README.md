# Vault-Clothes

A specialized second-hand clothing marketplace app focused on trust, usability, and secure transactions.

## 🚀 Features

- **Smart Filtering**: Filter by size, brand, condition, fit, material, and more.
- **Seller Trust**: Transparent seller profiles with ratings, reviews, and history.
- **Secure Transactions**: Integrated Order & Cart management.
- **Wishlist & Notifications**: Price drop alerts and availability tracking.
- **Cross-Platform**: Available on Mobile (iOS/Android) and Web.

## 🛠 Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Architecture**: MVVM (Model-View-ViewModel) with Manager Pattern

## 📦 Architecture Overview

The project follows a strict layered architecture:

- **User Client**: UI/Presentation Layer.
- **Interface**: ViewModel Layer.
- **Managers**: Business Logic (e.g., `TrustInfoManager`, `ListingManagementManager`).
- **Database Connector**: Centralized Data Access Layer.

## 🔧 Setup & Installation

1.  **Prerequisites**:
    - Flutter SDK
    - Firebase CLI

2.  **Installation**:

    ```bash
    git clone https://github.com/geopadev/Vault-Clothes.git
    cd Vault-Clothes
    flutter pub get
    ```

3.  **Run**:
    ```bash
    flutter run
    ```

## 🤝 Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, strict MVVM architectural standards, and the process for submitting pull requests.

## 🤖 AI Guidelines

See [AI_RULES.md](AI_RULES.md) for rules regarding AI-assisted code generation.

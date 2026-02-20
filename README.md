# Send Money Application

A Flutter application for sending money built with clean architecture and BLoC state management.

**Supported Platforms**: Android & iOS

---

## How to Run

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

3. **Login with demo credentials**
   - Username: `demo`
   - Password: `password`

---

## How to Run Unit Tests

```bash
flutter test
```

All 27 unit tests should pass ✅

---

## Features

- 🔐 User authentication
- 💰 Wallet balance management (show/hide balance)
- 💸 Send money with amount validation
- 📋 Transaction history with status tracking
- ⚡ Pull-to-refresh on all screens
- 📱 Modern, clean UI

---

## Technical Stack

- **Architecture**: Clean Architecture (Domain/Data/Presentation layers)
- **State Management**: BLoC pattern with flutter_bloc
- **Immutable Models**: Freezed + json_serializable
- **Dependency Injection**: GetIt
- **Local Storage**: SharedPreferences
- **Testing**: bloc_test + mocktail (27 unit tests)

---

## Troubleshooting

**Build errors?**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter clean && flutter pub get
```

**Code analysis:**
```bash
flutter analyze
```

---

## 🔐 Demo Credentials

- **Username**: `demo`
- **Password**: `password`

## Project Structure

```
lib/
├── core/                         # Core utilities
├── features/
│   ├── auth/                     # Authentication feature
│   │   ├── data/                 # Data layer (models, datasources, repositories)
│   │   ├── domain/               # Domain layer (entities, usecases)
│   │   └── presentation/         # UI layer (bloc, pages, widgets)
│   │
│   └── transaction/              # Transaction feature
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── injection_container.dart      # Dependency injection
└── main.dart                     # App entry point
```

---

**Project Status**: ✅ Complete | **Tests**: 27/27 Passing | **Analysis**: No Issues

# GigLedger

All-in-one business manager for freelancers - invoicing, expenses, clients, and financial insights.

## Quick Start

### Prerequisites

- Flutter SDK 3.0+
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

### Setup

1. **Clone and install dependencies**
   ```bash
   git clone https://github.com/kamal-haider/GigLedger.git
   cd GigLedger
   flutter pub get
   ```

2. **Configure Firebase** (if `lib/firebase_options.dart` doesn't exist)
   ```bash
   firebase login
   flutterfire configure --project=gigledger-app
   ```

3. **Enable Firebase Services** in [Firebase Console](https://console.firebase.google.com/project/gigledger-app):
   - Authentication (Google, Apple, Email/Password)
   - Cloud Firestore
   - Storage

4. **Run the app**
   ```bash
   flutter run
   ```

## Documentation

Comprehensive documentation is available in the `docs/` folder:

| Document | Description |
|----------|-------------|
| [Vision & Positioning](docs/01_vision_and_positioning.md) | Product identity and differentiation |
| [MVP PRD](docs/02_mvp_prd.md) | MVP scope and acceptance criteria |
| [User Personas](docs/03_user_personas_and_jobs.md) | Target users and jobs-to-be-done |
| [Information Architecture](docs/04_information_architecture_and_screens.md) | Screen map and navigation |
| [Data Model](docs/05_data_model_and_schema.md) | Database structure and caching |
| [Integration Spec](docs/06_integration_spec.md) | External API integration |
| [App Architecture](docs/07_app_architecture.md) | Clean Architecture patterns |
| [Monetization](docs/08_monetization_and_pricing.md) | Freemium model |

## Project Structure

```
lib/
├── app/           # App shell, routing, theming
├── core/          # Shared utilities, errors, constants
├── features/      # Feature modules (Clean Architecture)
│   ├── auth/
│   ├── clients/
│   ├── dashboard/
│   ├── expenses/
│   ├── invoices/
│   ├── onboarding/
│   ├── reports/
│   └── settings/
└── main.dart
```

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Architecture**: Clean Architecture + Feature-based modules

## Contributing

See [CLAUDE.md](CLAUDE.md) for development guidelines and the GitHub project board for available issues.

## License

Proprietary - All rights reserved.

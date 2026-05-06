# GiliranKu Mobile

GiliranKu Mobile is the patient-facing mobile application for the RSUD Porsea Hospital Queue and Information System. It provides patients with an easy way to view hospital information, doctors' schedules, and manage their routine check-up queues and reminders.

## Features
- **Authentication**: Secure login using NIK and Password.
- **Hospital Information**: View real-time operational hours, doctors' schedules, and available polyclinics.
- **Queue Management**: Register for general or BPJS queues and monitor queue statuses.
- **Notifications**: Automated reminders for routine follow-up check-ups (Kontrol Rutin).

## Architecture
The application follows a Clean Architecture approach:
- `lib/core/`: Contains shared resources, including API constants, models, datasources, services, UI components (widgets), and theme definitions.
- `lib/feature/`: Contains domain-specific modules such as `auth`, `home`, `patient`, and `notifikasi`.

## Getting Started

### Prerequisites
- Flutter SDK (>=3.11.4)
- Dart SDK

### Installation
1. Navigate to the `giliranku_mobile` directory:
   ```bash
   cd giliranku_mobile
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Configuration
Update the `lib/core/constants/apiConstants.dart` file to configure your local or production backend URLs.

## Dependencies
- `provider`: State management
- `http`: API communication
- `flutter_local_notifications` & `timezone`: Local push notifications
- `shared_preferences`: Local persistent storage
- `iconsax`: UI icons

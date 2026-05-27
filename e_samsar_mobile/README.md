# E-Samsar Mobile

Flutter mobile client for the E-Samsar Spring Boot backend.

## Backend URL

Default API URL:

```dart
http://10.0.2.2:9090
```

Use this for Android emulator. For a real phone on the same Wi-Fi network, change `ApiConfig.baseUrl` in:

```text
lib/core/api_client.dart
```

Example:

```dart
static const String baseUrl = 'http://192.168.1.10:9090';
```

## Run

If this folder was not created with `flutter create`, run:

```powershell
cd e_samsar_mobile
flutter create .
flutter pub get
flutter run
```

## Test Users

Seeded users:

```text
driver1@gmail.com -> driver20@gmail.com
password: driver1234567
```

```text
shipper1@gmail.com -> shipper5@gmail.com
password: shipper1234567
```

The app UI is in French and maps roles as:

- `DRIVER` -> Chauffeur
- `SHIPPER` -> Expéditeur

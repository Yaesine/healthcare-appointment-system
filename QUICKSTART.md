# Quick Start Guide

## Prerequisites

- Java 17+
- Maven 3.6+
- Flutter SDK (latest stable)

## Step 1: Start the Backend

```bash
cd backend
mvn spring-boot:run
```

The API will start on `http://localhost:8080`

## Step 2: Configure Flutter App API URL

Edit `mobile_app/lib/services/api_service.dart` and set the correct base URL:

- **Android Emulator**: `http://10.0.2.2:8080/api` (default)
- **iOS Simulator**: `http://localhost:8080/api`
- **Physical Device**: `http://<your-computer-ip>:8080/api`

## Step 3: Run the Flutter App

```bash
cd mobile_app
flutter pub get
flutter run
```

## Test Credentials

**Note:** You need to register first or create a test user:

**Option 1: Register in the app**
- Open app and tap "Register"
- Create your account

**Option 2: Create test user via API:**
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"patient1","password":"password123","email":"patient1@example.com"}'
```

Then login with:
- Username: `patient1`
- Password: `password123`

## Troubleshooting

### Backend won't start
- Check if port 8080 is available
- Ensure Java 17+ is installed: `java -version`
- Check Maven installation: `mvn -version`

### Flutter can't connect to API
- Verify backend is running on port 8080
- Check API URL in `api_service.dart`
- For physical devices, ensure phone and computer are on same network
- Check firewall settings

### Build errors
- Run `flutter clean` and `flutter pub get`
- Ensure all dependencies are installed: `mvn clean install` (backend)


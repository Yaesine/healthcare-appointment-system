# Testing Guide

This guide will help you test both the backend API and the Flutter mobile application.

## Prerequisites Check

Before testing, ensure you have:
- ✅ Java 17+ installed (`java -version`)
- ✅ Maven installed (`mvn -version`)
- ✅ Flutter SDK installed (`flutter --version`)
- ✅ An Android emulator running OR iOS simulator OR physical device connected

## Part 1: Testing the Backend API

### Step 1: Start the Backend Server

```bash
cd backend
mvn spring-boot:run
```

Wait for the message: `Started AppointmentApplication in X.XXX seconds`

The API will be available at: `http://localhost:8080`

### Step 2: Test Authentication Endpoints

#### Test Registration (using curl or Postman)

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123",
    "email": "testuser@example.com",
    "firstName": "Test",
    "lastName": "User"
  }'
```

**Expected Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "testuser",
  "userId": 1
}
```

#### Test Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "patient1",
    "password": "password123"
  }'
```

**Expected Response:** JWT token with user details

**Or use pre-seeded user:**
- Username: `patient1`
- Password: `password123`

### Step 3: Test Appointment Endpoints

First, get a token from login, then use it for appointment endpoints:

```bash
# Save token from login response
TOKEN="your-jwt-token-here"

# Get all appointments
curl -X GET http://localhost:8080/api/appointments \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"

# Create an appointment
curl -X POST http://localhost:8080/api/appointments \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "doctorName": "Dr. Smith",
    "appointmentDateTime": "2024-01-15T10:00:00",
    "reason": "Annual checkup"
  }'
```

### Step 4: Test Security

Try accessing protected endpoints without token:
```bash
curl -X GET http://localhost:8080/api/appointments
```

**Expected:** 401 Unauthorized

## Part 2: Testing the Flutter Mobile App

### Step 1: Configure API URL

The app is already configured for Android emulator (`10.0.2.2:8080`). 

**For iOS Simulator:**
Edit `mobile_app/lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:8080/api'; // iOS simulator
```

**For Physical Device:**
1. Find your computer's IP address:
   - Mac/Linux: `ifconfig | grep "inet " | grep -v 127.0.0.1`
   - Windows: `ipconfig`
2. Update `api_service.dart`:
```dart
static const String baseUrl = 'http://192.168.1.XXX:8080/api'; // Your IP
```

### Step 2: Start the Flutter App

```bash
cd mobile_app
flutter pub get
flutter run
```

### Step 3: Test User Flows

#### Test Case 1: Registration
1. App opens to login screen
2. Tap "Don't have an account? Register"
3. Fill in:
   - Username: `newuser`
   - Email: `newuser@test.com`
   - Password: `password123`
4. Tap "Register"
5. **Expected:** Redirected to appointment screen

#### Test Case 2: Login
1. If logged out, enter credentials:
   - Username: `patient1`
   - Password: `password123`
2. Tap "Login"
3. **Expected:** Redirected to appointment screen with calendar

#### Test Case 3: View Appointments
1. After login, view the calendar
2. **Expected:** Calendar displays with any existing appointments
3. Tap on a date to see appointments for that day

#### Test Case 4: Book New Appointment
1. Tap the "+" (Floating Action Button)
2. Fill in:
   - Doctor Name: `Dr. Johnson`
   - Tap "Date & Time" and select a future date/time
   - Reason (optional): `General consultation`
3. Tap "Book Appointment"
4. **Expected:** 
   - Success message appears
   - Redirected to calendar
   - New appointment appears on selected date

#### Test Case 5: Edit Appointment
1. Find an appointment in the list
2. Tap the menu icon (three dots) on the appointment card
3. Select "Edit"
4. Modify details (e.g., change time or doctor)
5. Tap "Update Appointment"
6. **Expected:** Appointment updated successfully

#### Test Case 6: Cancel Appointment
1. Find an appointment
2. Tap menu icon → "Cancel"
3. Confirm cancellation
4. **Expected:** 
   - Appointment removed from list
   - Status changed to "CANCELLED"

#### Test Case 7: Error Handling
1. Try to book appointment with past date
   - **Expected:** Error message "Appointment time must be in the future"

2. Try to login with wrong credentials
   - **Expected:** Error message "Invalid username or password"

3. Try to book without doctor name
   - **Expected:** Form validation error

### Step 4: Test Loading States
- During API calls, you should see loading indicators
- Buttons should be disabled during loading
- No duplicate submissions possible

## Part 3: Integration Testing

### Test Complete Flow

1. **Backend Running** ✅
   ```bash
   cd backend && mvn spring-boot:run
   ```

2. **Flutter App Running** ✅
   ```bash
   cd mobile_app && flutter run
   ```

3. **Complete User Journey:**
   - Register new account
   - Login
   - Book appointment
   - View on calendar
   - Edit appointment
   - Cancel appointment
   - Logout
   - Login again
   - Verify appointments still visible

## Part 4: Testing with Postman/API Client

### Import Collection

You can use Postman or any REST client to test the API:

1. **Register User**
   - Method: POST
   - URL: `http://localhost:8080/api/auth/register`
   - Body (JSON):
     ```json
     {
       "username": "testuser",
       "password": "password123",
       "email": "test@example.com"
     }
     ```

2. **Login**
   - Method: POST
   - URL: `http://localhost:8080/api/auth/login`
   - Body (JSON):
     ```json
     {
       "username": "testuser",
       "password": "password123"
     }
     ```
   - Copy the `token` from response

3. **Get Appointments**
   - Method: GET
   - URL: `http://localhost:8080/api/appointments`
   - Headers: `Authorization: Bearer <token>`

4. **Create Appointment**
   - Method: POST
   - URL: `http://localhost:8080/api/appointments`
   - Headers: `Authorization: Bearer <token>`
   - Body (JSON):
     ```json
     {
       "doctorName": "Dr. Smith",
       "appointmentDateTime": "2024-01-20T14:30:00",
       "reason": "Checkup"
     }
     ```

## Troubleshooting

### Backend Issues

**Port 8080 already in use:**
```bash
# Find process using port 8080
lsof -i :8080
# Kill the process or change port in application.properties
```

**Maven build fails:**
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

### Flutter Issues

**Can't connect to API:**
- Verify backend is running: `curl http://localhost:8080/api/auth/login`
- Check API URL in `api_service.dart`
- For physical device, ensure same WiFi network
- Check firewall settings

**Build errors:**
```bash
cd mobile_app
flutter clean
flutter pub get
flutter run
```

**App crashes on startup:**
- Check Flutter logs: `flutter logs`
- Verify all dependencies installed: `flutter pub get`
- Check API URL configuration

### Common Errors

1. **"Network error" in Flutter:**
   - Backend not running
   - Wrong API URL
   - CORS issues (should be handled, but check SecurityConfig)

2. **"401 Unauthorized":**
   - Token expired (24 hours)
   - Invalid token
   - Token not sent in header

3. **"Access denied":**
   - Trying to access another user's appointment
   - Token doesn't match user

## Quick Test Checklist

- [ ] Backend starts without errors
- [ ] Can register new user via API
- [ ] Can login and get JWT token
- [ ] Can create appointment with token
- [ ] Can retrieve own appointments
- [ ] Cannot access other user's appointments
- [ ] Flutter app connects to backend
- [ ] Can login in Flutter app
- [ ] Calendar displays correctly
- [ ] Can book appointment from app
- [ ] Can edit appointment
- [ ] Can cancel appointment
- [ ] Error messages display correctly
- [ ] Loading states work properly

## Next Steps

After basic testing:
1. Test with multiple users
2. Test concurrent appointments
3. Test edge cases (past dates, overlapping times)
4. Test security (try accessing other users' data)
5. Performance testing with many appointments


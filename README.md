# Healthcare Appointment System

A full-stack healthcare appointment booking application built with Flutter and Spring Boot, featuring JWT-based authentication and a modern calendar interface.

## Architecture Overview

The system consists of two main components:

1. **Backend API** (Spring Boot): RESTful API providing authentication and appointment management
2. **Mobile App** (Flutter): Cross-platform mobile application with calendar-based appointment booking

### Technology Stack

#### Backend
- **Framework**: Spring Boot 3.2.0
- **Language**: Java 17
- **Security**: Spring Security with JWT authentication
- **Database**: H2 in-memory database (can be easily replaced with PostgreSQL/MySQL)
- **Build Tool**: Maven
- **Key Dependencies**:
  - Spring Boot Web
  - Spring Security
  - Spring Data JPA
  - JJWT (JSON Web Token)
  - Lombok
  - H2 Database

#### Frontend
- **Framework**: Flutter
- **State Management**: Provider
- **HTTP Client**: http package
- **Secure Storage**: flutter_secure_storage (for JWT tokens)
- **Calendar**: table_calendar
- **Key Dependencies**:
  - provider: State management
  - http: API communication
  - flutter_secure_storage: Secure token storage
  - table_calendar: Calendar widget
  - intl: Date/time formatting

## Project Structure

```
healthcare-appointment-system/
├── backend/
│   ├── src/
│   │   └── main/
│   │       ├── java/com/healthcare/appointment/
│   │       │   ├── config/          # Security and JWT configuration
│   │       │   ├── controller/      # REST controllers
│   │       │   ├── dto/             # Data Transfer Objects
│   │       │   ├── model/           # Entity models
│   │       │   ├── repository/       # Data access layer
│   │       │   ├── security/        # JWT authentication filter
│   │       │   └── service/         # Business logic
│   │       └── resources/
│   │           ├── application.properties
│   │           └── data.sql         # Sample data
│   └── pom.xml
└── mobile_app/
    └── lib/
        ├── models/                  # Data models
        ├── services/                # API service
        ├── providers/               # State management
        ├── screens/                 # UI screens
        └── main.dart
```

## Security Features

### Implemented Security Measures

1. **JWT-Based Authentication**
   - Tokens are generated upon successful login/registration
   - Tokens include username and userId claims
   - Tokens expire after 24 hours (configurable)
   - Tokens are validated on every protected endpoint request

2. **Password Security**
   - Passwords are hashed using BCrypt before storage
   - Plain text passwords are never stored in the database
   - Password validation on registration (minimum 6 characters)

3. **Endpoint Protection**
   - All appointment endpoints require valid JWT token
   - Authentication filter validates tokens before request processing
   - Unauthorized requests are rejected with 401 status

4. **Data Validation**
   - Server-side validation for all inputs using Jakarta Validation
   - Client-side validation in Flutter forms
   - Backend never trusts client data - all inputs are validated

5. **User Isolation**
   - Users can only access their own appointments
   - User ID is extracted from JWT token (cannot be spoofed)
   - Authorization checks on all appointment operations

## Business Rules

1. **Appointment Booking**
   - Appointments must be scheduled in the future
   - Doctors cannot have overlapping appointments at the same time
   - Users can only book/modify/cancel their own appointments

2. **Appointment Management**
   - Appointments can be created, viewed, updated, and cancelled
   - Cancelled appointments are marked with "CANCELLED" status
   - Appointment history is maintained with creation timestamps

## API Endpoints

### Authentication Endpoints

- `POST /api/auth/register` - Register a new user
  - Request body: `{ username, password, email, firstName?, lastName? }`
  - Returns: JWT token, username, userId

- `POST /api/auth/login` - Login with credentials
  - Request body: `{ username, password }`
  - Returns: JWT token, username, userId

### Appointment Endpoints (Protected - Require JWT)

- `GET /api/appointments` - Get all appointments for authenticated user
  - Headers: `Authorization: Bearer <token>`
  - Returns: List of appointments

- `POST /api/appointments` - Create a new appointment
  - Headers: `Authorization: Bearer <token>`
  - Request body: `{ doctorName, appointmentDateTime, reason? }`
  - Returns: Created appointment

- `GET /api/appointments/{id}` - Get appointment by ID
  - Headers: `Authorization: Bearer <token>`
  - Returns: Appointment details (only if owned by user)

- `PUT /api/appointments/{id}` - Update an appointment
  - Headers: `Authorization: Bearer <token>`
  - Request body: `{ doctorName, appointmentDateTime, reason? }`
  - Returns: Updated appointment

- `DELETE /api/appointments/{id}` - Cancel an appointment
  - Headers: `Authorization: Bearer <token>`
  - Returns: 204 No Content

## Getting Started

### Prerequisites

- Java 17 or higher
- Maven 3.6+
- Flutter SDK (latest stable version)
- Android Studio / Xcode (for mobile development)

### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Build the project:
```bash
mvn clean install
```

3. Run the application:
```bash
mvn spring-boot:run
```

The API will be available at `http://localhost:8080`

### Frontend Setup

1. Navigate to the mobile_app directory:
```bash
cd mobile_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update API base URL in `lib/services/api_service.dart`:
   - For Android emulator: `http://10.0.2.2:8080/api` (default)
   - For iOS simulator: `http://localhost:8080/api`
   - For physical device: `http://<your-computer-ip>:8080/api`

4. Run the application:
```bash
flutter run
```

## Testing

### Sample Credentials

The application comes with pre-seeded test users:
- Username: `patient1`, Password: `password123`
- Username: `patient2`, Password: `password123`

### Manual Testing Flow

1. **Registration/Login**
   - Open the app
   - Register a new account or login with existing credentials
   - JWT token is automatically stored securely

2. **View Appointments**
   - After login, view the calendar interface
   - Appointments are displayed on their respective dates
   - Tap on a date to see appointments for that day

3. **Book Appointment**
   - Tap the "+" button
   - Fill in doctor name, select date/time, and optional reason
   - Submit to create the appointment

4. **Manage Appointments**
   - Tap the menu icon on any appointment card
   - Edit or cancel appointments
   - Only your own appointments can be modified

## Technical Choices & Trade-offs

### Database Choice: H2 In-Memory

**Choice**: H2 in-memory database for development/demo

**Rationale**:
- Quick setup without external database configuration
- Suitable for demonstration and development
- Easy to replace with PostgreSQL/MySQL for production

**Trade-off**: Data is lost on application restart. For production, replace with a persistent database.

### State Management: Provider

**Choice**: Provider pattern for state management

**Rationale**:
- Simple and lightweight
- Built-in Flutter support
- Sufficient for this application's complexity
- Easy to understand and maintain

**Alternative Considered**: Bloc/Riverpod - More powerful but adds complexity for this use case.

### JWT Token Storage: Flutter Secure Storage

**Choice**: flutter_secure_storage for JWT tokens

**Rationale**:
- Stores tokens in platform-specific secure storage (Keychain/Keystore)
- Prevents token exposure in app memory
- Industry best practice for sensitive data

### Calendar Widget: table_calendar

**Choice**: table_calendar package

**Rationale**:
- Modern, customizable calendar interface
- Good performance
- Active maintenance
- Supports event markers and date selection

### CORS Configuration

**Choice**: Allow all origins in development

**Rationale**:
- Simplifies development across different platforms
- Flutter apps can connect from various origins

**Production Note**: Restrict to specific origins in production for enhanced security.

## Error Handling

### Backend Error Handling
- Validation errors return 400 Bad Request with error messages
- Authentication errors return 401 Unauthorized
- Authorization errors return 403 Forbidden
- All errors include descriptive messages

### Frontend Error Handling
- Network errors are caught and displayed to users
- Loading states prevent duplicate requests
- User-friendly error messages via SnackBars
- Form validation provides immediate feedback

## Loading States

- Backend operations show loading indicators
- Flutter app displays CircularProgressIndicator during API calls
- Buttons are disabled during loading to prevent duplicate submissions
- Smooth transitions between states

## Future Enhancements

### Potential Improvements

1. **Database Integration**
   - Replace H2 with PostgreSQL or MySQL
   - Add database migrations
   - Implement connection pooling

2. **Additional Features**
   - Email notifications for appointments
   - Doctor availability management
   - Appointment reminders
   - Patient profile management
   - Appointment history with filtering

3. **Security Enhancements**
   - Token refresh mechanism
   - Rate limiting
   - Input sanitization
   - SQL injection prevention (already handled by JPA)

4. **Testing**
   - Unit tests for services
   - Integration tests for controllers
   - Flutter widget tests
   - End-to-end tests

5. **UI/UX Improvements**
   - Dark mode support
   - Accessibility features
   - Offline mode with local caching
   - Push notifications

## Known Limitations

1. **Time Constraints**: Some features were simplified due to 24-hour development window
2. **Database**: H2 in-memory database loses data on restart
3. **Error Messages**: Some error messages could be more user-friendly
4. **Validation**: Additional business rule validations could be added
5. **Testing**: Limited automated tests due to time constraints

## License

This project is created for demonstration purposes.

## Contact

For questions or issues, please refer to the repository documentation.


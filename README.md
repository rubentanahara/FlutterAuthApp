# Auth App - Flutter & .NET

# Demo

https://github.com/user-attachments/assets/093c8512-d073-4a81-93d7-cc18ba3667be

--- 

## Prerequisites

### Backend (.NET)
- **.NET SDK 9.0+** - [Download here](https://dotnet.microsoft.com/download)

### Frontend (Flutter)
- **Flutter 3.35.1+** - [Install guide](https://docs.flutter.dev/get-started/install)
- **Dart 3.9.0+** (included with Flutter)

## 🚀 Quick Setup

### 1. Backend Setup (.NET API)

```bash
# Navigate to backend
cd backend/AuthauthenticationAPI

# Install dependencies
dotnet restore

# Install Entity Framework tools (required for database)
dotnet tool install --global dotnet-ef

# Build project
dotnet build

# Create database tables (IMPORTANT!)
dotnet ef database update

# Start backend server
dotnet run
```

**Backend will run at:**
- HTTP: `http://localhost:5062`
- `http://localhost:5062/swagger/index.html`

### 2. Frontend Setup (Flutter)

```bash
# Navigate to frontend
cd frontend

# Install dependencies
flutter pub get

# Generate Riverpod code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Backend Config (`appsettings.json`)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=AuthDB.db"
  },
  "Jwt": {
    "Key": "your-secret-key",
    "Issuer": "YourApp",
    "Audience": "YourApp",
    "ExpiryMinutes": 60
  }
}
```

### Frontend Config (`lib/core/constants/app_constants.dart`)
```dart
static const String baseUrl = 'http://localhost:5022/api';
```

## 🧪 Testing

1. **Start backend**: `dotnet run` from `backend/AuthauthenticationAPI`
2. **Start frontend**: `flutter run` from `frontend`
3. **Test flow**:
   - Open app → Login page appears
   - Tap "Sign Up" → Create account
   - Login with credentials → Access feed
   - Navigate to Profile → Sign out

## 🐛 Common Issues & Fixes

### ❌ Database Error: "no such table: AspNetRoles"

**Problem**: Database tables don't exist

**Fix**:
```bash
cd backend/AuthauthenticationAPI

# Install EF tools if needed
dotnet tool install --global dotnet-ef

# Create database tables
dotnet ef database update

# Start app
dotnet run
```

### ❌ Frontend Build Issues

**Fix**:
```bash
cd frontend

# Clean and reinstall
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## 🔄 Complete Reset (if needed)

### Backend Reset
```bash
cd backend/AuthauthenticationAPI

# Remove database
rm AuthDB.db

# Remove migrations
rm -rf Migrations/

# Create fresh migration
dotnet ef migrations add InitialCreate

# Apply migration
dotnet ef database update

# Start app
dotnet run
```

### Frontend Reset
```bash
cd frontend

# Clean everything
flutter clean
rm -rf .dart_tool/
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## 📖 API Documentation

After starting the backend, visit:
- **Swagger UI**: `https://localhost:7222/swagger`
- **API Endpoints**:
  - `POST /api/Auth/register` - User registration
  - `POST /api/Auth/login` - User login

**Built with ❤️ using Flutter and .NET**

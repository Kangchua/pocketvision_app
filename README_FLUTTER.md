# PocketVision Mobile App

A Flutter mobile application for personal finance management built based on the PocketVision web application.

## Features

✨ **Core Features:**
- 👤 User Authentication (Login & Register)
- 💰 Expense Management (Create, Read, Update, Delete)
- 📊 Budget Management with spending tracking
- 🏷️ Category Management for expenses
- 📱 Dashboard with spending statistics
- 💳 User Profile Management

## Project Structure

```
lib/
├── models/              # Data models
│   ├── user.dart
│   ├── expense.dart
│   ├── category.dart
│   └── budget.dart
├── services/           # API service
│   └── api_service.dart
├── providers/          # State management (Provider)
│   ├── auth_provider.dart
│   ├── expense_provider.dart
│   ├── category_provider.dart
│   └── budget_provider.dart
├── screens/           # UI Screens
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── expenses_screen.dart
│   ├── add_expense_screen.dart
│   ├── budgets_screen.dart
│   └── profile_screen.dart
├── widgets/           # Reusable widgets
├── utils/            # Utility functions
│   ├── app_theme.dart
│   └── format_utils.dart
└── main.dart         # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.10.4)
- Android Studio or Xcode for emulator
- Backend API running (Java Spring Boot server)

### Installation

1. **Install dependencies:**
   ```bash
   cd pocketvision_app
   flutter pub get
   ```

2. **Configure API Server:**
   
   Edit `lib/services/api_service.dart` and update the `baseUrl`:
   ```dart
   static const String baseUrl = 'http://YOUR_SERVER_ADDRESS:8080/api';
   ```

3. **Run the app:**
   ```bash
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   
   # For Web
   flutter run -d chrome
   ```

## Dependencies

Key packages used:
- `provider` - State management
- `dio` - HTTP client
- `shared_preferences` - Local storage
- `intl` - Internationalization (Vietnamese support)
- `fl_chart` - Charts and graphs
- `image_picker` - Image selection
- `cached_network_image` - Image caching

## API Integration

The app connects to the backend API with the following endpoints:

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user

### Expenses
- `GET /api/expenses?userId={userId}` - Get all expenses
- `GET /api/expenses/{id}` - Get expense details
- `POST /api/expenses` - Create new expense
- `PUT /api/expenses/{id}` - Update expense
- `DELETE /api/expenses/{id}` - Delete expense

### Categories
- `GET /api/categories?userId={userId}` - Get all categories
- `POST /api/categories` - Create category

### Budgets
- `GET /api/budgets?userId={userId}` - Get all budgets
- `POST /api/budgets` - Create budget

## Screens

### 1. Authentication
- **Login Screen**: Email and password login
- **Register Screen**: New user registration

### 2. Dashboard
- Welcome message
- Total expenses statistics
- Quick action buttons
- Navigation to other screens

### 3. Expenses
- List all expenses
- Create/Edit/Delete expenses
- Filter by date and category
- View expense details

### 4. Budgets
- View budget allocations
- Track spending vs budget
- Visual progress indicators
- Budget management

### 5. Profile
- User information display
- Settings options
- Logout functionality

## UI/UX Features

- 🎨 Beautiful Material 3 design
- 🌙 Light theme with custom colors
- 📱 Responsive layout
- ⚡ Smooth animations and transitions
- 🔄 Pull-to-refresh functionality
- 💬 Vietnamese localization

## Build & Deployment

### Android Build
```bash
flutter build apk --release
```

### iOS Build
```bash
flutter build ios --release
```

### Web Build
```bash
flutter build web --release
```

## Configuration

### API Base URL
Update in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_SERVER:8080/api';
```

### Date/Time Format
Vietnamese formatting is configured in `main.dart`

### Theme Customization
Edit colors and theme in `lib/utils/app_theme.dart`

## Development

### State Management
The app uses Provider for state management:
- `AuthProvider` - Authentication and user state
- `ExpenseProvider` - Expense data management
- `CategoryProvider` - Category data management
- `BudgetProvider` - Budget data management

### Local Storage
Uses `SharedPreferences` to store:
- User authentication data
- User preferences
- Cache data

## Troubleshooting

### App won't connect to API
- Check if backend server is running
- Verify API base URL is correct
- Check Android device network settings

### Flutter doctor issues
```bash
flutter doctor
flutter pub get
```

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

## Features Coming Soon

- 📈 Advanced spending analytics
- 📧 Monthly reports and email
- 📸 Receipt image upload and OCR
- 🤖 AI-powered expense suggestions
- 💬 Expense notes and tagging
- 🔔 Budget alerts and notifications
- 📊 Multi-chart analytics
- 💾 Data export (PDF, CSV)

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request

## License

This project is licensed under MIT License - see LICENSE file for details.

## Contact

For support and questions, please contact the development team.

---

**Version:** 1.0.0  
**Last Updated:** December 2025

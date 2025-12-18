# 🎯 PocketVision Flutter App - Quick Reference

## 📱 App Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│           PocketVision Mobile App                   │
│           Flutter Application v1.0                  │
└─────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
  │   Screens    │  │  Providers   │  │    Models    │
  │              │  │              │  │              │
  │ • Login      │  │ • Auth       │  │ • User       │
  │ • Register   │  │ • Expense    │  │ • Expense    │
  │ • Dashboard  │  │ • Category   │  │ • Category   │
  │ • Expenses   │  │ • Budget     │  │ • Budget     │
  │ • Budgets    │  │              │  │              │
  │ • Profile    │  │              │  │              │
  └──────────────┘  └──────────────┘  └──────────────┘
        │                 │                 │
        └─────────────────┼─────────────────┘
                          │
                  ┌───────▼───────┐
                  │  API Service  │
                  │   (Dio HTTP)  │
                  └───────┬───────┘
                          │
            ┌─────────────┼─────────────┐
            │             │             │
            ▼             ▼             ▼
        ┌────────┐   ┌────────┐   ┌────────┐
        │  Auth  │   │Expense │   │Budget  │
        │ API    │   │ API    │   │ API    │
        └────────┘   └────────┘   └────────┘
            │             │             │
            └─────────────┼─────────────┘
                          │
                    ┌─────▼─────┐
                    │  Backend   │
                    │  Server    │
                    │ (Java/Spr) │
                    └────────────┘
```

## 🗂️ Project File Structure

```
pocketvision_app/
│
├── lib/                          # Main source code
│   ├── main.dart                 # App entry point
│   │
│   ├── models/                   # Data models (4 files)
│   │   ├── user.dart
│   │   ├── expense.dart
│   │   ├── category.dart
│   │   └── budget.dart
│   │
│   ├── services/                 # Backend API
│   │   └── api_service.dart
│   │
│   ├── providers/                # State management (4 files)
│   │   ├── auth_provider.dart
│   │   ├── expense_provider.dart
│   │   ├── category_provider.dart
│   │   └── budget_provider.dart
│   │
│   ├── screens/                  # UI Screens (7 files)
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── expenses_screen.dart
│   │   ├── add_expense_screen.dart
│   │   ├── budgets_screen.dart
│   │   └── profile_screen.dart
│   │
│   ├── widgets/                  # Reusable components (folder ready)
│   │
│   └── utils/                    # Utilities (2 files)
│       ├── app_theme.dart        # Theme & colors
│       └── format_utils.dart     # Formatting functions
│
├── pubspec.yaml                  # Dependencies
├── pubspec.lock                  # Locked versions
├── analysis_options.yaml         # Lint rules
│
├── android/                      # Android config
├── ios/                          # iOS config
├── web/                          # Web config
├── windows/                      # Windows config
│
├── README_FLUTTER.md             # Full documentation
├── SETUP_GUIDE_VI.md             # Vietnamese guide
└── PROJECT_COMPLETE.md           # Project summary
```

## 🚀 Quick Start Commands

```bash
# Navigate to app
cd pocketvision_app

# Install dependencies
flutter pub get

# Run on Android
flutter run

# Run on iOS
flutter run -d ios

# Run on Web
flutter run -d chrome

# Build for production
flutter build apk --release
flutter build ios --release
flutter build web --release
```

## 📊 App Statistics

| Category | Count |
|----------|-------|
| Model Classes | 4 |
| Provider Classes | 4 |
| Screen Files | 7 |
| Utility Files | 2 |
| Total Dart Files | 19 |
| API Endpoints | 10+ |
| Supported Features | 10+ |

## 🎯 Feature Checklist

### Authentication ✅
- [x] User Registration
- [x] User Login
- [x] Session Management
- [x] Auto-save User Data
- [x] Logout

### Expense Management ✅
- [x] View Expenses
- [x] Add Expense
- [x] Edit Expense
- [x] Delete Expense
- [x] Category Selection
- [x] Date Picker
- [x] Notes/Description

### Budget Management ✅
- [x] View Budgets
- [x] Track Spending
- [x] Progress Indicator
- [x] Remaining Amount Calc

### Dashboard ✅
- [x] Welcome Message
- [x] Total Expenses
- [x] Quick Actions
- [x] Navigation Menu

### Profile ✅
- [x] User Info Display
- [x] Settings Menu
- [x] Logout Option

### UI/UX ✅
- [x] Material 3 Design
- [x] Vietnamese Language
- [x] Currency Formatting
- [x] Responsive Layout
- [x] Loading States
- [x] Error Handling

## 🔗 API Integration Points

```dart
// Auth
POST   /api/auth/register
POST   /api/auth/login

// Expenses
GET    /api/expenses?userId={id}
GET    /api/expenses/{id}
POST   /api/expenses
PUT    /api/expenses/{id}
DELETE /api/expenses/{id}

// Categories
GET    /api/categories?userId={id}
POST   /api/categories

// Budgets
GET    /api/budgets?userId={id}
POST   /api/budgets
```

## 🛠️ Key Technologies

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter | 3.10.4+ | UI Framework |
| Dart | 3.10.4+ | Language |
| Provider | 6.1.5 | State Mgmt |
| Dio | 5.9.0 | HTTP Client |
| SharedPrefs | 2.5.4 | Local Storage |
| Intl | 0.19.0 | Localization |
| FL Chart | 0.65.0 | Charts |

## 📋 Development Workflow

```
1. Start Backend Server
   └─ Run Java Spring Boot app on http://localhost:8080

2. Configure API URL
   └─ Edit lib/services/api_service.dart

3. Install Dependencies
   └─ flutter pub get

4. Run App
   └─ flutter run

5. Test Features
   └─ Register → Login → Add Expense → View Budget

6. Build for Release
   └─ flutter build apk --release
```

## 💡 Important Files

| File | Purpose |
|------|---------|
| main.dart | App initialization & routing |
| api_service.dart | All API calls |
| auth_provider.dart | Authentication logic |
| expense_provider.dart | Expense CRUD |
| app_theme.dart | Colors & typography |
| format_utils.dart | Date/currency formatting |

## 🔒 Security Features

✅ Password encryption during transmission  
✅ User session management  
✅ Local data storage  
✅ API error handling  
✅ Input validation  

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (13+)
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows (with additional setup)
- ✅ macOS (with additional setup)
- ✅ Linux (with additional setup)

## 🧪 Testing Checklist

- [ ] Login with valid credentials
- [ ] Register new account
- [ ] Add expense with all fields
- [ ] Edit expense
- [ ] Delete expense
- [ ] View all expenses
- [ ] Check budget tracking
- [ ] View dashboard stats
- [ ] Logout and login again
- [ ] Check data persists

## 🎨 Color Scheme

```
Primary:      #3B82F6 (Blue)
Secondary:    #10B981 (Green)
Danger:       #EF4444 (Red)
Warning:      #F59E0B (Amber)
Success:      #10B981 (Green)
Background:   #F9FAFB (Light Gray)
```

## 📞 Troubleshooting

| Issue | Solution |
|-------|----------|
| API connection fails | Check backend is running, verify API URL |
| Dependencies error | Run `flutter clean` then `flutter pub get` |
| Build error | Run `flutter doctor`, update SDK |
| Hot reload fails | Use `flutter run` with fresh start |
| Port in use | Stop backend, restart on different port |

## 🎓 Code Examples

### Add Expense
```dart
await context.read<ExpenseProvider>().addExpense(
  userId: user.id,
  categoryId: selectedCategory,
  totalAmount: amount,
  note: note,
  expenseDate: selectedDate,
);
```

### Fetch Data
```dart
await context.read<ExpenseProvider>().fetchExpenses(user.id);
```

### Format Currency
```dart
FormatUtils.formatCurrency(100000) // "₫100.000"
```

---

## 📞 Support Resources

- **Flutter Docs:** https://flutter.dev/docs
- **Dart Docs:** https://dart.dev/guides
- **Provider Docs:** https://pub.dev/packages/provider
- **Dio Docs:** https://pub.dev/packages/dio

## ✨ Project Status

**Status:** ✅ **COMPLETE AND READY TO USE**

- All core features implemented
- All dependencies installed and compatible
- API integration configured
- Documentation complete
- Ready for testing and deployment

---

**Version:** 1.0.0  
**Created:** December 2025  
**Framework:** Flutter  
**Platform:** Cross-platform Mobile App

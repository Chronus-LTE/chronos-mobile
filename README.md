# Chronos Mobile App

A beautiful, feature-rich mobile application for managing your emails, calendar, and AI-powered chat assistant. Built with Flutter for cross-platform support (iOS, Android, Web, Desktop).

## 🌟 Features

### 📧 Email Management

- **Gmail Integration**: Full Gmail sync with read, send, delete, star operations
- **Smart Search**: Debounced search with instant results
- **Folder Navigation**: Inbox, Sent, Drafts, Starred, Important, Spam, Trash
- **HTML Email Rendering**: Beautiful email display with attachments
- **Compose & Send**: Full-featured email composition with validation
- **Sync Status**: Real-time sync progress tracking
- **Swipe Actions**: Quick delete with swipe gestures

### 📅 Calendar

- **Google Calendar Integration**: View and manage your calendar events
- **Event Management**: Create, edit, and delete events
- **Multiple Views**: Day, week, month views

### 💬 AI Chat Assistant

- **Intelligent Conversations**: AI-powered chat for productivity
- **Context-Aware**: Remembers conversation history
- **Beautiful UI**: Smooth animations and modern design

## 🎨 Design

The app features a warm, **clay-toned color palette** with:

- Premium gradients and smooth animations
- Clean, modern typography (Inter, Space Grotesk)
- Responsive layouts for all screen sizes
- Dark mode support (coming soon)

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.7.2 or higher
- **Dart SDK**: Included with Flutter
- **Android Studio** or **Xcode** for mobile development
- **Google Cloud Project** with OAuth 2.0 credentials

### Installation

1. **Clone the repository**

   ```bash
   cd chronos-mobile
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Google Sign-In**

   Update `lib/features/auth/services/auth_service.dart` with your OAuth credentials:

   ```dart
   serverClientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
   ```

4. **Configure Backend URL**

   Update `lib/core/services/api_client.dart` with your backend URL:

   ```dart
   static String get baseUrl {
     if (Platform.isAndroid) {
       return 'http://10.0.2.2:8000';  // Android emulator
     }
     return 'http://localhost:8000';   // iOS simulator
   }
   ```

5. **Run the app**

   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For Web
   flutter run -d chrome

   # For Desktop
   flutter run -d macos  # or windows, linux
   ```

## 📁 Project Structure

```
lib/
├── core/
│   ├── layout/          # Main app layout and navigation
│   ├── services/        # Core services (API client, auth)
│   └── theme/           # App colors and theme
├── features/
│   ├── auth/            # Authentication (login, register, Google Sign-In)
│   ├── email/           # Email feature
│   │   ├── models/      # Data models
│   │   ├── services/    # Email API service
│   │   ├── viewmodels/  # State management
│   │   └── presentation/# UI screens and widgets
│   ├── calendar/        # Calendar feature
│   ├── chat/            # AI chat feature
│   └── onboarding/      # Onboarding screens
└── main.dart            # App entry point
```

## 🔧 Configuration

### Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable APIs:
   - Gmail API
   - Google Calendar API
   - Google Tasks API
4. Create OAuth 2.0 credentials:
   - **Android**: Add SHA-1 fingerprint
   - **iOS**: Add bundle ID
   - **Web**: Add authorized domains

### Required Scopes

```dart
'email',
'profile',
'openid',
'https://www.googleapis.com/auth/calendar',
'https://www.googleapis.com/auth/tasks',
'https://www.googleapis.com/auth/gmail.readonly',
'https://www.googleapis.com/auth/gmail.send',
'https://www.googleapis.com/auth/gmail.modify',
```

## 🏗️ Architecture

### State Management

- **Provider**: For dependency injection and state management
- **ChangeNotifier**: For reactive UI updates

### Design Patterns

- **MVVM**: Model-View-ViewModel architecture
- **Repository Pattern**: Service layer for API calls
- **Dependency Injection**: Using Provider

### Performance Optimizations

- **Response Caching**: 30-second TTL for email lists
- **Search Debouncing**: 300ms delay to reduce API calls
- **Lazy Loading**: Pagination for large lists
- **Optimistic Updates**: Instant UI feedback
- **Proper Cleanup**: Dispose controllers and timers

## 📦 Dependencies

### Core

- `provider: ^6.1.2` - State management
- `http: ^1.2.2` - HTTP client
- `google_sign_in: ^6.2.2` - Google authentication
- `shared_preferences: ^2.5.3` - Local storage

### UI

- `flutter_html: ^3.0.0-beta.2` - HTML rendering
- `flutter_slidable: ^3.0.0` - Swipe actions
- `intl: ^0.19.0` - Date formatting

### Utilities

- `dartz: ^0.10.1` - Functional programming
- `uuid: ^4.5.1` - UUID generation

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## 🔨 Build

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

### Desktop

```bash
flutter build macos --release
# or
flutter build windows --release
# or
flutter build linux --release
```

## 🐛 Troubleshooting

### Common Issues

**403 Forbidden on API calls**

- Ensure you're logged in with Google
- Check that AuthService has a valid token
- Verify backend is running

**Google Sign-In fails**

- Check OAuth credentials are correct
- Verify SHA-1 fingerprint (Android)
- Ensure bundle ID matches (iOS)

**Emails not loading**

- Check backend URL configuration
- Verify Gmail API is enabled
- Check network connectivity

**Build errors**

```bash
flutter clean
flutter pub get
flutter run
```

## 📱 Supported Platforms

- ✅ Android (5.0+)
- ✅ iOS (12.0+)
- ✅ Web (Chrome, Safari, Firefox, Edge)
- ✅ macOS (10.14+)
- ✅ Windows (10+)
- ✅ Linux

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Team

Chronos Development Team

## 🔗 Related Repositories

- [Chronus AI Backend](../chronus-ai) - FastAPI backend with Gmail integration
- [Chronus Web App](../chronus-webapp) - Angular web application

## 📞 Support

For issues and questions:

- Create an issue in this repository
- Contact the development team

---

**Made with ❤️ using Flutter**

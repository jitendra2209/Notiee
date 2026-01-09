# Notiee - Project Overview

## 📋 Project Summary

**Notiee** is a modern Flutter application that serves as a smart daily companion for managing todos, notes, and bills. The app features a beautiful **neumorphic design system** and is built with clean architecture principles, powered by Firebase for real-time synchronization.

## 🏗️ Architecture

### Clean Architecture Implementation
- **Domain Layer**: Business logic and entities with clear boundaries
- **Application Layer**: BLoC state management with reactive patterns  
- **Infrastructure Layer**: Firebase, Firestore, and external data sources
- **Presentation Layer**: Neumorphic UI components and pages

### Project Structure
```
lib/
├── core/                          # Core utilities and shared components
│   ├── di/                        # Dependency injection setup
│   ├── errors/                    # Error handling and failures
│   └── utils/                     # Utility functions and constants
├── features/                      # Feature-based modules
│   ├── authentication/            # User authentication
│   ├── todo/                     # Todo & Notes management
│   ├── bills/                    # Bills & Group management
│   └── profile/                  # User profile management
├── main.dart                     # App entry point
├── home.dart                     # Main navigation
├── splash_screen.dart            # Animated splash screen
└── firebase_options.dart         # Firebase configuration
```

## ✨ Key Features

### 🎨 Neumorphic Design System
- **Soft Shadows**: Multi-layered shadow system with light source from top-left
- **Extruded Elements**: 3D-like buttons, cards, and interactive components
- **Color Palette**: 
  - Background: `#E6EBEF` (soft light gray)
  - Primary: `Colors.redAccent.shade100` with gradients
  - Text: `#2E3A4B` (dark blue-gray) / `#7C8BA0` (medium gray)

### 🔐 Authentication
- Phone-based authentication with Firebase
- Neumorphic login/signup forms
- Password strength validation
- Session management

### 📋 Todo & Notes Management
- CRUD operations with real-time sync
- Priority system (High, Medium, Low)
- Notes with color coding, tags, and pinning
- Three-tab organization (Ongoing, Completed, Notes)

### 💰 Bills & Group Management
- Group creation with contact integration
- Month-based organization
- Real device contacts with permission handling
- Member management with visual selection

### 👤 Profile Management
- Comprehensive profile editing
- Social media integration
- Expandable developer info section
- Password management

## 🛠️ Tech Stack

### Frontend
- **Flutter** (SDK ^3.5.3)
- **Dart** (Latest stable)
- **Neumorphic Design System** (Custom implementation)

### State Management
- **flutter_bloc** ^9.1.1
- **equatable** ^2.0.5

### Backend & Database
- **Firebase Core** ^4.1.0
- **Firebase Auth** ^6.0.2
- **Cloud Firestore** ^6.0.1

### Key Dependencies
- **get_it** ^8.2.0 (Dependency Injection)
- **dartz** ^0.10.1 (Functional Programming)
- **flutter_contacts** ^1.1.9 (Contacts)
- **permission_handler** ^12.0.1 (Permissions)
- **crypto** ^3.0.3 (Password Hashing)
- **flutter_svg** ^2.2.0 (SVG Support)
- **url_launcher** ^6.1.14 (External URLs)
- **http** ^1.2.2 (HTTP Requests)

## 📱 Application Flow

```
├── Splash Screen (/)
├── Authentication
│   ├── Login Page (/login)
│   └── Signup Page (/signup)
├── Main Navigation (/main)
│   ├── Todos Tab (Ongoing, Completed, Notes)
│   └── Bills Tab (Group management)
├── Todo Management
│   ├── Add/Edit Todo (/add_edit_todo)
│   └── Add/Edit Note (/add_edit_note)
├── Bills Management
│   └── Create Group (Contact integration)
└── Profile (/profile)
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.5.3)
- Firebase Project Setup
- Android Studio / VS Code

### Installation
1. Clone repository
2. Run `flutter pub get`
3. Configure Firebase
4. Add platform-specific configuration files
5. Run `flutter run`

## 📁 Key Files

- **`pubspec.yaml`**: Dependencies and app configuration
- **`main.dart`**: App entry point with theme setup
- **`home.dart`**: Main navigation with neumorphic FAB
- **`firebase_options.dart`**: Firebase configuration
- **`lib/core/`**: Shared utilities and dependency injection
- **`lib/features/`**: Feature-based modules with BLoC pattern

## 🔮 Future Enhancements

- Expense tracking and bill splitting
- Push notifications
- Dark theme implementation
- Offline sync capability
- File attachments for notes
- Advanced filtering and search
- Voice input functionality
- Collaborative features

## 📊 Development Status

The project is actively developed with:
- ✅ Complete neumorphic design system
- ✅ Full authentication flow
- ✅ Todo and notes management
- ✅ Group and bills management
- ✅ Profile management
- ✅ Real-time Firebase integration
- ✅ Contact integration
- 🚧 Future enhancements in progress

---

**Notiee** - *Your Smart Daily Companion with Beautiful Neumorphic Design* 🌟✨

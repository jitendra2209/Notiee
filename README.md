# Notiee - Your Smart Daily Companion

![Notiee Logo](assets/logo/logo.png)

Notiee is a modern, feature-rich Flutter application that serves as your smart daily companion for managing todos, notes, and bills. Built with clean architecture principles and powered by Firebase, it offers a seamless and beautiful user experience with real-time synchronization across all platforms.

## ✨ Features

### 🚀 **Latest Updates**
- **✅ Notes Management**: Complete notes system with colors, tags, and pinning
- **✅ Enhanced Profile**: Comprehensive profile management with social links
- **✅ Smart Navigation**: Three-tab system with improved user experience
- **✅ Advanced Authentication**: Password strength validation and secure updates
- **✅ Developer Integration**: Social media links and contact information
- **✅ External URL Support**: Seamless external link opening capabilities

### 🎨 **Modern UI/UX**
- **Splash Screen**: Beautiful animated splash screen with logo and loading indicators
- **Floating Navigation**: Elegant bottom navigation bar with floating design
- **Material Design 3**: Modern UI components with Indigo and Red accent scheme
- **Responsive Design**: Optimized for all screen sizes
- **Smooth Animations**: Delightful transitions and micro-interactions
- **Grid Layouts**: Optimized card-based layouts for notes and content
- **Interactive Elements**: Context menus, expandable sections, and dynamic theming

### 🔐 **Authentication System**
- **Phone-based Authentication**: Login/signup using phone numbers
- **Firebase Authentication**: Secure backend authentication
- **Password Protection**: Encrypted password storage
- **Auto-Navigation**: Smart routing based on authentication state
- **Session Management**: Persistent login sessions

### 📋 **Todo Management**
- **Create Todos**: Add tasks with title, description, and priority levels
- **Edit Todos**: Modify existing tasks with full editing capabilities
- **Complete Tasks**: Mark todos as completed with visual feedback and timestamps
- **Delete Todos**: Remove unwanted tasks with confirmation dialogs
- **Priority System**: High, Medium, Low priority with color-coded indicators
- **Reminder Dates**: Set reminder dates for important tasks
- **Real-time Sync**: Live updates across devices via Firebase Firestore
- **Tab Organization**: Separate tabs for Ongoing and Completed tasks
- **Empty State**: Beautiful empty state with helpful guidance

### 📝 **Notes Management**
- **Rich Note Editor**: Create notes with titles and formatted content
- **Color Coding**: 8 beautiful color themes for visual organization
- **Pin Important Notes**: Keep essential notes at the top of the list
- **Tag System**: Organize notes with custom hashtags
- **Grid Layout**: Optimized 2-column grid display for mobile viewing
- **Smart Organization**: Separate sections for pinned and regular notes
- **Real-time Sync**: Instant synchronization across all devices
- **Empty State**: Encouraging guidance for first-time users

### 👤 **Profile Management**
- **User Profile**: Comprehensive profile management with editable fields
- **Password Updates**: Secure password changing with strength indicators
- **Field Editing**: Individual field editing for name, phone, and email
- **Loading States**: Visual feedback during profile operations
- **Developer Info**: Expandable section with developer details and social links
- **Social Media Integration**: Direct links to GitHub, LinkedIn, Facebook, WhatsApp, Twitter, and website
- **Real-time Validation**: Password strength checking and confirmation matching

### 💰 **Bills Section**
- **Bills Tab**: Dedicated section for future bill management features
- **Ready for Expansion**: Structured architecture for adding bill tracking

### 🏗️ **Architecture & Technical Features**

#### **Clean Architecture**
- **Domain Layer**: Business logic and entities
- **Application Layer**: Use cases and BLoC state management
- **Infrastructure Layer**: External data sources and repositories
- **Presentation Layer**: UI components and widgets

#### **State Management**
- **Flutter BLoC**: Reactive state management with clear separation of concerns
- **Event-driven**: Predictable state changes through events
- **Stream-based**: Real-time UI updates

#### **Backend & Data**
- **Firebase Core**: Backend infrastructure
- **Firestore**: NoSQL database for todos and user data
- **Firebase Auth**: User authentication and session management
- **Real-time Sync**: Automatic data synchronization

#### **Dependency Injection**
- **GetIt**: Service locator for dependency management
- **Repository Pattern**: Clean separation between data sources and business logic
- **Lazy Loading**: Efficient resource management

## 📱 **Screenshots**

### App Flow
1. **Splash Screen** → **Authentication** → **Main Navigation**
2. **Home Tab** (Todos & Notes) ↔ **Bills Tab** ↔ **Profile**
3. **Smart FAB** → **Add Todo** or **Add Note**
4. **Tab Navigation** → **Ongoing** | **Completed** | **Notes**

### Navigation Structure
```
├── Splash Screen (/)
├── Authentication
│   ├── Login Page (/login)
│   └── Signup Page (/signup)
├── Main Navigation (/main)
│   ├── Home Tab (Todos)
│   └── Bills Tab
└── Todo Management
    └── Add/Edit Todo (/add_edit_todo)
```

## 🛠️ **Tech Stack**

### **Frontend**
- **Flutter** (SDK ^3.5.3)
- **Dart** (Latest stable)
- **Material Design 3**

### **State Management**
- **flutter_bloc** ^8.1.6
- **equatable** ^2.0.5

### **Backend & Database**
- **Firebase Core** ^3.6.0
- **Firebase Auth** ^5.3.1
- **Cloud Firestore** ^5.4.4

### **Architecture & Utils**
- **get_it** ^7.7.0 (Dependency Injection)
- **dartz** ^0.10.1 (Functional Programming)
- **crypto** ^3.0.3 (Password Hashing)
- **flutter_svg** ^2.2.0 (SVG Support)
- **http** ^1.2.2 (HTTP Requests)
- **url_launcher** ^6.1.14 (External URL Support)

### **Development**
- **flutter_lints** ^4.0.0
- **flutter_test** (Testing framework)

## 🚀 **Getting Started**

### **Prerequisites**
- Flutter SDK (^3.5.3)
- Dart SDK (Latest)
- Firebase Project Setup
- Android Studio / VS Code
- iOS/Android development environment

### **Installation**

1. **Clone the Repository**
   ```bash
   git clone [repository-url]
   cd notiee
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Add Android/iOS apps to Firebase
   - Download and place configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`
   - Run FlutterFire configure:
     ```bash
     flutterfire configure
     ```

4. **Run the App**
   ```bash
   flutter run
   ```

### **Building for Production**

#### **Android**
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### **iOS**
```bash
flutter build ios --release
```

## 📁 **Project Structure**

```
lib/
├── core/                          # Core utilities and shared components
│   ├── di/                        # Dependency injection setup
│   ├── errors/                    # Error handling and failures
│   └── utils/                     # Utility functions and constants
├── features/                      # Feature-based modules
│   ├── authentication/            # User authentication
│   │   ├── application/           # BLoC and business logic
│   │   ├── domain/               # Entities and repository contracts
│   │   ├── infrastructure/       # Data sources and implementations
│   │   └── presentation/         # UI components and pages
│   ├── todo/                     # Todo & Notes management
│   │   ├── application/          # Todo & Note BLoCs and events
│   │   │   └── bloc/            # TodoBloc & NoteBloc
│   │   ├── domain/              # Todo & Note models and contracts
│   │   │   ├── models/          # TodoModel & NoteModel
│   │   │   └── repositories/    # Repository interfaces
│   │   ├── infrastructure/      # Firestore implementations
│   │   └── presentation/        # Todo & Note UI components
│   │       ├── pages/          # List, Add/Edit pages
│   │       └── widgets/        # Reusable UI components
│   ├── profile/                 # User profile management
│   │   ├── application/         # Profile BLoC and events
│   │   ├── domain/             # Profile models and contracts
│   │   ├── infrastructure/     # Profile data implementation
│   │   └── presentation/       # Profile UI components
│   └── bills/                   # Bills management (future expansion)
│       └── presentation/        # Bills UI components
├── main.dart                    # App entry point
├── home.dart                   # Main navigation page
├── splash_screen.dart          # Animated splash screen
└── firebase_options.dart       # Firebase configuration
```

## 🎯 **Key Features in Detail**

### **Authentication Flow**
- Phone number + password authentication
- Automatic email derivation from phone number
- Plain text password storage
- Firebase Auth integration
- Persistent sessions

### **Todo Management**
- **CRUD Operations**: Create, Read, Update, Delete todos
- **Priority System**: High, Medium, Low priority levels with color coding
- **Tab Organization**: Separate tabs for Ongoing and Completed tasks  
- **Real-time Updates**: Live synchronization across devices
- **User Isolation**: Each user sees only their todos
- **Rich UI**: Checkboxes, edit/delete actions, completion states
- **Reminder System**: Set reminder dates for important tasks
- **Optimistic Updates**: Immediate UI feedback

### **Notes Management**
- **Rich Editor**: Create notes with titles and formatted content
- **Color System**: 8 beautiful color themes for visual organization
- **Pin Functionality**: Keep important notes at the top
- **Tag System**: Organize notes with custom hashtags
- **Grid Display**: Optimized 2-column layout for mobile
- **Real-time Sync**: Instant updates across all devices
- **Smart Organization**: Pinned and regular note sections

### **Profile System**
- **User Management**: Comprehensive profile with editable fields
- **Password Security**: Password strength validation and secure updates
- **Social Integration**: Developer contact links and social media
- **Real-time Updates**: Live profile synchronization
- **Field Validation**: Input validation and error handling

### **Navigation System**
- **Bottom Navigation**: Floating design with Home and Bills tabs
- **Smart FAB**: Popup menu for Todo and Note creation
- **Tab Navigation**: Three-tab system (Ongoing, Completed, Notes)
- **Smart Routing**: Context-aware navigation based on auth state
- **Hero Animations**: Smooth transitions between screens

## 🔮 **Future Enhancements**

### **Planned Features**
- [ ] Bill tracking and management
- [ ] Due date reminders with notifications
- [ ] Note categories and advanced filtering
- [ ] File attachments for notes and todos
- [ ] Dark theme support
- [ ] Offline synchronization
- [ ] Push notifications for reminders
- [ ] Data export/backup functionality
- [ ] Collaborative todos and shared notes
- [ ] Voice input for quick note creation
- [ ] Advanced search across todos and notes
- [ ] Note sharing capabilities

### **Technical Improvements**
- [ ] Unit and integration tests
- [ ] Performance optimizations
- [ ] Accessibility improvements
- [ ] Internationalization (i18n)
- [ ] Analytics integration
- [ ] Crash reporting
- [ ] CI/CD pipeline

## 🤝 **Contributing**

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Coding Standards**
- Follow Flutter/Dart style guidelines
- Use clean architecture principles
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 **Team**

Built with ❤️ by the Notiee development team.

## 📞 **Support**

For support, email support@notiee.app or create an issue in this repository.

---

**Notiee** - *Your Smart Daily Companion* 🌟
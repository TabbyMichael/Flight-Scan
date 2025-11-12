# SkyScan Flight Viewer

[![Flutter](https://img.shields.io/badge/Flutter-%5E3.8.1-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/github/license/yourusername/skyscan-flight-viewer)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web-lightgrey)](#)

A modern, cross-platform flight search and booking application built with Flutter. SkyScan allows users to search for flights, view detailed flight information, filter results, and manage bookings.

## Table of Contents

- [Features](#features)
- [Installation & Setup](#installation--setup)
- [Usage Examples](#usage-examples)
- [Configuration](#configuration)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Testing](#testing)
- [Deployment](#deployment)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Features

- 🔍 **Advanced Flight Search**: Search flights with filters for price, stops, and airlines
- 📱 **Responsive UI**: Clean, intuitive interface that works on mobile and web
- 🌙 **Dark/Light Theme**: Toggle between themes with persistent user preference
- 🎯 **Flight Filtering**: Filter flights by price, number of stops, and airline
- 📋 **Detailed Flight Information**: View comprehensive flight details including segments
- 🛒 **Booking Management**: Manage your flight bookings in one place
- 🌐 **Cross-Platform**: Runs on Android, iOS, and Web
- ⚡ **Real-time Data**: Fetches live flight data from backend API

## Installation & Setup

### Prerequisites

- Flutter SDK ^3.8.1
- Dart SDK ^3.8.1
- Android Studio or Xcode for mobile development
- Backend API running (see backend setup)

### Backend Setup

1. Navigate to the backend directory:
```bash
cd ../backend
```

2. Create a virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Run the backend API:
```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`

### Flutter App Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd flight_viewer
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Configure API connection:
- For Android emulator: `http://10.0.2.2:8000` (already configured)
- For web: `http://localhost:8000`
- For physical device: Replace with your computer's IP address

4. Run the app:
```bash
flutter run
```

## Usage Examples

1. Launch the app to see the onboarding screen
2. Navigate to the "Search Flights" tab
3. Browse available flights or apply filters
4. Tap on any flight to view detailed information
5. Switch to "My Bookings" tab to manage your reservations
6. Toggle between dark/light mode using the theme switcher in the app bar

## Configuration

### API Configuration

The API service configuration can be found in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://10.0.2.2:8000'; // For Android emulator
// static const String baseUrl = 'http://localhost:8000'; // For web
// static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000'; // For physical device
```

### Theme Configuration

Themes are defined in `lib/main.dart` with separate configurations for light and dark modes.

## Tech Stack

- **Frontend**: Flutter ^3.8.1, Dart ^3.8.1
- **State Management**: Provider
- **Networking**: http package
- **Backend**: Python, FastAPI
- **Data Format**: JSON
- **Persistence**: Shared Preferences
- **UI Components**: Material Design

### Key Dependencies

- `http`: ^1.5.0 - For API communication
- `provider`: ^6.1.5+1 - State management
- `shared_preferences`: ^2.5.3 - Local data persistence
- `intl`: ^0.20.2 - Internationalization and date formatting
- `cached_network_image`: ^3.4.1 - Image caching

## Architecture

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models (Flight, Booking, etc.)
├── providers/                # State management providers
├── screens/                  # UI screens and pages
├── services/                 # API services and business logic
├── widgets/                  # Reusable UI components
```

## Testing

### Run Unit Tests

```bash
flutter test test/unit/
```

### Run Widget Tests

```bash
flutter test test/widget/
```

### Run All Tests

```bash
flutter test
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

## Deployment

### Android

1. Update version in `pubspec.yaml`
2. Build release APK:
```bash
flutter build apk --release
```

### iOS

1. Update version in `pubspec.yaml`
2. Build for iOS:
```bash
flutter build ios --release
```

### Web

1. Build for web:
```bash
flutter build web
```

## Roadmap

- [ ] Implement booking creation flow
- [ ] Add push notifications for flight updates
- [ ] Integrate maps for airport locations
- [ ] Add offline support
- [ ] Implement user authentication
- [ ] Add multi-language support
- [ ] Enhance accessibility features

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flight data provided by travel API
- Icons from Flutter's built-in icon library
- UI inspiration from modern travel applications
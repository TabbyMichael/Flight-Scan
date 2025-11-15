# SkyScan Flight Viewer

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-blue.svg)](https://flutter.dev/docs)

A modern cross-platform flight search and booking application built with Flutter. SkyScan allows users to search for flights, view detailed flight information, and manage bookings with an intuitive and responsive interface.

<p align="center">
  <img src="assets/images/app_icon.png" alt="SkyScan Logo" width="200">
</p>

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Installation & Setup](#installation--setup)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Testing](#testing)
- [Contribution Guidelines](#contribution-guidelines)
- [License](#license)

## Features

- ✈️ **Flight Search**: Search for flights with filters for price, stops, airlines, and dates
- 📱 **Cross-Platform**: Native mobile experience on iOS and Android
- 🌙 **Dark/Light Mode**: Toggle between themes with persistent user preference
- 🔍 **Advanced Filtering**: Filter flights by price, stops, duration, and airlines
- 📋 **Booking Management**: View and manage all your flight bookings
- 🎨 **Modern UI**: Clean, intuitive interface with smooth animations
- 🛫 **Detailed Flight Info**: Comprehensive flight details including segments and pricing
- 💾 **Data Persistence**: Save user preferences and booking history locally
- 🎉 **Onboarding Experience**: Guided introduction for new users

## Screenshots

<p align="center">
  <img src="docs/screenshots/search_light.png" width="200" alt="Search Screen Light">
  <img src="docs/screenshots/flight_detail.png" width="200" alt="Flight Detail Screen">
  <img src="docs/screenshots/bookings_dark.png" width="200" alt="Bookings Screen Dark">
</p>

## Tech Stack

- **Framework**: Flutter 3.8.1
- **State Management**: Provider
- **Networking**: http package
- **UI Components**: Material Design & Cupertino widgets
- **Local Storage**: shared_preferences
- **Fonts**: Google Fonts (Roboto)
- **Icons**: Font Awesome & Cupertino Icons

## Installation & Setup

### Prerequisites

- Flutter SDK 3.8.1+
- Android Studio or Xcode for mobile development
- Dart SDK 3.8.1+

### Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/skyscan-flight-viewer.git
   cd skyscan-flight-viewer/flight_viewer
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Running with Backend

To fully utilize the app, you'll need to run the backend API:

1. Start the backend server (from the backend directory):
   ```bash
   cd ../backend
   source venv/bin/activate
   uvicorn app.main:app --reload
   ```

2. Run the Flutter app:
   ```bash
   cd ../flight_viewer
   flutter run
   ```

## Usage

### First Launch

On first launch, users will see an onboarding screen explaining the app features. After completing the onboarding, users can:

1. Search for flights using the search form
2. Filter results by price, stops, duration, and airlines
3. View detailed flight information
4. Book flights and manage bookings
5. Toggle between light and dark themes

### Navigation

- **Search Flights**: Find and filter flights
- **My Bookings**: View and manage your bookings

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── airline.dart
│   ├── booking.dart
│   ├── extra_service.dart
│   ├── flight.dart
│   └── receipt.dart
├── providers/                # State management
│   ├── booking_provider.dart
│   ├── extra_service_provider.dart
│   ├── flight_provider.dart
│   └── theme_provider.dart
├── screens/                  # App screens
│   ├── error_screen.dart
│   ├── flight_detail_screen.dart
│   ├── home_screen.dart
│   ├── loading_screen.dart
│   ├── main_tab_screen.dart
│   ├── my_bookings_screen.dart
│   ├── onboarding_screen.dart
│   ├── passenger_details_screen.dart
│   ├── receipt_screen.dart
│   ├── review_pay_screen.dart
│   ├── search_form_screen.dart
│   └── select_services_screen.dart
├── services/                 # Utility services
│   └── haptics_service.dart
├── utils/                    # Helper functions
│   └── navigation_utils.dart
└── widgets/                  # Custom widgets
    ├── custom_loader.dart
    └── filter_bottom_sheet.dart
```

## Dependencies

### Core Dependencies

- `flutter`: UI toolkit
- `provider`: State management
- `http`: HTTP client for API requests
- `intl`: Internationalization and date formatting
- `shared_preferences`: Local data persistence
- `google_fonts`: Custom font integration
- `font_awesome_flutter`: Icon library
- `cupertino_icons`: iOS-style icons
- `flutter_svg`: SVG image support
- `cached_network_image`: Image caching
- `flutter_native_splash`: Splash screen
- `onboarding`: Onboarding screen components

### Dev Dependencies

- `flutter_test`: Testing framework
- `flutter_lints`: Code linting
- `flutter_launcher_icons`: App icon generation

## Testing

Run widget tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## Contribution Guidelines

We welcome contributions to SkyScan Flight Viewer! Here's how you can help:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Create a new Pull Request

### Code Standards

- Follow the existing code style
- Write clear, descriptive commit messages
- Add tests for new functionality
- Update documentation as needed

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## Acknowledgments

- UI design inspired by modern travel applications
- Built with [Flutter](https://flutter.dev/)
- Icons from [Font Awesome](https://fontawesome.com/) and [Cupertino Icons](https://pub.dev/packages/cupertino_icons)

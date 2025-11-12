# SkyScan Flight Viewer - Flutter Test Suite

Comprehensive test suite for the SkyScan Flight Viewer mobile application, built with Flutter and Dart.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Running Tests](#running-tests)
- [Test Structure](#test-structure)
- [Coverage](#coverage)
- [CI/CD Integration](#cicd-integration)
- [Widget Testing](#widget-testing)
- [Integration Testing](#integration-testing)
- [License](#license)

## Features

- ✅ **Unit Tests** - Test individual components and providers
- ✅ **Widget Tests** - Verify UI component behavior
- ✅ **Integration Tests** - Test complete user workflows
- ✅ **Code Coverage** - Track test coverage with Flutter's built-in tools
- ✅ **CI/CD Ready** - GitHub Actions workflow integration
- ✅ **Mocking** - Isolated testing with mocked dependencies

## Tech Stack

- [Flutter](https://flutter.dev/) - UI toolkit for building natively compiled applications
- [Dart](https://dart.dev/) - Client-optimized language for fast apps
- [flutter_test](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) - Testing library for Flutter
- [integration_test](https://pub.dev/packages/integration_test) - Integration testing package
- [provider](https://pub.dev/packages/provider) - State management
- [GitHub Actions](https://github.com/features/actions) - CI/CD

## Installation

1. Navigate to the Flutter app directory:
   ```bash
   cd flight_viewer
   ```

2. Ensure all dependencies are installed:
   ```bash
   flutter pub get
   ```

## Running Tests

### Run all tests:
```bash
flutter test
```

### Run tests with coverage:
```bash
flutter test --coverage
```

### Run specific test types:
```bash
# Run unit tests only
flutter test test/unit/

# Run widget tests only
flutter test test/widget/

# Run integration tests only
flutter test test/integration/
```

## Test Structure

```
test/
├── unit/
│   ├── providers/
│   │   ├── flight_provider_test.dart     # Flight provider tests
│   │   └── theme_provider_test.dart      # Theme provider tests
│   └── services/
│       └── api_service_test.dart         # API service tests
├── widget/
│   ├── home_screen_test.dart             # Home screen widget tests
│   └── widget_test.dart                  # Default widget tests
├── integration/
│   └── booking_flow_test.dart            # Booking flow integration tests
└── README.md                             # This file
```

## Coverage

To generate a coverage report:
```bash
flutter test --coverage
```

To view the coverage report in HTML format:
```bash
# Install lcov if not already installed
sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open the report
open coverage/html/index.html
```

## CI/CD Integration

Tests are automatically run on every push and pull request via GitHub Actions:

```yaml
# .github/workflows/ci.yml
jobs:
  flutter-test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
    - name: Install dependencies
      run: |
        cd flight_viewer
        flutter pub get
    - name: Run tests
      run: |
        cd flight_viewer
        flutter test --coverage
```

## Widget Testing

Widget tests verify the behavior of Flutter UI components. Example test:

```dart
testWidgets('HomeScreen displays loading indicator initially', (WidgetTester tester) async {
  // Build the HomeScreen widget with mocked provider
  await tester.pumpWidget(
    MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<FlightProvider>(create: (_) => MockFlightProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const HomeScreen(),
      ),
    ),
  );
  
  // Verify that the loading indicator is displayed
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Integration Testing

Integration tests verify complete user workflows. Example test structure:

```dart
testWidgets('Complete booking flow', (WidgetTester tester) async {
  // This would test the complete flow from flight search to booking confirmation
  // Requires a running backend API or mocked HTTP responses
});
```

To run integration tests:
```bash
flutter test test/integration/
```

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.
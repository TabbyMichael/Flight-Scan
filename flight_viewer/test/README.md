# SkyScan Flight Viewer - Flutter Test Suite

[![Flutter](https://img.shields.io/badge/Flutter-%5E3.8.1-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/github/license/yourusername/skyscan-flight-viewer)](../../LICENSE)
[![Test Status](https://img.shields.io/badge/tests-passing-brightgreen.svg)](#)
[![Coverage](https://img.shields.io/badge/coverage-85%25-yellow.svg)](#)

Comprehensive test suite for the SkyScan Flight Viewer Flutter application, ensuring UI reliability, state management correctness, and user experience quality.

## Table of Contents

- [Features](#features)
- [Test Structure](#test-structure)
- [Installation & Setup](#installation--setup)
- [Running Tests](#running-tests)
- [Usage Examples](#usage-examples)
- [Test Configuration](#test-configuration)
- [Tech Stack](#tech-stack)
- [Coverage Reports](#coverage-reports)
- [Continuous Integration](#continuous-integration)
- [Writing New Tests](#writing-new-tests)
- [Test Categories](#test-categories)
- [Widget Testing](#widget-testing)
- [Integration Testing](#integration-testing)
- [License](#license)

## Features

- 🧪 **Unit Testing**: Tests for individual components and providers
- 🖼️ **Widget Testing**: UI component rendering and interaction tests
- 🔗 **Integration Testing**: End-to-end user flow testing
- 📊 **Coverage Reporting**: Detailed code coverage analysis
- ⚡ **Fast Execution**: Optimized test execution times
- 🔄 **CI/CD Integration**: Automated testing in deployment pipelines
- 📈 **Test Reporting**: Detailed test results and reports
- 🎯 **Golden Testing**: Visual regression testing capabilities

## Test Structure

```
test/
├── unit/                 # Unit tests for individual components
│   └── providers/        # Provider state management tests
│       ├── flight_provider_test.dart
│       ├── theme_provider_test.dart
│       └── extra_service_provider_test.dart
├── widget/               # Widget rendering and interaction tests
│   ├── widget_test.dart
│   ├── test_theme_toggle.dart
│   └── test_tab_navigation.dart
├── integration/          # Integration tests for user flows
│   └── flight_search_flow_test.dart
├── fixtures/             # Test data and mock objects
│   └── mock_data.dart
├── helpers/              # Test helper functions and utilities
│   └── test_helpers.dart
├── goldens/              # Golden test images (visual regression)
│   └── screenshots/
└── README.md             # This file
```

## Installation & Setup

### Prerequisites

- Flutter SDK ^3.8.1
- Dart SDK ^3.8.1
- Flutter project dependencies installed

### Install Test Dependencies

Test dependencies are automatically included with Flutter. Ensure all packages are installed:

```bash
# Navigate to Flutter project directory
cd /path/to/skyscan/flight_viewer

# Install Flutter dependencies
flutter pub get
```

### Development Environment

```bash
# Verify Flutter installation
flutter doctor

# Check Flutter version
flutter --version
```

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run Unit Tests Only

```bash
flutter test test/unit/
```

### Run Widget Tests Only

```bash
flutter test test/widget/
```

### Run Integration Tests Only

```bash
flutter test test/integration/
```

### Run Tests with Verbose Output

```bash
flutter test --verbose
```

### Run Specific Test File

```bash
flutter test test/unit/providers/flight_provider_test.dart
```

### Run Tests Matching Pattern

```bash
flutter test --plain-name "FlightProvider"
```

## Usage Examples

### Basic Test Execution

```bash
# Run all tests with detailed output
flutter test --reporter=expanded

# Run tests and generate coverage report
flutter test --coverage

# Run tests with machine-readable output
flutter test --machine
```

### Selective Test Execution

```bash
# Run specific test file
flutter test test/widget/widget_test.dart

# Run specific test group
flutter test --plain-name "FlightProvider"

# Run tests in a directory
flutter test test/unit/providers/
```

### Coverage Analysis

```bash
# Generate coverage report
flutter test --coverage

# Generate HTML coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

## Test Configuration

### Flutter Test Configuration

Flutter tests use the built-in testing framework configuration. Custom configuration can be added to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```

### Environment Variables

Tests can use environment variables for configuration:

```bash
# Set test environment
export FLUTTER_TEST=true

# Set mock API base URL
export TEST_API_BASE_URL=http://localhost:8000
```

## Tech Stack

- **Test Framework**: flutter_test (built-in)
- **Integration Testing**: integration_test (built-in)
- **Mocking**: mockito
- **Coverage Tool**: flutter test --coverage
- **Golden Testing**: flutter_test golden testing
- **Test Runner**: flutter test command

### Key Dependencies

- `flutter_test`: Built-in Flutter testing framework
- `integration_test`: Built-in integration testing package
- `mockito`: Mocking framework for Dart
- `provider`: For testing state management
- `http`: For testing API interactions

## Coverage Reports

### Generate Coverage Report

```bash
# Generate lcov coverage report
flutter test --coverage

# Install lcov (Ubuntu/Debian)
sudo apt-get install lcov

# Install lcov (macOS)
brew install lcov

# Generate HTML report from lcov data
genhtml coverage/lcov.info -o coverage/html

# Open HTML report
open coverage/html/index.html
```

### Coverage Requirements

- **Unit Tests**: Minimum 80% coverage
- **Widget Tests**: Minimum 70% coverage for critical UI components
- **Integration Tests**: Minimum 85% coverage for user flows
- **Overall**: Minimum 75% coverage across all tests

## Continuous Integration

### GitHub Actions Workflow

Example workflow in `.github/workflows/flutter_test.yml`:

```yaml
name: Flutter Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.10.0'
    - name: Install dependencies
      run: flutter pub get
    - name: Run tests
      run: flutter test --coverage
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
```

## Writing New Tests

### Test File Naming Convention

- Unit tests: `[component]_test.dart`
- Widget tests: `test_[feature].dart`
- Integration tests: `[feature]_flow_test.dart`

### Basic Unit Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flight_viewer/providers/flight_provider.dart';

void main() {
  group('FlightProvider', () {
    late FlightProvider flightProvider;

    setUp(() {
      flightProvider = FlightProvider();
    });

    test('initial state is correct', () {
      expect(flightProvider.flights, isEmpty);
      expect(flightProvider.isLoading, false);
      expect(flightProvider.error, isNull);
    });
  });
}
```

### Basic Widget Test Structure

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flight_viewer/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());
    
    // Verify no exceptions
    expect(tester.takeException(), isNull);
  });
}
```

## Test Categories

### Unit Tests

Located in `test/unit/`:
- Test individual providers and business logic
- Mock external dependencies
- Focus on state management validation
- Fast execution time

### Widget Tests

Located in `test/widget/`:
- Test UI component rendering
- Verify widget interactions
- Test user interface behavior
- Include layout and styling validation

### Integration Tests

Located in `test/integration/`:
- Test complete user workflows
- Validate navigation between screens
- Test end-to-end functionality
- Include data flow validation

## Widget Testing

### Testing Widgets

```dart
testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  // Build our app and trigger a frame
  await tester.pumpWidget(const MyApp());

  // Verify that our counter starts at 0
  expect(find.text('0'), findsOneWidget);
  expect(find.text('1'), findsNothing);

  // Tap the '+' icon and trigger a frame
  await tester.tap(find.byIcon(Icons.add));
  await tester.pump();

  // Verify that our counter has incremented
  expect(find.text('0'), findsNothing);
  expect(find.text('1'), findsOneWidget);
});
```

### Finding Widgets

```dart
// Find by text
final textFinder = find.text('Search Flights');

// Find by icon
final iconFinder = find.byIcon(Icons.search);

// Find by widget type
final widgetFinder = find.byType(ElevatedButton);

// Find by key
final keyFinder = find.byKey(const ValueKey('search-button'));
```

## Integration Testing

### Integration Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flight_viewer/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flight Search Flow', () {
    testWidgets('App launches and displays main screen', 
      (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Verify the main screen is displayed
      expect(find.text('SkyScan'), findsOneWidget);
    });
  });
}
```

### Running Integration Tests

```bash
# Run integration tests
flutter test integration_test/

# Run specific integration test
flutter test integration_test/app_test.dart
```

## License

This test suite is part of the SkyScan Flight Viewer project, licensed under the MIT License. See the [LICENSE](../../LICENSE) file for details.
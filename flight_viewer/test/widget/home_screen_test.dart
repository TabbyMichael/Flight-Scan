import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flight_viewer/screens/home_screen.dart';
import 'package:flight_viewer/providers/flight_provider.dart';
import 'package:flight_viewer/providers/theme_provider.dart';
import 'package:flight_viewer/models/flight.dart';
import 'package:provider/provider.dart';

class MockFlightProvider extends FlightProvider {
  @override
  bool get isLoading => true;
  
  @override
  String? get error => null;
  
  @override
  List<Flight> get flights => [];
}

void main() {
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
  
  testWidgets('HomeScreen has theme toggle button', (WidgetTester tester) async {
    // Build the HomeScreen widget
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
    
    // Verify that the theme toggle button is present
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });
  
  testWidgets('HomeScreen has filter button', (WidgetTester tester) async {
    // Build the HomeScreen widget
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
    
    // Verify that the filter button is present
    expect(find.byIcon(Icons.filter_alt), findsOneWidget);
  });
}
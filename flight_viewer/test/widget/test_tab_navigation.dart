import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flight_viewer/providers/theme_provider.dart';
import 'package:flight_viewer/providers/flight_provider.dart';
import 'package:flight_viewer/screens/main_tab_screen.dart';

void main() {
  testWidgets('Tab navigation switches between screens', 
    (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FlightProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          home: MainTabScreen(),
        ),
      ),
    );

    // Verify we start on the Search Flights tab
    expect(find.text('Search Flights'), findsWidgets);
    expect(find.text('My Bookings'), findsWidgets);
    
    // Find the My Bookings tab and tap it
    final myBookingsTab = find.text('My Bookings');
    expect(myBookingsTab, findsOneWidget);
    await tester.tap(myBookingsTab);
    await tester.pumpAndSettle();

    // Find the Search Flights tab and tap it
    final searchFlightsTab = find.text('Search Flights');
    expect(searchFlightsTab, findsOneWidget);
    await tester.tap(searchFlightsTab);
    await tester.pumpAndSettle();
  });
}
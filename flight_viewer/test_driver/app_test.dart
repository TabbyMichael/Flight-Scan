import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flight_viewer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('App starts successfully', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Verify that the app starts without errors
    // This is a simple test - in a real app we would have more specific assertions
    expect(find.byType(app.MyApp), findsOneWidget);
  });
}
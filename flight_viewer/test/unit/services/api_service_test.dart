import 'package:flutter_test/flutter_test.dart';
import 'package:flight_viewer/services/api_service.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;
    
    setUp(() {
      apiService = ApiService();
    });
    
    test('baseUrl is correctly set', () {
      // Verify the base URL is set correctly for Android emulator
      expect(ApiService.baseUrl, 'http://10.0.2.2:8000');
    });
    
    test('fetchFlights method exists', () {
      // Verify the method exists (we can't test actual HTTP calls without mocking)
      expect(apiService.fetchFlights, isA<Future Function()>());
    });
    
    test('fetchAirlines method exists', () {
      // Verify the method exists
      expect(apiService.fetchAirlines, isA<Future Function()>());
    });
    
    test('searchFlights method exists', () {
      // Verify the method exists
      expect(apiService.searchFlights, isA<Future Function({double? maxPrice, int? maxStops, List<String>? airlineCodes})>());
    });
    
    test('fetchServices method exists', () {
      // Verify the method exists
      expect(apiService.fetchServices, isA<Future Function()>());
    });
  });
}
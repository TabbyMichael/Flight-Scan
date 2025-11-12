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

    test('getUniqueAirlines returns empty list when no flights', () {
      final airlines = flightProvider.getUniqueAirlines();
      expect(airlines, isEmpty);
    });

    test('getAirports returns empty list when no flights', () {
      final airports = flightProvider.getAirports();
      expect(airports, isEmpty);
    });

    test('getPriceRange returns default values when no flights', () {
      final priceRange = flightProvider.getPriceRange();
      expect(priceRange['min'], 0);
      expect(priceRange['max'], 1000);
    });
  });
}
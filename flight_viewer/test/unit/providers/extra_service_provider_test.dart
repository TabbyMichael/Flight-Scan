import 'package:flutter_test/flutter_test.dart';
import 'package:flight_viewer/providers/extra_service_provider.dart';

void main() {
  group('ExtraServiceProvider', () {
    late ExtraServiceProvider provider;

    setUp(() {
      provider = ExtraServiceProvider();
    });

    test('initial state is correct', () {
      expect(provider.services, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
      expect(provider.totalCost, 0.0);
    });

    test('quantityFor returns 0 for non-existent service', () {
      expect(provider.quantityFor('non-existent'), 0);
    });

    test('selections returns empty map initially', () {
      expect(provider.selections, isEmpty);
    });
  });
}
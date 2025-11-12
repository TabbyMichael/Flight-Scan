import 'package:flutter/foundation.dart';
import '../models/flight.dart';
import '../services/api_service.dart';
import '../utils/error_handler.dart';

class FlightProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Flight> _flights = [];
  List<Flight> _allFlights = [];
  bool _isLoading = false;
  String? _error;

  List<Flight> get flights => _flights;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFlights() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allFlights = await _apiService.fetchFlights();
      _flights = List.from(_allFlights);
      _error = null;
    } catch (e) {
      _error = ErrorHandler.formatErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Apply client-side filters without hitting backend.
  void applyFilters({
    double? maxPrice,
    int? maxStops,
    Set<String>? airlineCodes,
  }) {
    _flights = _allFlights.where((f) {
      if (maxPrice != null && f.price > maxPrice) return false;
      if (maxStops != null && f.stops > maxStops) return false;
      if (airlineCodes != null && airlineCodes.isNotEmpty && !airlineCodes.contains(f.airlineCode)) {
        return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  // Still available if we later want server-side filtering
  Future<void> searchFlights({
    double? maxPrice,
    int? maxStops,
    List<String>? airlineCodes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _flights = await _apiService.searchFlights(
        maxPrice: maxPrice,
        maxStops: maxStops,
        airlineCodes: airlineCodes,
      );
      _error = null;
    } catch (e) {
      _error = ErrorHandler.formatErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to get unique airlines from flights
  List<String> getUniqueAirlines() {
    final airlines = _flights.map((f) => f.airlineCode).toSet().toList();
    return airlines;
  }

  // Helper method to get minimum and maximum prices
  // unique airports for dropdowns
  List<String> getAirports() {
    final set = <String>{};
    for (final f in _allFlights) {
      set.add(f.departureAirport);
      set.add(f.arrivalAirport);
    }
    final list = set.toList()..sort();
    return list;
  }

  Map<String, double> getPriceRange() {
    if (_flights.isEmpty) return {'min': 0, 'max': 1000};
    
    final prices = _flights.map((f) => f.price).toList()..sort();
    return {
      'min': prices.first,
      'max': prices.last,
    };
  }
}
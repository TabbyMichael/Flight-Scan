import 'package:flutter/foundation.dart';
import '../models/flight.dart';
import '../services/api_service.dart';
import '../services/haptics_service.dart';

class FlightProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final HapticsService _hapticsService = HapticsService();
  List<Flight> _flights = [];
  List<Flight> _allFlights = [];
  bool _isLoading = false;
  String? _error;
  
  // Filter state
  double? _currentMaxPrice;
  int? _currentMaxStops;
  Set<String> _selectedAirlines = {};
  
  // Getters for filter state
  double? get currentMaxPrice => _currentMaxPrice;
  int? get currentMaxStops => _currentMaxStops;
  Set<String> get selectedAirlines => _selectedAirlines;

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
      _hapticsService.success();
    } catch (e) {
      _error = e.toString();
      _hapticsService.error();
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
    // Update filter state
    _currentMaxPrice = maxPrice;
    _currentMaxStops = maxStops;
    _selectedAirlines = airlineCodes ?? {};
    
    _flights = _allFlights.where((f) {
      if (maxPrice != null && f.price > maxPrice) return false;
      if (maxStops != null && f.stops > maxStops) return false;
      if (airlineCodes != null && airlineCodes.isNotEmpty && !airlineCodes.contains(f.airlineCode)) {
        return false;
      }
      return true;
    }).toList();
    
    _hapticsService.lightImpact();
    notifyListeners();
  }

  // Server-side search with all parameters
  Future<void> searchFlights({
    String? origin,
    String? destination,
    DateTime? departureDate,
    double? maxPrice,
    int? maxStops,
    List<String>? airlineCodes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _flights = await _apiService.searchFlights(
        origin: origin,
        destination: destination,
        departureDate: departureDate,
        maxPrice: maxPrice,
        maxStops: maxStops,
        airlineCodes: airlineCodes,
      );
      _error = null;
      _hapticsService.success();
    } catch (e) {
      _error = e.toString();
      _hapticsService.error();
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
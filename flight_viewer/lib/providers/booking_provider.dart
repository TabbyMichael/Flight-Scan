import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import '../services/haptics_service.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final HapticsService _hapticsService = HapticsService();
  List<Booking> _bookings = [];
  bool _loading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> fetchBookings(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _bookings = await _api.fetchUserBookings(email);
      _hapticsService.success();
    } catch (e) {
      _error = e.toString();
      _hapticsService.error();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Booking> createBooking({
    required String flightId,
    required String firstName,
    required String lastName,
    required String passport,
    required String email,
    required Map<String, int> extras,
    required double totalCost,
  }) async {
    try {
      final booking = await _api.createBooking(
        flightId: flightId,
        firstName: firstName,
        lastName: lastName,
        passport: passport,
        email: email,
        extras: extras,
        totalCost: totalCost,
      );
      
      // Add the new booking to our list
      _bookings.add(booking);
      notifyListeners();
      
      _hapticsService.success();
      return booking;
    } catch (e) {
      _error = e.toString();
      _hapticsService.error();
      rethrow;
    }
  }
}
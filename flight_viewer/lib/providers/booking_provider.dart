import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../utils/error_handler.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get bookingCount => _bookings.length;

  Future<void> fetchBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _apiService.fetchUserBookings();
      _error = null;
    } catch (e) {
      _error = ErrorHandler.formatErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearBookings() {
    _bookings = [];
    notifyListeners();
  }
}
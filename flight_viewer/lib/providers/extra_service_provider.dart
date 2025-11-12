import 'package:flutter/foundation.dart';
import '../models/extra_service.dart';
import '../services/api_service.dart';
import '../utils/error_handler.dart';

class ExtraServiceProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  List<ExtraService> _services = [];
  final Map<String, int> _selectedQty = {};
  bool _loading = false;
  String? _error;

  List<ExtraService> get services => _services;
  bool get isLoading => _loading;
  String? get error => _error;

  double get totalCost {
    double total = 0;
    for (final svc in _services) {
      final qty = _selectedQty[svc.id] ?? (svc.isMandatory ? svc.minQuantity : 0);
      total += qty * svc.price;
    }
    return total;
  }

  int quantityFor(String id) => _selectedQty[id] ?? 0;

  Future<void> fetchServices() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _services = await _api.fetchServices();
      // initialize mandatory quantities
      for (final s in _services) {
        if (s.isMandatory) _selectedQty[s.id] = s.minQuantity;
      }
    } catch (e) {
      _error = ErrorHandler.formatErrorMessage(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setQuantity(String id, int qty) {
    _selectedQty[id] = qty;
    notifyListeners();
  }

  Map<String, int> get selections => Map.unmodifiable(_selectedQty);
}
import 'package:flutter/foundation.dart';
import '../models/extra_service.dart';
import '../services/api_service.dart';

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

  int quantityFor(String id) {
    // For mandatory services, ensure minimum quantity is selected by default
    final service = _services.firstWhereOrNull((s) => s.id == id);
    if (service != null && service.isMandatory) {
      return _selectedQty[id] ?? service.minQuantity;
    }
    return _selectedQty[id] ?? 0;
  }

  Future<void> fetchServices() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _services = await _api.fetchServices();
      // Initialize mandatory quantities
      for (final s in _services) {
        if (s.isMandatory) {
          _selectedQty[s.id] = s.minQuantity;
        }
      }
    } catch (e) {
      _error = e.toString();
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
  
  // Get service by ID for displaying details in review screen
  ExtraService? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get selected services with full details
  List<Map<String, dynamic>> getSelectedServicesWithDetails() {
    final List<Map<String, dynamic>> selected = [];
    _selectedQty.forEach((id, qty) {
      if (qty > 0) {
        final service = getServiceById(id);
        if (service != null) {
          selected.add({
            'service': service,
            'quantity': qty,
            'totalPrice': service.price * qty,
          });
        }
      }
    });
    return selected;
  }
}

// Extension to add firstWhereOrNull method to List
extension FirstWhereOrNull<E> on List<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
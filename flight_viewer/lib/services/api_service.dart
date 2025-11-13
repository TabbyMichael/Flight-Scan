import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight.dart';
import '../models/airline.dart';
import '../models/extra_service.dart';
import '../models/booking.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // For Android emulator
  // static const String baseUrl = 'http://localhost:8000'; // For web
  // static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000'; // For physical device

  Future<List<Flight>> fetchFlights() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/flights'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> flightsJson = data['flights'] ?? [];
        return flightsJson.map((json) => Flight.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load flights: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch flights: $e');
    }
  }

  Future<List<Airline>> fetchAirlines() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/airlines'));
      
      if (response.statusCode == 200) {
        final List<dynamic> airlinesJson = json.decode(response.body);
        return airlinesJson.map((json) => Airline.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load airlines: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch airlines: $e');
    }
  }

  Future<List<Flight>> searchFlights({
    String? origin,
    String? destination,
    DateTime? departureDate,
    double? maxPrice,
    int? maxStops,
    List<String>? airlineCodes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/flights/search'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'origin': origin,
          'destination': destination,
          'departure_date': departureDate?.toIso8601String().split('T').first,
          'max_price': maxPrice,
          'max_stops': maxStops,
          'airline_codes': airlineCodes,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> flightsJson = data['flights'] ?? [];
        return flightsJson.map((json) => Flight.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search flights: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search flights: $e');
    }
  }

  Future<List<ExtraService>> fetchServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/services'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
        // Process the complex JSON structure to extract services
        final List<ExtraService> services = [];
        
        // Extract from DynamicBaggage
        final baggageServices = _extractServicesFromCategory(
          decoded, 
          'DynamicBaggage', 
          'Baggage'
        );
        services.addAll(baggageServices);
        
        // Extract from DynamicMeal
        final mealServices = _extractServicesFromCategory(
          decoded, 
          'DynamicMeal', 
          'Meals'
        );
        services.addAll(mealServices);
        
        // Extract from DynamicSeat
        final seatServices = _extractServicesFromCategory(
          decoded, 
          'DynamicSeat', 
          'Seats'
        );
        services.addAll(seatServices);
        
        return services;
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }
  
  List<ExtraService> _extractServicesFromCategory(
    Map<String, dynamic> json, 
    String categoryName, 
    String displayCategory
  ) {
    final List<ExtraService> services = [];
    
    try {
      final dynamicBaggage = json['ExtraServicesResponse']?['ExtraServicesResult']?['ExtraServicesData']?[categoryName];
      if (dynamicBaggage != null && dynamicBaggage is List) {
        for (final baggageItem in dynamicBaggage) {
          if (baggageItem is Map<String, dynamic>) {
            final servicesList = baggageItem['Services'];
            if (servicesList != null && servicesList is List) {
              for (final serviceGroup in servicesList) {
                if (serviceGroup is List) {
                  for (final service in serviceGroup) {
                    if (service is Map<String, dynamic>) {
                      services.add(ExtraService.fromJson({
                        'id': service['ServiceId']?.toString() ?? '',
                        'name': _generateServiceName(service, displayCategory),
                        'description': service['Description']?.toString() ?? '',
                        'price': double.tryParse(service['ServiceCost']?['Amount']?.toString() ?? '0') ?? 0,
                        'minQuantity': service['MinimumQuantity'] ?? 0,
                        'maxQuantity': service['MaximumQuantity'] ?? 5,
                        'isMandatory': service['IsMandatory'] ?? false,
                      }));
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      // Handle any parsing errors gracefully
      print('Error parsing $categoryName services: $e');
    }
    
    return services;
  }
  
  String _generateServiceName(Map<String, dynamic> service, String category) {
    final description = service['Description']?.toString() ?? '';
    if (description.isNotEmpty) {
      return description;
    }
    
    // Generate a name based on category and weight/quantity
    switch (category) {
      case 'Baggage':
        return 'Baggage Service';
      case 'Meals':
        return 'Meal Service';
      case 'Seats':
        return 'Seat Selection';
      default:
        return 'Extra Service';
    }
  }
  
  // Add method to create a booking
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
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'flight_id': flightId,
          'passenger': {
            'first_name': firstName,
            'last_name': lastName,
            'passport': passport,
            'email': email,
          },
          'extras': extras,
          'total_price': totalCost,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return Booking.fromJson(responseData);
      } else {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }
  
  // Add method to fetch user bookings
  Future<List<Booking>> fetchUserBookings(String email) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bookings?email=$email'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }
}
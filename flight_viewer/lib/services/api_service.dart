import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight.dart';
import '../models/airline.dart';
import '../models/extra_service.dart';
import '../models/booking.dart';
import 'haptics_service.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000'; // For iOS simulator and local development
  // static const String baseUrl = 'http://10.0.2.2:8000'; // For Android emulator
  // static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000'; // For physical device
  
  final HapticsService _hapticsService = HapticsService();

  Future<List<Flight>> fetchFlights() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/flights'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> flightsJson = data['flights'] ?? [];
        return flightsJson.map((json) => Flight.fromJson(json)).toList();
      } else {
        _hapticsService.error();
        throw Exception('Failed to load flights: ${response.statusCode}');
      }
    } catch (e) {
      _hapticsService.error();
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
        _hapticsService.error();
        throw Exception('Failed to load airlines: ${response.statusCode}');
      }
    } catch (e) {
      _hapticsService.error();
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
        _hapticsService.error();
        throw Exception('Failed to search flights: ${response.statusCode}');
      }
    } catch (e) {
      _hapticsService.error();
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
        _hapticsService.error();
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      _hapticsService.error();
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
      _hapticsService.error();
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
      print('Creating booking with flight ID: $flightId');
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
          'currency': 'USD',
        }),
      );
      
      print('Booking response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _hapticsService.success();
        
        // Transform the response to match our Booking model
        final bookingData = {
          'id': responseData['id'] ?? '',
          'flightId': responseData['flight_id'] ?? '',
          'firstName': responseData['passenger']?['first_name'] ?? '',
          'lastName': responseData['passenger']?['last_name'] ?? '',
          'passport': responseData['passenger']?['passport'] ?? '',
          'email': responseData['passenger_email'] ?? responseData['passenger']?['email'] ?? '',
          'extras': responseData['extras'] ?? {},
          'totalCost': (responseData['total_price'] ?? 0.0).toDouble(),
          'createdAt': responseData['created_at'] ?? DateTime.now().toIso8601String(),
        };
        
        return Booking.fromJson(bookingData);
      } else {
        final errorData = json.decode(response.body);
        _hapticsService.error();
        throw Exception('Failed to create booking: ${errorData['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      _hapticsService.error();
      throw Exception('Failed to create booking: $e');
    }
  }
  
  // Fetch all bookings for a specific user by email
  Future<List<Booking>> fetchUserBookings(String email) async {
    try {
      print('Fetching bookings for email: $email');
      final response = await http.get(
        Uri.parse('$baseUrl/bookings').replace(
          queryParameters: {'email': email},
        ),
      );
      
      print('Bookings response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final List<dynamic> bookingsList = responseBody is List ? responseBody : [];
        
        return bookingsList.map((json) {
          // Transform each booking to match our model
          return Booking.fromJson({
            'id': json['id'] ?? '',
            'flight_id': json['flight_id'] ?? '',
            'first_name': json['passenger']?['first_name'] ?? '',
            'last_name': json['passenger']?['last_name'] ?? '',
            'passport': json['passenger']?['passport'] ?? '',
            'email': json['passenger_email'] ?? json['passenger']?['email'] ?? '',
            'extras': json['extras'] ?? {},
            'total_price': json['total_price'] ?? 0.0,
            'created_at': json['created_at'] ?? DateTime.now().toIso8601String(),
          });
        }).toList();
      } else {
        _hapticsService.error();
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      _hapticsService.error();
      throw Exception('Failed to fetch bookings: $e');
    }
  }
}
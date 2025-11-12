import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flight.dart';
import '../models/airline.dart';
import '../models/extra_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // For Android emulator
  // static const String baseUrl = 'http://localhost:8000'; // For web
  // static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000'; // For physical device

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null ? {'Authorization': 'Bearer $token'} : {};
  }

  Future<List<Flight>> fetchFlights() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/flights'), headers: headers);
      
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
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/airlines'), headers: headers);
      
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
    double? maxPrice,
    int? maxStops,
    List<String>? airlineCodes,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/flights/search'),
        headers: {'Content-Type': 'application/json', ...headers},
        body: json.encode({
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
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/services'), headers: headers);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> jsonList = decoded is List ? decoded : (decoded['services'] ?? []);
        return jsonList.map((e) => ExtraService.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }
  
  Future<Map<String, dynamic>> createBooking({
    required String flightId,
    required String firstName,
    required String lastName,
    required String email,
    required String passport,
    required Map<String, int> extras,
    required double totalPrice,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {'Content-Type': 'application/json', ...headers},
        body: json.encode({
          'flight_id': flightId,
          'passenger': {
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'passport': passport,
          },
          'extras': extras,
          'total_price': totalPrice,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create booking: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> fetchUserBookings() async {
    try {
      final headers = await _getAuthHeaders();
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      
      if (userEmail == null) {
        throw Exception('User not logged in');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/bookings?email=$userEmail'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> bookingsJson = json.decode(response.body);
        return bookingsJson.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Save token and user info to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['access_token']);
        await prefs.setString('user_id', data['user']['id']);
        await prefs.setString('user_email', data['user']['email']);
        await prefs.setString('user_first_name', data['user']['first_name']);
        await prefs.setString('user_last_name', data['user']['last_name']);
        
        return data;
      } else {
        throw Exception('Login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Registration failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_first_name');
    await prefs.remove('user_last_name');
  }
}
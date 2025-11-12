import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight.dart';
import '../models/airline.dart';
import '../models/extra_service.dart';

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
    double? maxPrice,
    int? maxStops,
    List<String>? airlineCodes,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (maxStops != null) queryParams['max_stops'] = maxStops;
      
      final response = await http.post(
        Uri.parse('$baseUrl/flights/search'),
        headers: {'Content-Type': 'application/json'},
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
      final response = await http.get(Uri.parse('$baseUrl/services'));
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
}
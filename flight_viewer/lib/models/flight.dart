class Flight {
  final String id;
  final String airlineCode;
  final String airlineName;
  final String flightNumber;
  final String departureAirport;
  final String arrivalAirport;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final int duration; // in minutes
  final double price;
  final int stops;
  final String currency;
  final List<Segment> segments;
  final String cabinClass;

  Flight({
    required this.id,
    required this.airlineCode,
    required this.airlineName,
    required this.flightNumber,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.stops,
    required this.currency,
    required this.segments,
    required this.cabinClass,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    // Parse departure time
    DateTime departureTime;
    try {
      departureTime = DateTime.parse(json['departureTime']);
    } catch (e) {
      departureTime = DateTime.now();
    }
    
    // Parse arrival time
    DateTime arrivalTime;
    try {
      arrivalTime = DateTime.parse(json['arrivalTime']);
    } catch (e) {
      arrivalTime = DateTime.now();
    }
    
    return Flight(
      id: json['id'] ?? '',
      airlineCode: json['airlineCode'] ?? '',
      airlineName: json['airlineName'] ?? '',
      flightNumber: json['flightNumber'] ?? '',
      departureAirport: json['departureAirport'] ?? '',
      arrivalAirport: json['arrivalAirport'] ?? '',
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      duration: json['duration'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      stops: json['stops'] ?? 0,
      currency: json['currency'] ?? 'USD',
      cabinClass: json['cabinClass'] ?? '',
      segments: (json['segments'] as List<dynamic>?)
              ?.map((segment) => Segment.fromJson(segment))
              .toList() ??
          [],
    );
  }
}

class Segment {
  final String departureAirport;
  final String arrivalAirport;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String flightNumber;
  final String airlineCode;
  final String airlineName;
  final int duration; // in minutes

  Segment({
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.flightNumber,
    required this.airlineCode,
    required this.airlineName,
    required this.duration,
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    // Parse departure time
    DateTime departureTime;
    try {
      departureTime = DateTime.parse(json['departureTime']);
    } catch (e) {
      departureTime = DateTime.now();
    }
    
    // Parse arrival time
    DateTime arrivalTime;
    try {
      arrivalTime = DateTime.parse(json['arrivalTime']);
    } catch (e) {
      arrivalTime = DateTime.now();
    }
    
    return Segment(
      departureAirport: json['departureAirport'] ?? '',
      arrivalAirport: json['arrivalAirport'] ?? '',
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      flightNumber: json['flightNumber'] ?? '',
      airlineCode: json['airlineCode'] ?? '',
      airlineName: json['airlineName'] ?? '',
      duration: json['duration'] ?? 0,
    );
  }
}
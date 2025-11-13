class Booking {
  final String id;
  final String flightId;
  final Map<String, int> extras;
  final String firstName;
  final String lastName;
  final String passport;
  final String email;
  final double totalCost;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.flightId,
    required this.extras,
    required this.firstName,
    required this.lastName,
    required this.passport,
    required this.email,
    required this.totalCost,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      return Booking(
        id: json['id']?.toString() ?? '',
        flightId: json['flight_id']?.toString() ?? json['flightId']?.toString() ?? '',
        extras: json['extras'] != null 
            ? Map<String, int>.from(
                Map<dynamic, dynamic>.from(json['extras']).map(
                  (key, value) => MapEntry(key.toString(), value is int ? value : int.tryParse(value.toString()) ?? 0),
                ),
              )
            : <String, int>{},
        firstName: json['first_name']?.toString() ?? json['firstName']?.toString() ?? '',
        lastName: json['last_name']?.toString() ?? json['lastName']?.toString() ?? '',
        passport: json['passport']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        totalCost: (json['total_price'] ?? json['totalCost'])?.toDouble() ?? 0.0,
        createdAt: json['created_at'] != null 
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
                : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing booking: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'flightId': flightId,
        'extras': extras,
        'firstName': firstName,
        'lastName': lastName,
        'passport': passport,
        'email': email,
        'totalCost': totalCost,
        'createdAt': createdAt.toIso8601String(),
      };
}

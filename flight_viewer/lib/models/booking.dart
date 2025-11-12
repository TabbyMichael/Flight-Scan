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
    // Handle the nested passenger structure from backend
    final passenger = json['passenger'] as Map<String, dynamic>? ?? {};
    
    return Booking(
      id: json['id'] as String? ?? '',
      flightId: json['flight_id'] as String? ?? '',
      extras: Map<String, int>.from(json['extras'] as Map? ?? {}),
      firstName: passenger['first_name'] as String? ?? '',
      lastName: passenger['last_name'] as String? ?? '',
      passport: passenger['passport'] as String? ?? '',
      email: passenger['email'] as String? ?? '',
      totalCost: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'flight_id': flightId,
        'extras': extras,
        'passenger': {
          'first_name': firstName,
          'last_name': lastName,
          'passport': passport,
          'email': email,
        },
        'total_price': totalCost,
        'created_at': createdAt.toIso8601String(),
      };
}
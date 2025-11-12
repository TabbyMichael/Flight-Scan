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

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'],
        flightId: json['flightId'],
        extras: Map<String, int>.from(json['extras']),
        firstName: json['firstName'],
        lastName: json['lastName'],
        passport: json['passport'],
        email: json['email'],
        totalCost: (json['totalCost'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
      );

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

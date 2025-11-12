class Airline {
  final String code;
  final String name;
  final String logoUrl;

  Airline({
    required this.code,
    required this.name,
    required this.logoUrl,
  });

  factory Airline.fromJson(Map<String, dynamic> json) {
    return Airline(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
    );
  }
}

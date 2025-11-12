class ExtraService {
  final String id;
  final String name;
  final String description;
  final double price;
  final int minQuantity;
  final int maxQuantity;
  final bool isMandatory;

  ExtraService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.minQuantity,
    required this.maxQuantity,
    required this.isMandatory,
  });

  factory ExtraService.fromJson(Map<String, dynamic> json) {
    return ExtraService(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      minQuantity: json['minQuantity'] ?? 0,
      maxQuantity: json['maxQuantity'] ?? 5,
      isMandatory: json['isMandatory'] ?? false,
    );
  }
}

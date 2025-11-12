class ExtraService {
  final String id;
  final String name;
  final String description;
  final double price;
  final int minQuantity;
  final int maxQuantity;
  final bool isMandatory;
  final String category;

  ExtraService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.minQuantity,
    required this.maxQuantity,
    required this.isMandatory,
    required this.category,
  });

  factory ExtraService.fromJson(Map<String, dynamic> json) {
    // Determine category based on service name or description
    String category = 'Other';
    final nameLower = (json['name'] ?? '').toString().toLowerCase();
    final descLower = (json['description'] ?? '').toString().toLowerCase();
    
    if (nameLower.contains('bag') || nameLower.contains('luggage') || 
        descLower.contains('bag') || descLower.contains('luggage')) {
      category = 'Baggage';
    } else if (nameLower.contains('meal') || nameLower.contains('food') || 
               descLower.contains('meal') || descLower.contains('food')) {
      category = 'Meals';
    } else if (nameLower.contains('seat') || nameLower.contains('legroom') || 
               descLower.contains('seat') || descLower.contains('legroom')) {
      category = 'Seats';
    }

    return ExtraService(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      minQuantity: json['minQuantity'] ?? 0,
      maxQuantity: json['maxQuantity'] ?? 5,
      isMandatory: json['isMandatory'] ?? false,
      category: json['category'] ?? category,
    );
  }
}
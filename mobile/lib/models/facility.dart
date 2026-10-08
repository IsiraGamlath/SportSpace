class Facility {
  const Facility({
    required this.name,
    required this.sport,
    required this.price,
    required this.availableSlots,
  });

  final String name;
  final String sport;
  final int price;
  final int availableSlots;

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      name: json['name']?.toString() ?? 'Unnamed facility',
      sport: json['sport']?.toString() ?? 'Sports',
      price: (json['price'] as num?)?.round() ?? 0,
      availableSlots: (json['availableSlots'] as num?)?.toInt() ?? 0,
    );
  }
}

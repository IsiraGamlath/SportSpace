class Facility {
  const Facility({
    required this.name,
    required this.sport,
    required this.price,
    required this.availableSlots,
    this.photoUrl,
  });

  final String name;
  final String sport;
  final int price;
  final int availableSlots;
  final String? photoUrl;

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      name: json['name']?.toString() ?? 'Unnamed facility',
      sport: json['sport']?.toString() ?? (json['type']?.toString() ?? 'Sports'),
      price: (json['price'] as num?)?.round() ?? (json['hourlyRate'] as num?)?.round() ?? 0,
      availableSlots: (json['availableSlots'] as num?)?.toInt() ?? 10,
      photoUrl: json['photoUrl']?.toString() ?? (json['photos'] != null && (json['photos'] as List).isNotEmpty ? json['photos'][0].toString() : null),
    );
  }
}

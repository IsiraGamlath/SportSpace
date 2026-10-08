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
      sport: json['sport']?.toString() ?? 'Sports',
      price: (json['price'] as num?)?.round() ?? 0,
      availableSlots: (json['availableSlots'] as num?)?.toInt() ?? 0,
      photoUrl: _firstPhoto(json),
    );
  }

  static String? _firstPhoto(Map<String, dynamic> json) {
    final photos = json['photos'];
    final firstPhoto = photos is List && photos.isNotEmpty
        ? photos.first?.toString().trim()
        : null;
    final photoUrl = json['photoUrl']?.toString().trim();
    final value = (firstPhoto?.isNotEmpty == true ? firstPhoto : photoUrl);
    if (value == null || value.isEmpty) return null;
    return value;
  }
}

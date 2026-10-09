import 'package:flutter/material.dart';
import '../views/tertiary/facility_details_view.dart';

class FacilityItem {
  final String id;
  final String name;
  final String imageUrl;
  final String status;
  final String cityLocation;
  final String address;
  final String phone;
  final String email;
  final String openingHours;
  final List<String> availableSports;
  final List<FacilityAmenity> amenities;
  final List<String> upcomingEvents;
  final String accessibilityNote;
  final String scheduleTimeRange;
  final String scheduleEventTitle;
  final double rating;
  final String distance;
  final String description;

  const FacilityItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.status = 'Open',
    required this.cityLocation,
    required this.address,
    required this.phone,
    required this.email,
    required this.openingHours,
    required this.availableSports,
    required this.amenities,
    required this.upcomingEvents,
    required this.accessibilityNote,
    this.scheduleTimeRange = '',
    this.scheduleEventTitle = '',
    this.rating = 4.8,
    this.distance = '1.5 km',
    this.description =
        'A premier, fully equipped multi-sport facility offering professional-standard courts, well-maintained locker rooms, dedicated coaching programs, and accessible amenities for all community members.',
  });

  factory FacilityItem.fromBackendJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Facility';
    final location = json['location'] as String? ?? 'Colombo';
    final photo = json['photoUrl'] as String? ??
        (json['photos'] is List && (json['photos'] as List).isNotEmpty
            ? json['photos'][0] as String
            : 'assets/images/badminton.jpg');
    final sports = (json['availableSports'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        ['Badminton'];
    final amenitiesList = (json['amenities'] as List?)
            ?.map((e) => FacilityAmenity(
                  icon: Icons.check_circle_outline,
                  label: e.toString(),
                ))
            .toList() ??
        const [
          FacilityAmenity(icon: Icons.local_parking_outlined, label: 'Parking'),
          FacilityAmenity(icon: Icons.checkroom_outlined, label: 'Changing rooms'),
        ];
    final access = (json['accessibility'] as List?)?.join(', ') ??
        'Wheelchair Accessible';

    return FacilityItem(
      id: json['id'] as String? ??
          json['_id'] as String? ??
          name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      imageUrl: photo,
      status: json['status'] == 'active' ? 'Open' : (json['status'] ?? 'Open'),
      cityLocation: location,
      address: location,
      phone: json['contactNumber'] as String? ?? '+94 11 269 1111',
      email: 'info@sportspace.lk',
      openingHours: json['openTime'] as String? ?? '06:00 AM – 10:00 PM',
      availableSports: sports,
      amenities: amenitiesList,
      upcomingEvents: const ['Community Sports Event'],
      accessibilityNote: access,
      description: json['description'] as String? ??
          'Premier sports facility with professional courts and modern amenities.',
    );
  }
}

const List<FacilityItem> kMockFacilities = [
  FacilityItem(
    id: 'colombo_sports_hub',
    name: 'Colombo Sports Hub',
    imageUrl: 'assets/images/badminton.jpg',
    status: 'Open',
    cityLocation: 'Colombo 07, Sri Lanka',
    address: '123 Independence Square, Colombo 07',
    phone: '+94 11 234 5678',
    email: 'info@colombosportshub.lk',
    openingHours: '6:00 AM – 10:00 PM',
    availableSports: ['Badminton', 'Tennis', 'Squash', 'Swimming'],
    rating: 4.8,
    distance: '1.2 km away',
    scheduleTimeRange: '9:00 AM – 5:00 PM',
    scheduleEventTitle: 'Colombo Community Badminton Open',
    upcomingEvents: [
      'Colombo Community Badminton Open',
      'Junior Badminton Clinic',
      'Weekend Squash Ladder',
    ],
    accessibilityNote:
        'Wheelchair-accessible ramp, ground-floor courts & dedicated accessible restrooms',
    amenities: [
      FacilityAmenity(icon: Icons.local_parking_outlined, label: 'Parking'),
      FacilityAmenity(icon: Icons.checkroom_outlined, label: 'Changing rooms'),
      FacilityAmenity(icon: Icons.shower_outlined, label: 'Showers'),
      FacilityAmenity(icon: Icons.local_cafe_outlined, label: 'Cafeteria'),
      FacilityAmenity(icon: Icons.inventory_2_outlined, label: 'Equipment rental'),
    ],
  ),
  FacilityItem(
    id: 'city_sports_ground',
    name: 'City Sports Ground',
    imageUrl: 'assets/images/football.jpg',
    status: 'Open',
    cityLocation: 'Colombo 05, Sri Lanka',
    address: '45 Havelock Road, Colombo 05',
    phone: '+94 11 258 9123',
    email: 'contact@citysportsground.lk',
    openingHours: '7:00 AM – 9:00 PM',
    availableSports: ['Football', 'Cricket', 'Athletics'],
    rating: 4.6,
    distance: '2.8 km away',
    scheduleTimeRange: '4:00 PM – 7:00 PM',
    scheduleEventTitle: 'Youth Football Training Day',
    upcomingEvents: [
      'Youth Football Training Day',
      'Inter-Club Friendly Match',
      'Morning Athletics Practice',
    ],
    accessibilityNote:
        'Accessible spectator stands and designated disabled parking spots',
    amenities: [
      FacilityAmenity(icon: Icons.local_parking_outlined, label: 'Parking'),
      FacilityAmenity(icon: Icons.checkroom_outlined, label: 'Changing rooms'),
      FacilityAmenity(icon: Icons.lightbulb_outline, label: 'Floodlights'),
      FacilityAmenity(icon: Icons.medical_services_outlined, label: 'First Aid'),
    ],
  ),
  FacilityItem(
    id: 'downtown_arena',
    name: 'Downtown Arena',
    imageUrl:
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=1200&q=80',
    status: 'Open',
    cityLocation: 'Colombo 03, Sri Lanka',
    address: '88 Galle Road, Kollupitiya, Colombo 03',
    phone: '+94 11 243 7890',
    email: 'support@downtownarena.lk',
    openingHours: '8:00 AM – 11:00 PM',
    availableSports: ['Basketball', 'Volleyball', 'Futsal'],
    rating: 4.9,
    distance: '3.5 km away',
    scheduleTimeRange: '2:00 PM – 6:00 PM',
    scheduleEventTitle: 'Weekend Basketball League',
    upcomingEvents: [
      'Weekend Basketball League',
      '3v3 Streetball Shootout',
      'Evening Volleyball Match',
    ],
    accessibilityNote:
        'Elevator access to court levels and dedicated wheelchair seating zones',
    amenities: [
      FacilityAmenity(icon: Icons.local_parking_outlined, label: 'Parking'),
      FacilityAmenity(icon: Icons.ac_unit_rounded, label: 'Air conditioning'),
      FacilityAmenity(icon: Icons.lock_outline_rounded, label: 'Lockers'),
      FacilityAmenity(icon: Icons.local_cafe_outlined, label: 'Refreshment bar'),
    ],
  ),
  FacilityItem(
    id: 'royal_palms_tennis',
    name: 'Royal Palms Tennis Club',
    imageUrl:
        'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=1200&q=80',
    status: 'Open',
    cityLocation: 'Colombo 02, Sri Lanka',
    address: '12 Park Street, Colombo 02',
    phone: '+94 11 267 4321',
    email: 'info@royalpalmssports.lk',
    openingHours: '6:30 AM – 8:30 PM',
    availableSports: ['Tennis', 'Table Tennis'],
    rating: 4.7,
    distance: '4.1 km away',
    scheduleTimeRange: '7:00 AM – 11:00 AM',
    scheduleEventTitle: 'Morning Singles Ladder',
    upcomingEvents: [
      'Morning Singles Ladder',
      'Weekend Doubles Clinic',
    ],
    accessibilityNote: 'Ramp access to all clay and synthetic courts',
    amenities: [
      FacilityAmenity(icon: Icons.local_parking_outlined, label: 'Parking'),
      FacilityAmenity(icon: Icons.storefront_outlined, label: 'Pro Shop'),
      FacilityAmenity(icon: Icons.shower_outlined, label: 'Showers'),
      FacilityAmenity(icon: Icons.weekend_outlined, label: 'Clubhouse Lounge'),
    ],
  ),
  FacilityItem(
    id: 'metro_aquatic_centre',
    name: 'Metro Aquatic & Fitness Centre',
    imageUrl:
        'https://images.unsplash.com/photo-1519315901367-f34ff9154487?w=1200&q=80',
    status: 'Open',
    cityLocation: 'Colombo 08, Sri Lanka',
    address: '200 Cotta Road, Colombo 08',
    phone: '+94 11 269 8899',
    email: 'aquatics@metrofitness.lk',
    openingHours: '5:30 AM – 9:30 PM',
    availableSports: ['Swimming', 'Water Polo'],
    rating: 4.8,
    distance: '5.0 km away',
    scheduleTimeRange: '6:00 AM – 12:00 PM',
    scheduleEventTitle: 'Public Lane Swimming',
    upcomingEvents: [
      'Public Lane Swimming',
      'Masters Swim Meet',
    ],
    accessibilityNote:
        'Pool hoist available on request, step-free entrance & accessible lockers',
    amenities: [
      FacilityAmenity(icon: Icons.pool_rounded, label: 'Olympic Pool'),
      FacilityAmenity(icon: Icons.checkroom_outlined, label: 'Lockers & Showers'),
      FacilityAmenity(icon: Icons.local_cafe_outlined, label: 'Healthy Cafe'),
      FacilityAmenity(icon: Icons.local_parking_outlined, label: 'Parking'),
    ],
  ),
];

FacilityItem findFacilityByName(String name) {
  final cleanName = name.trim().toLowerCase();
  for (final facility in kMockFacilities) {
    if (facility.name.toLowerCase().contains(cleanName) ||
        cleanName.contains(facility.name.toLowerCase()) ||
        cleanName.contains(facility.id.replaceAll('_', ' '))) {
      return facility;
    }
  }

  // Graceful fallback for any unknown facility
  return FacilityItem(
    id: name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
    name: name,
    imageUrl: 'assets/images/badminton.jpg',
    status: 'Open',
    cityLocation: 'Colombo, Sri Lanka',
    address: '$name, Colombo',
    phone: '+94 11 200 0000',
    email: 'contact@sportspace.lk',
    openingHours: '8:00 AM – 10:00 PM',
    availableSports: const ['Multi-Sport', 'Badminton', 'Football'],
    rating: 4.5,
    distance: '2.0 km away',
    scheduleTimeRange: '8:00 AM – 8:00 PM',
    scheduleEventTitle: 'Public Sports & Practice Sessions',
    upcomingEvents: const ['Community Practice Session', 'Open Friendly Play'],
    accessibilityNote: 'Accessible entrance & parking on site',
    amenities: const [
      FacilityAmenity(icon: Icons.local_parking_outlined, label: 'Parking'),
      FacilityAmenity(icon: Icons.checkroom_outlined, label: 'Changing rooms'),
      FacilityAmenity(icon: Icons.local_cafe_outlined, label: 'Refreshments'),
      FacilityAmenity(icon: Icons.inventory_2_outlined, label: 'Equipment rental'),
    ],
  );
}

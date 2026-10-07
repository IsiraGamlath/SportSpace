 

class NearbyEvent {
  final String title;
  final String sport;
  final String date;
  final String time;
  final String location;
  final String status; // e.g. 'Open', 'Confirmed'
  final String imageUrl;

  const NearbyEvent({
    required this.title,
    required this.sport,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
    required this.imageUrl,
  });
}
import 'time_slot.dart';

class Booking {
  final String id;
  final String courtName;
  final TimeSlot slot;
  final String status;
  final String bookingId;

  Booking({
    required this.id,
    required this.courtName,
    required this.slot,
    required this.status,
    required this.bookingId,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      courtName: json['courtName'] ?? 'Badminton Court 1',
      slot: TimeSlot(
        id: json['slot']['_id'] ?? json['slot']['id'] ?? '',
        time: json['slot']['time'] ?? '',
        durationRange: json['slot']['durationRange'] ?? '',
        status: SlotStatus.booked,
        price: (json['slot']['price'] ?? 0).toDouble(),
        isConflictTrigger: false,
        date: json['slot']['date'] ?? '',
        courtName: json['slot']['courtName'] ?? '',
        facilityType: json['slot']['facilityType'] ?? '',
      ),
      status: json['status'] ?? 'confirmed',
      bookingId: json['bookingId'] ?? 'SS-00000',
    );
  }
}

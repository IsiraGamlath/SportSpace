enum SlotStatus {
  available,
  selected,
  booked,
}

class TimeSlot {
  final String id;
  final String time;
  final String durationRange;
  final SlotStatus status;
  final double price;
  final bool isConflictTrigger;
  final String? date;
  final String? courtName;
  final String? facilityType;

  const TimeSlot({
    required this.id,
    required this.time,
    required this.durationRange,
    required this.status,
    required this.price,
    this.isConflictTrigger = false,
    this.date,
    this.courtName,
    this.facilityType,
  });

  TimeSlot copyWith({
    String? id,
    String? time,
    String? durationRange,
    SlotStatus? status,
    double? price,
    bool? isConflictTrigger,
    String? date,
    String? courtName,
    String? facilityType,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      time: time ?? this.time,
      durationRange: durationRange ?? this.durationRange,
      status: status ?? this.status,
      price: price ?? this.price,
      isConflictTrigger: isConflictTrigger ?? this.isConflictTrigger,
      date: date ?? this.date,
      courtName: courtName ?? this.courtName,
      facilityType: facilityType ?? this.facilityType,
    );
  }
}

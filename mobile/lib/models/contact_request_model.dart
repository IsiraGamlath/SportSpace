
enum ContactRequestType { generalEnquiry, accessibilityRequest }

class ContactRequest {
  final String id;
  final String facilityId;
  final String userId;
  final ContactRequestType type;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ContactRequest({
    required this.id,
    required this.facilityId,
    required this.userId,
    required this.type,
    required this.message,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
  });

  ContactRequest copyWith({
    String? id,
    String? facilityId,
    String? userId,
    ContactRequestType? type,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactRequest(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
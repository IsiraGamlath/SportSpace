
enum ContactRequestType { generalEnquiry, accessibilityRequest }

class ContactRequest {
  final String id;
  final String facilityId;
  final String userId;
  final ContactRequestType type;
  final String message;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ContactRequest({
    required this.id,
    required this.facilityId,
    required this.userId,
    required this.type,
    required this.message,
    required this.createdAt,
    this.updatedAt,
  });

  ContactRequest copyWith({
    ContactRequestType? type,
    String? message,
    DateTime? updatedAt,
  }) {
    return ContactRequest(
      id: id,
      facilityId: facilityId,
      userId: userId,
      type: type ?? this.type,
      message: message ?? this.message,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
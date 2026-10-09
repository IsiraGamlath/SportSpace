import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/contact_request_model.dart';
import '../models/app_notification_model.dart';
import 'api_service.dart';
import 'app_services.dart';

class ContactRequestService extends ChangeNotifier {
  final Map<String, ContactRequest> _requests = {}; // keyed by id
  int _nextId = 1;

  // Placeholder until the project has real authentication.
  static const String _currentUserId = 'guest';

  ContactRequestService() {
    loadFromBackend();
  }

  Future<void> loadFromBackend() async {
    try {
      final backendList = await ApiService.fetchContactRequests(userId: _currentUserId);
      if (backendList.isNotEmpty) {
        for (final item in backendList) {
          final id = item['id'] as String? ?? item['_id'] as String? ?? 'req_${_nextId++}';
          final typeStr = item['type'] as String? ?? 'generalEnquiry';
          final type = typeStr == 'accessibilityRequest'
              ? ContactRequestType.accessibilityRequest
              : ContactRequestType.generalEnquiry;

          _requests[id] = ContactRequest(
            id: id,
            facilityId: item['facilityId'] as String? ?? 'general',
            userId: item['userId'] as String? ?? _currentUserId,
            type: type,
            message: item['message'] as String? ?? '',
            createdAt: item['createdAt'] != null
                ? DateTime.tryParse(item['createdAt'].toString()) ?? DateTime.now()
                : DateTime.now(),
            updatedAt: item['updatedAt'] != null
                ? DateTime.tryParse(item['updatedAt'].toString())
                : null,
          );
        }
        notifyListeners();
      }
    } catch (_) {
      // Offline fallback
    }
  }

  List<ContactRequest> requestsForUser(String userId) =>
      _requests.values.where((r) => r.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<ContactRequest> get myRequests => requestsForUser(_currentUserId);

  /// CREATE
  ContactRequest create({
    required String facilityId,
    required ContactRequestType type,
    required String message,
  }) {
    final id = 'req_${_nextId++}';
    final request = ContactRequest(
      id: id,
      facilityId: facilityId,
      userId: _currentUserId,
      type: type,
      message: message,
      createdAt: DateTime.now(),
    );
    _requests[id] = request;
    notifyListeners();

    // Push to backend
    ApiService.createContactRequest({
      'facilityId': facilityId,
      'userId': _currentUserId,
      'type': type.name,
      'message': message,
    }).catchError((_) => <String, dynamic>{});

    // Requirement 13: when submit contact enquiry or accessibility request,
    // show in notification screen for community member who submitted the request.
    final readableType = type == ContactRequestType.accessibilityRequest
        ? 'Accessibility Request'
        : 'Contact Enquiry';

    appServices.notificationService.dispatchNotification(
      targetRoles: ['communityMember'],
      userId: _currentUserId,
      category: NotificationCategory.facility,
      title: 'Request Submitted',
      message: 'Your $readableType for $facilityId has been submitted successfully.',
      accentColor: const Color(0xFF2E8B57), // Green
    );

    return request;
  }

  /// UPDATE — no-op if [id] doesn't exist or isn't owned by current user.
  void update(String id, {ContactRequestType? type, String? message}) {
    final existing = _requests[id];
    if (existing == null || existing.userId != _currentUserId) return;

    _requests[id] = existing.copyWith(
      type: type,
      message: message,
      updatedAt: DateTime.now(),
    );
    notifyListeners();

    // Push update to backend
    ApiService.updateContactRequest(id, {
      if (type != null) 'type': type.name,
      if (message != null) 'message': message,
    }).catchError((_) => <String, dynamic>{});
  }

  /// DELETE — no-op if [id] doesn't exist or isn't owned by current user.
  void delete(String id) {
    final existing = _requests[id];
    if (existing == null || existing.userId != _currentUserId) return;

    _requests.remove(id);
    notifyListeners();

    // Push delete to backend
    ApiService.deleteContactRequest(id).catchError((_) => false);
  }

  @visibleForTesting
  void resetForTesting() {
    _requests.clear();
    _nextId = 1;
    notifyListeners();
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/contact_request_model.dart';
import '../models/app_notification_model.dart';
import 'api_service.dart';
import 'app_services.dart';

class ContactRequestService extends ChangeNotifier {
  final Map<String, ContactRequest> _requests = {}; // keyed by id
  int _nextId = 1;

  String get currentUserId {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid.isNotEmpty) {
        return user.uid;
      }
    } catch (_) {}
    return 'guest';
  }

  ContactRequestService() {
    loadFromBackend();
    try {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        loadFromBackend(user?.uid);
      });
    } catch (_) {}
  }

  Future<void> loadFromBackend([String? targetUserId]) async {
    final activeUserId = targetUserId ?? currentUserId;
    try {
      final backendList = await ApiService.fetchContactRequests(userId: activeUserId);
      _requests.clear();
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
            userId: item['userId'] as String? ?? activeUserId,
            type: type,
            message: item['message'] as String? ?? '',
            status: item['status'] as String? ?? 'pending',
            createdAt: item['createdAt'] != null
                ? DateTime.tryParse(item['createdAt'].toString()) ?? DateTime.now()
                : DateTime.now(),
            updatedAt: item['updatedAt'] != null
                ? DateTime.tryParse(item['updatedAt'].toString())
                : null,
          );
        }
      }
      notifyListeners();
    } catch (_) {
      // Offline fallback
    }
  }

  List<ContactRequest> requestsForUser(String userId) =>
      _requests.values.where((r) => r.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<ContactRequest> get myRequests => requestsForUser(currentUserId);

  /// CREATE
  ContactRequest create({
    required String facilityId,
    required ContactRequestType type,
    required String message,
  }) {
    final activeUserId = currentUserId;
    final id = 'req_${_nextId++}';
    final request = ContactRequest(
      id: id,
      facilityId: facilityId,
      userId: activeUserId,
      type: type,
      message: message,
      createdAt: DateTime.now(),
    );
    _requests[id] = request;
    notifyListeners();

    // Push to backend
    () async {
      try {
        final created = await ApiService.createContactRequest({
          'facilityId': facilityId,
          'userId': activeUserId,
          'type': type.name,
          'message': message,
        });
        if (created.containsKey('id') || created.containsKey('_id')) {
          final serverId = created['id'] as String? ?? created['_id'] as String?;
          if (serverId != null && serverId != id) {
            _requests.remove(id);
            _requests[serverId] = request.copyWith(id: serverId);
            notifyListeners();
          }
        }
      } catch (_) {}
    }();

    // Requirement 13: when submit contact enquiry or accessibility request,
    // show in notification screen for community member who submitted the request.
    final readableType = type == ContactRequestType.accessibilityRequest
        ? 'Accessibility Request'
        : 'Contact Enquiry';

    appServices.notificationService.dispatchNotification(
      targetRoles: ['communityMember'],
      userId: activeUserId,
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
    final activeUserId = currentUserId;
    if (existing == null || existing.userId != activeUserId) return;

    _requests[id] = existing.copyWith(
      type: type,
      message: message,
      updatedAt: DateTime.now(),
    );
    notifyListeners();

    // Push update to backend
    () async {
      try {
        await ApiService.updateContactRequest(id, {
          if (type != null) 'type': type.name,
          if (message != null) 'message': message,
        });
      } catch (_) {}
    }();
  }

  /// DELETE — no-op if [id] doesn't exist or isn't owned by current user.
  void delete(String id) {
    final existing = _requests[id];
    final activeUserId = currentUserId;
    if (existing == null || existing.userId != activeUserId) return;

    _requests.remove(id);
    notifyListeners();

    // Push delete to backend
    () async {
      try {
        await ApiService.deleteContactRequest(id);
      } catch (_) {}
    }();

    // Requirement 3: when community member deletes a request, dispatch notification to communityMember
    final readableType = existing.type == ContactRequestType.accessibilityRequest
        ? 'Accessibility Request'
        : 'Contact Enquiry';

    appServices.notificationService.dispatchNotification(
      targetRoles: ['communityMember'],
      userId: activeUserId,
      category: NotificationCategory.facility,
      title: 'Request Deleted',
      message: 'Your $readableType for ${existing.facilityId} has been deleted.',
      accentColor: const Color(0xFFE14C4C), // Red
      icon: Icons.delete_outline_rounded,
    );
  }

  @visibleForTesting
  void resetForTesting() {
    _requests.clear();
    _nextId = 1;
    notifyListeners();
  }
}
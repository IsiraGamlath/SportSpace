
import 'package:flutter/foundation.dart';
import '../models/contact_request_model.dart';

class ContactRequestService extends ChangeNotifier {
  final Map<String, ContactRequest> _requests = {}; // keyed by id
  int _nextId = 1;

  // Placeholder until the project has real authentication.
  static const String _currentUserId = 'guest';

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

    // TODO(backend): persist, e.g.
    //   await FirebaseFirestore.instance
    //     .collection('contact_requests').doc(id)
    //     .set({
    //       'facilityId': request.facilityId,
    //       'userId': request.userId,
    //       'type': request.type.name,
    //       'message': request.message,
    //       'createdAt': request.createdAt,
    //     });

    return request;
  }

  /// UPDATE — no-op if [id] doesn't exist or isn't owned by the
  /// current user.
  void update(String id, {ContactRequestType? type, String? message}) {
    final existing = _requests[id];
    if (existing == null || existing.userId != _currentUserId) return;

    _requests[id] = existing.copyWith(
      type: type,
      message: message,
      updatedAt: DateTime.now(),
    );
    notifyListeners();

    // TODO(backend): persist update, e.g.
    //   await FirebaseFirestore.instance
    //     .collection('contact_requests').doc(id)
    //     .update({'type': ..., 'message': ..., 'updatedAt': ...});
  }

  /// DELETE — no-op if [id] doesn't exist or isn't owned by the
  /// current user.
  void delete(String id) {
    final existing = _requests[id];
    if (existing == null || existing.userId != _currentUserId) return;

    _requests.remove(id);
    notifyListeners();

    // TODO(backend): persist delete, e.g.
    //   await FirebaseFirestore.instance.collection('contact_requests').doc(id).delete();
  }

  @visibleForTesting
  void resetForTesting() {
    _requests.clear();
    _nextId = 1;
    notifyListeners();
  }
}
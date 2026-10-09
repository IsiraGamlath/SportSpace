// lib/services/app_services.dart
//
// Lightweight service locator — plain top-level singletons, no DI
// package required. Screens/widgets import `appServices` directly, so
// Save/Bookmark, Remind Me, and Contact Request state stays consistent
// everywhere without threading instances through every constructor.

import 'bookmark_service.dart';
import 'reminder_service.dart';
import 'event_repository.dart';
import 'contact_request_service.dart';

class AppServices {
  AppServices._internal();
  static final AppServices instance = AppServices._internal();

  final BookmarkService bookmarkService = BookmarkService();
  final ReminderService reminderService = ReminderService();
  final EventRepository eventRepository = MockEventRepository();
  final ContactRequestService contactRequestService = ContactRequestService();
}

final AppServices appServices = AppServices.instance;
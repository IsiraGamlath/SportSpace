

import 'bookmark_service.dart';
import 'reminder_service.dart';
import 'event_repository.dart';

class AppServices {
  AppServices._internal();
  static final AppServices instance = AppServices._internal();

  final BookmarkService bookmarkService = BookmarkService();
  final ReminderService reminderService = ReminderService();
  final EventRepository eventRepository = MockEventRepository();
}

final AppServices appServices = AppServices.instance;
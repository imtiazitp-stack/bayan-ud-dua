import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Lets someone set a daily reminder to recite a specific dua, backed by
/// a real local notification (not just a UI toggle) so it fires even if
/// the app isn't open. One reminder per dua, keyed by `Dua.appId` — both
/// as the notification id and as the SharedPreferences key so the app can
/// show whether a reminder is already set without querying the OS.
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const _prefsPrefix = 'reminder_hour_minute_';
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    _initialized = true;
  }

  /// The time-of-day a reminder is set for this dua, or null if none.
  Future<TimeOfDayValue?> reminderFor(int appId) async {
    final prefs = await SharedPreferences.getInstance();
    final packed = prefs.getInt('$_prefsPrefix$appId');
    if (packed == null) return null;
    return TimeOfDayValue(packed ~/ 100, packed % 100);
  }

  Future<void> setReminder({
    required int appId,
    required String duaLabel,
    required int hour,
    required int minute,
  }) async {
    await init();
    final scheduled = _nextInstanceOf(hour, minute);
    await _plugin.zonedSchedule(
      appId,
      'Time for $duaLabel',
      'A gentle reminder to recite this dua.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'dua_reminders',
          'Dua reminders',
          channelDescription: 'Daily reminders to recite a specific dua',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefsPrefix$appId', hour * 100 + minute);
  }

  Future<void> cancelReminder(int appId) async {
    await init();
    await _plugin.cancel(appId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefsPrefix$appId');
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// A plain hour/minute pair — avoids depending on Flutter's material
/// TimeOfDay from a services file that shouldn't need the UI toolkit.
class TimeOfDayValue {
  final int hour;
  final int minute;
  const TimeOfDayValue(this.hour, this.minute);

  String format() {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}

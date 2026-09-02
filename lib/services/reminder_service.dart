import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Lets someone set one or more daily reminders to recite a specific dua,
/// backed by real local notifications (not just a UI toggle) so they fire
/// even if the app isn't open.
///
/// A dua's reminders are stored as a list of packed "HMM" times (e.g. 830
/// for 8:30) under one SharedPreferences key per dua. Each notification's
/// id is derived from `appId` and its own time, not from a per-dua slot
/// index - `appId * 10000 + hour*100 + minute` is unique across every
/// (dua, time) pair (packed time maxes out at 2359, well under 10000), so
/// adding or removing one specific time never disturbs any other.
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const _prefsPrefix = 'reminder_times_';
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

  int _packTime(int hour, int minute) => hour * 100 + minute;
  int _notificationId(int appId, int packed) => appId * 10000 + packed;

  /// Every reminder time currently set for this dua, earliest first.
  Future<List<TimeOfDayValue>> remindersFor(int appId) async {
    final prefs = await SharedPreferences.getInstance();
    final packed = (prefs.getStringList('$_prefsPrefix$appId') ?? [])
        .map(int.parse)
        .toList()
      ..sort();
    return packed.map((p) => TimeOfDayValue(p ~/ 100, p % 100)).toList();
  }

  Future<void> addReminder({
    required int appId,
    required String duaLabel,
    required int hour,
    required int minute,
  }) async {
    await init();
    final packed = _packTime(hour, minute);
    final scheduled = _nextInstanceOf(hour, minute);
    await _plugin.zonedSchedule(
      _notificationId(appId, packed),
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
    final key = '$_prefsPrefix$appId';
    final current = prefs.getStringList(key) ?? [];
    if (!current.contains('$packed')) {
      await prefs.setStringList(key, [...current, '$packed']);
    }
  }

  Future<void> removeReminder({
    required int appId,
    required int hour,
    required int minute,
  }) async {
    await init();
    final packed = _packTime(hour, minute);
    await _plugin.cancel(_notificationId(appId, packed));
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefsPrefix$appId';
    final current = prefs.getStringList(key) ?? [];
    current.remove('$packed');
    await prefs.setStringList(key, current);
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

/// A plain hour/minute pair - avoids depending on Flutter's material
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

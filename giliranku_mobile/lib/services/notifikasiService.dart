import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotifikasiService {
  static final NotifikasiService _instance = NotifikasiService._internal();
  factory NotifikasiService() => _instance;
  NotifikasiService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service. Call this once at app startup.
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permission on Android 13+
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    _initialized = true;
    debugPrint('notifikasiService initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show a notification immediately (for past-due or test).
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'kontrol_rutin_channel',
      'Pengingat Kontrol Rutin',
      channelDescription: 'Notifikasi pengingat jadwal kontrol rutin pasien',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, notificationDetails,
        payload: payload);

    debugPrint('Notification $id shown immediately');
  }

  /// Schedule a notification at a specific date and time.
  /// If the scheduled time is in the past but TODAY, show it immediately.
  /// If it's a past day entirely, skip it.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    // If scheduled time already passed
    if (scheduledTZDate.isBefore(now)) {
      // If it's still today, show immediately
      if (scheduledTZDate.year == now.year &&
          scheduledTZDate.month == now.month &&
          scheduledTZDate.day == now.day) {
        debugPrint('Notification $id: scheduled earlier today, showing now');
        await showNow(id: id, title: title, body: body, payload: payload);
        return;
      }
      // Past day entirely — skip
      debugPrint('Skipping notification $id: scheduled date is in the past');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'kontrol_rutin_channel',
      'Pengingat Kontrol Rutin',
      channelDescription: 'Notifikasi pengingat jadwal kontrol rutin pasien',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      matchDateTimeComponents: null,
    );

    debugPrint(
        'Notification $id scheduled for ${scheduledTZDate.toIso8601String()}');
  }

  /// Schedule the 3 kontrol rutin reminders: H-7, H-3, H-1
  /// Notifications fire at 09:00 AM on each reminder day.
  Future<void> scheduleKontrolRutinReminders({
    required int controlId,
    required DateTime controlDate,
    required String patientName,
    String? notes,
  }) async {
    final List<int> reminderDays = [7, 3, 1];

    for (final int daysBefore in reminderDays) {
      // Set notification time to exact 24 hours before (keep the hour/minute intact)
      final DateTime reminderDate = DateTime(
        controlDate.year,
        controlDate.month,
        controlDate.day - daysBefore,
        controlDate.hour,
        controlDate.minute,
      );

      // Unique ID per control per reminder tier (safely within 32-bit int limit for Android)
      final int baseId = controlId % 100000000; // Take last 8 digits
      final int notifId = baseId * 10 + daysBefore;

      String body;
      if (daysBefore == 1) {
        body =
            'Besok adalah jadwal kontrol rutin Anda di RSUD Porsea (${_formatDate(controlDate)}).';
      } else {
        body =
            'Jadwal kontrol rutin Anda di RSUD Porsea tinggal $daysBefore hari lagi (${_formatDate(controlDate)}).';
      }

      if (notes != null && notes.isNotEmpty) {
        body += ' Catatan: $notes';
      }

      await scheduleNotification(
        id: notifId,
        title: 'Pengingat Kontrol Rutin - H-$daysBefore',
        body: body,
        scheduledDate: reminderDate,
        payload: 'kontrol_rutin_$controlId',
      );
    }
  }

  /// Cancel all notifications for a specific control
  Future<void> cancelKontrolRutinReminders(int controlId) async {
    final int baseId = controlId % 100000000;
    for (final int daysBefore in [7, 3, 1]) {
      final int notifId = baseId * 10 + daysBefore;
      await _notificationsPlugin.cancel(notifId);
    }
    debugPrint('Cancelled all reminders for control $controlId');
  }

  /// Cancel all pending notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  String _formatDate(DateTime date) {
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

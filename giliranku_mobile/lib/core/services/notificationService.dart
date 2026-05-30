import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    _initialized = true;
    debugPrint('notifikasiService initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

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
          channelDescription:
              'Notifikasi pengingat jadwal kontrol rutin pasien',
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

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    debugPrint('Notification $id shown immediately');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      if (scheduledTZDate.isBefore(now)) {
        if (scheduledTZDate.year == now.year &&
            scheduledTZDate.month == now.month &&
            scheduledTZDate.day == now.day) {
          debugPrint('Notification $id: scheduled earlier today, showing now');
          await showNow(id: id, title: title, body: body, payload: payload);
        } else {
          debugPrint('Skipping notification $id: scheduled date is in the past');
        }
        return;
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'kontrol_rutin_channel',
            'Pengingat Kontrol Rutin',
            channelDescription:
                'Notifikasi pengingat jadwal kontrol rutin pasien',
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
        matchDateTimeComponents: null,
      );

      debugPrint(
        'Notification $id scheduled for ${scheduledTZDate.toIso8601String()}',
      );
    } catch (e) {
      debugPrint('scheduleNotification $id error (diabaikan): $e');
    }
  }

  Future<void> scheduleKontrolRutinReminders({
    required int controlId,
    required DateTime controlDate,
    required String patientName,
    String? notes,
  }) async {
    final List<int> reminderDays = [7, 3, 1];

    for (final int daysBefore in reminderDays) {
      final DateTime reminderDate = DateTime(
        controlDate.year,
        controlDate.month,
        controlDate.day,
        controlDate.hour,
        controlDate.minute,
      ).subtract(Duration(days: daysBefore));

      final int baseId = controlId % 100000000;
      final int notifId = baseId * 10 + daysBefore;

      String body;
      if (daysBefore == 1) {
        body =
            'Besok adalah jadwal kontrol rutin Anda di RSUD Porsea (${_formatDate(controlDate)}, ${_formatTime(controlDate)}).';
      } else {
        body =
            'Jadwal kontrol rutin Anda di RSUD Porsea tinggal $daysBefore hari lagi (${_formatDate(controlDate)}, ${_formatTime(controlDate)}).';
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

    final DateTime oneHourBefore = DateTime(
      controlDate.year,
      controlDate.month,
      controlDate.day,
      controlDate.hour,
      controlDate.minute,
    ).subtract(const Duration(hours: 1));
    final int baseId = controlId % 100000000;
    final int oneHourNotifId = baseId * 10;

    String oneHourBody =
        'Jadwal kontrol rutin Anda di RSUD Porsea 1 jam lagi (${_formatDate(controlDate)}, ${_formatTime(controlDate)}).';

    if (notes != null && notes.isNotEmpty) {
      oneHourBody += ' Catatan: $notes';
    }

    await scheduleNotification(
      id: oneHourNotifId,
      title: 'Pengingat Kontrol Rutin - 1 Jam Lagi',
      body: oneHourBody,
      scheduledDate: oneHourBefore,
      payload: 'kontrol_rutin_$controlId',
    );
  }

  Future<void> cancelKontrolRutinReminders(int controlId) async {
    final int baseId = controlId % 100000000;
    for (final int suffix in [7, 3, 1, 0]) {
      final int notifId = baseId * 10 + suffix;
      await _notificationsPlugin.cancel(notifId);
    }
    debugPrint('Cancelled all reminders for control $controlId');
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  String _formatDate(DateTime date) {
    final List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
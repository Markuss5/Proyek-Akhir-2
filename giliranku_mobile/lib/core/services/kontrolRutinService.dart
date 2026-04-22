import 'package:flutter/material.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/models/kontrolRutinModel.dart';
import 'package:giliranku/core/models/notifikasiModel.dart';
import 'package:giliranku/core/services/notificationService.dart';

/// Service layer for kontrol rutin business logic.
/// Delegates all HTTP calls to [ApiDataSource] (via repository pattern)
/// and handles local notification scheduling.
class KontrolRutinService {
  static final KontrolRutinService _instance = KontrolRutinService._internal();
  factory KontrolRutinService() => _instance;
  KontrolRutinService._internal();

  final ApiDataSource _api = ApiDataSource();
  final NotificationService _notifikasiService = NotificationService();

  /// Create a new kontrol rutin schedule.
  /// This will:
  /// 1. Post to the backend (which auto-creates 3 notification records in DB)
  /// 2. Schedule 3 local native phone notifications (H-7, H-3, H-1)
  Future<KontrolRutinModel?> createKontrolRutin({
    required String nik,
    required DateTime controlDate,
    String? notes,
  }) async {
    try {
      final kontrolRutin = await _api.createKontrolRutin(
        nik: nik,
        controlDate: controlDate,
        notes: notes,
      );

      if (kontrolRutin != null) {
        // Schedule local native phone notifications
        await _notifikasiService.scheduleKontrolRutinReminders(
          controlId: kontrolRutin.controlId,
          controlDate: kontrolRutin.controlDate,
          patientName: nik,
          notes: kontrolRutin.notes,
        );

        debugPrint('Kontrol rutin created and notifications scheduled');
        return kontrolRutin;
      } else {
        debugPrint('Failed to create kontrol rutin');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating kontrol rutin: $e');
      return null;
    }
  }

  /// Get all kontrol rutin schedules for a patient
  Future<List<KontrolRutinModel>> getByNIK(String nik) async {
    try {
      return await _api.fetchKontrolRutinByNik(nik);
    } catch (e) {
      debugPrint('Error fetching kontrol rutin: $e');
      return [];
    }
  }

  /// Get all notifications for a patient
  Future<List<NotifikasiModel>> getNotifikasi(String nik) async {
    try {
      return await _api.fetchNotifikasiByNik(nik);
    } catch (e) {
      debugPrint('Error fetching notifikasi: $e');
      return [];
    }
  }

  /// Re-schedule local notifications for all upcoming kontrol rutin.
  /// Call this on app startup to ensure notifications persist after reinstall.
  Future<void> resyncNotifications(String nik) async {
    try {
      final kontrolList = await getByNIK(nik);
      final now = DateTime.now();

      for (final kr in kontrolList) {
        // Only re-schedule for future controls
        if (kr.controlDate.isAfter(now)) {
          await _notifikasiService.scheduleKontrolRutinReminders(
            controlId: kr.controlId,
            controlDate: kr.controlDate,
            patientName: nik,
            notes: kr.notes,
          );
        }
      }
      debugPrint('Notifications re-synced for $nik');
    } catch (e) {
      debugPrint('Error re-syncing notifications: $e');
    }
  }
}

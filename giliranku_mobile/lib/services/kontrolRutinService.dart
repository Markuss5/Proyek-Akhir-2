import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:giliranku_mobile/models/kontrolModel.dart';
import 'package:giliranku_mobile/models/notifikasiModel.dart';
import 'package:giliranku_mobile/services/notifikasiService.dart';

class KontrolRutinService {
  // Change this to your backend URL
  static const String _baseUrl = 'http://10.223.75.41:8080/api/v1';

  final NotifikasiService _notifikasiService = NotifikasiService();

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
      final response = await http.post(
        Uri.parse('$_baseUrl/kontrol-rutin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nik': nik,
          'control_date':
              '${controlDate.year}-${controlDate.month.toString().padLeft(2, '0')}-${controlDate.day.toString().padLeft(2, '0')}',
          'notes': notes ?? '',
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final kontrolRutin = KontrolRutinModel.fromJson(data['data']);

        // Schedule local native phone notifications
        await _notifikasiService.scheduleKontrolRutinReminders(
          controlId: kontrolRutin.controlId,
          controlDate: kontrolRutin.controlDate,
          patientName: nik, // Will be replaced with actual name if available
          notes: kontrolRutin.notes,
        );

        debugPrint('Kontrol rutin created and notifications scheduled');
        return kontrolRutin;
      } else {
        final error = jsonDecode(response.body);
        debugPrint('Failed to create kontrol rutin: ${error['message']}');
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
      final response = await http.get(
        Uri.parse('$_baseUrl/kontrol-rutin/pasien/$nik'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.map((e) => KontrolRutinModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching kontrol rutin: $e');
      return [];
    }
  }

  /// Get all notifications for a patient
  Future<List<NotifikasiModel>> getNotifikasi(String nik) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifikasi/pasien/$nik'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.map((e) => NotifikasiModel.fromJson(e)).toList();
      }
      return [];
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

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/models/kontrolRutinModel.dart';
import 'package:giliranku/core/services/notificationService.dart';

class KontrolRutinRepository {
  static final ApiDataSource _api = ApiDataSource();
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<KontrolRutinModel>> getAll() => _api.fetchAllKontrolRutin();

  Future<List<KontrolRutinModel>> getByNik(String nik) =>
      _api.fetchKontrolRutinByNik(nik);

  Future<KontrolRutinModel?> create({
    required String nik,
    required DateTime controlDate,
    String? notes,
  }) async {
    final entity = await _api.createKontrolRutin(
      nik: nik,
      controlDate: controlDate,
      notes: notes,
    );

    if (entity == null) return null;

    try {
      await _db
          .collection('kontrol_rutin')
          .doc(entity.controlId.toString())
          .set({
        'control_id': entity.controlId,
        'nik': nik,
        'control_date': Timestamp.fromDate(controlDate),
        'notes': notes ?? '',
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore write failed: $e');
    }

    return entity;
  }

  Future<bool> delete(int controlId) async {
    final success = await _api.deleteKontrolRutin(controlId);

    if (success) {
      try {
        await _db
            .collection('kontrol_rutin')
            .doc(controlId.toString())
            .delete();
      } catch (e) {
        debugPrint('Firestore delete failed: $e');
      }
    }

    return success;
  }

  Future<void> resyncNotifications(String nik) async {
    try {
      final now = DateTime.now();

      final snapshot = await _db
          .collection('kontrol_rutin')
          .where('nik', isEqualTo: nik)
          .where('control_date', isGreaterThan: Timestamp.fromDate(now))
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final controlDate = (data['control_date'] as Timestamp).toDate();
        final controlId = data['control_id'] as int;
        final notes = data['notes'] as String?;

        await NotificationService().scheduleKontrolRutinReminders(
          controlId: controlId,
          controlDate: controlDate,
          patientName: nik,
          notes: notes,
        );
      }

      debugPrint('Resynced ${snapshot.docs.length} notif for $nik');
    } catch (e) {
      debugPrint('resyncNotifications failed: $e');
      final list = await getByNik(nik);
      final now = DateTime.now();
      for (final kr in list) {
        if (kr.controlDate.isAfter(now)) {
          await NotificationService().scheduleKontrolRutinReminders(
            controlId: kr.controlId,
            controlDate: kr.controlDate,
            patientName: nik,
            notes: kr.notes,
          );
        }
      }
    }
  }
}
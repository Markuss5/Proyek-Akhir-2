import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/models/kontrolRutinModel.dart';
import 'package:giliranku/core/services/notificationService.dart';

/// Merged repository — interface and implementation in one class.
class KontrolRutinRepository {
  static final ApiDataSource _api = ApiDataSource();

  Future<List<KontrolRutinModel>> getAll() => _api.fetchAllKontrolRutin();

  Future<List<KontrolRutinModel>> getByNik(String nik) =>
      _api.fetchKontrolRutinByNik(nik);

  Future<KontrolRutinModel?> create({
    required String nik,
    required DateTime controlDate,
    String? notes,
  }) =>
      _api.createKontrolRutin(nik: nik, controlDate: controlDate, notes: notes);

  Future<bool> delete(int controlId) => _api.deleteKontrolRutin(controlId);

  /// Re-schedule local alarms for all upcoming controls of a patient.
  /// Call this after login so notifications survive reinstalls.
  Future<void> resyncNotifications(String nik) async {
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

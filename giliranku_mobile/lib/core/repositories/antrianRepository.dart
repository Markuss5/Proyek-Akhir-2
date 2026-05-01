import 'package:giliranku/core/datasources/apiDataSource.dart';

class AntrianRepository {
  static final ApiDataSource _api = ApiDataSource();

  Future<List<Map<String, dynamic>>> getRiwayatAntrian(String nik) async {
    try {
      final response = await _api.getRiwayatAntrian(nik);
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
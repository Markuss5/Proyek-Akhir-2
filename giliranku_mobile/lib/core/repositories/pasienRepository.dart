import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/models/pasienModel.dart';

class PasienRepository {
  static final ApiDataSource _api = ApiDataSource();

  Future<PasienModel?> login(String nik, String name) =>
      _api.loginPasien(nik, name);

  Future<PasienModel?> getProfile(String nik) => _api.getProfile(nik);

  Future<PasienModel?> updateProfile(Map<String, dynamic> data) =>
      _api.updateProfile(data);
      
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
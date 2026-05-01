import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/models/pasienModel.dart';

/// Merged repository — interface and implementation in one class.
/// Views use this directly: `final _repo = PasienRepository();`
class PasienRepository {
  static final ApiDataSource _api = ApiDataSource();

  /// Login or register a patient. Returns entity on success, null on network error.
  /// If nik is empty on the returned model, it carries a server-level error in [phone].
  Future<PasienModel?> login(String nik, String name) =>
      _api.loginPasien(nik, name);

  Future<PasienModel?> getProfile(String nik) => _api.getProfile(nik);

  Future<PasienModel?> updateProfile(Map<String, dynamic> data) =>
      _api.updateProfile(data);
      
  /// Mengambil riwayat antrian pasien berdasarkan NIK
  Future<List<Map<String, dynamic>>> getRiwayatAntrian(String nik) async {
    try {
      // Memanggil fungsi getRiwayatAntrian yang ada di ApiDataSource
      final response = await _api.getRiwayatAntrian(nik);
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      // Mengembalikan list kosong jika terjadi error saat fetch data
      return [];
    }
  }
}
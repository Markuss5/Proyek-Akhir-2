/// Central place for all API base URL and endpoint constants.
/// Change [baseUrl] when switching environments (dev/staging/prod).
class ApiConstants {
  ApiConstants._(); // prevent instantiation

  // ── Base URL ──────────────────────────────────────────────────────────────
  /// Physical device: PC's local IP.
  /// Android emulator: use 10.0.2.2
  /// Run `ipconfig` to find your IP if connection fails.
  static const String baseUrl = 'http://10.226.247.41:8080/api/v1';

  static const Duration timeout = Duration(seconds: 10);

  // ── Endpoints ─────────────────────────────────────────────────────────────
  static const String poliklinik = '/poliklinik';
  static const String dokter = '/dokter';

  static const String pasienLogin = '/pasien/login';
  static const String pasienProfile = '/pasien/profile';

  static const String kontrolRutin = '/kontrol-rutin';
  static const String kontrolRutinAll = '/kontrol-rutin/all';
  static const String kontrolRutinByNik = '/kontrol-rutin/pasien'; // + /:nik

  static const String notifikasiByNik = '/notifikasi/pasien'; // + /:nik
}

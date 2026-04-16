import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For physical device: use your PC's local IP address (run 'ipconfig' to find it)
  // For Android emulator: use 10.0.2.2
  // NOTE: WiFi IPs can change! Run 'ipconfig' if connection fails.
  static const String baseUrl = 'http://10.223.75.41:8080/api/v1';

  // Short timeout for faster failure detection
  static const Duration _timeout = Duration(seconds: 5);

  // ============ POLIKLINIK ============

  static Future<List<Map<String, dynamic>>> fetchPoliklinik() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/poliklinik'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching poliklinik: $e');
    }
    return [];
  }

  // ============ DOKTER ============

  static Future<List<Map<String, dynamic>>> fetchDokterByPoly(int polyId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/dokter?poly_id=$polyId'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching dokter: $e');
    }
    return [];
  }

  // ============ KONTROL RUTIN ============

  static Future<List<Map<String, dynamic>>> fetchAllKontrolRutin() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/kontrol-rutin/all'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching kontrol rutin: $e');
    }
    return [];
  }

  static Future<bool> createKontrolRutin({
    required String nik,
    required String controlDate,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kontrol-rutin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nik': nik,
          'control_date': controlDate,
          'notes': notes ?? '',
        }),
      ).timeout(_timeout);
      return response.statusCode == 201;
    } catch (e) {
      print('Error creating kontrol rutin: $e');
    }
    return false;
  }

  // ============ PASIEN ============

  /// Login or auto-register a patient. Returns patient data map or null on failure.
  static Future<Map<String, dynamic>?> loginPasien(String nik, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pasien/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nik': nik, 'name': name}),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      } else {
        final data = jsonDecode(response.body);
        return {'error': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      print('Error login pasien: $e');
    }
    return null;
  }

  /// Get patient profile by NIK
  static Future<Map<String, dynamic>?> getProfile(String nik) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/pasien/profile/$nik'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
    return null;
  }

  /// Update patient profile
  static Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pasien/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profileData),
      ).timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
    return null;
  }

  // ============ NOTIFIKASI ============

  /// Fetch notifications for a specific patient NIK
  static Future<List<Map<String, dynamic>>> fetchNotifikasiByNIK(String nik) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/notifikasi/pasien/$nik'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching notifikasi: $e');
    }
    return [];
  }
}

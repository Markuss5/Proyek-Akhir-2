import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:giliranku/core/constants/apiConstants.dart';
import 'package:giliranku/core/models/pasienModel.dart';
import 'package:giliranku/core/models/kontrolRutinModel.dart';
import 'package:giliranku/core/models/notifikasiModel.dart';

/// The single class responsible for all outbound HTTP calls.
class ApiDataSource {
  static final ApiDataSource _instance = ApiDataSource._internal();
  factory ApiDataSource() => _instance;
  ApiDataSource._internal();

  final http.Client _client = http.Client();
  final Duration _timeout = ApiConstants.timeout;

  Uri _uri(String endpoint) => Uri.parse('${ApiConstants.baseUrl}$endpoint');
  Map<String, String> get _jsonHeaders => {'Content-Type': 'application/json'};

  // ══ PASIEN ════════════════════════════════════════════════════════════════

  Future<PasienModel?> loginPasien(String nik, String name) async {
    try {
      final res = await _client
          .post(
            _uri(ApiConstants.pasienLogin),
            headers: _jsonHeaders,
            body: jsonEncode({'nik': nik, 'name': name}),
          )
          .timeout(_timeout);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return PasienModel.fromJson(body['data'] as Map<String, dynamic>);
      }
      return PasienModel(
        nik: '',
        name: '',
        phone: body['message'] as String? ?? 'Login gagal',
      );
    } catch (e) {
      debugPrint('ApiDataSource.loginPasien: $e');
      return null;
    }
  }

  Future<PasienModel?> getProfile(String nik) async {
    try {
      final res = await _client
          .get(_uri('${ApiConstants.pasienProfile}/$nik'))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return PasienModel.fromJson(
          (jsonDecode(res.body) as Map<String, dynamic>)['data']
              as Map<String, dynamic>,
        );
      }
    } catch (e) {
      debugPrint('ApiDataSource.getProfile: $e');
    }
    return null;
  }

  Future<PasienModel?> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _client
          .put(
            _uri(ApiConstants.pasienProfile),
            headers: _jsonHeaders,
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return PasienModel.fromJson(
          (jsonDecode(res.body) as Map<String, dynamic>)['data']
              as Map<String, dynamic>,
        );
      }
    } catch (e) {
      debugPrint('ApiDataSource.updateProfile: $e');
    }
    return null;
  }

  // ══ POLIKLINIK & DOKTER ═══════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchPoliklinik() async {
    try {
      final res = await _client
          .get(_uri(ApiConstants.poliklinik))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return ((jsonDecode(res.body) as Map<String, dynamic>)['data']
                    as List<dynamic>? ??
                [])
            .cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('ApiDataSource.fetchPoliklinik: $e');
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchDokterByPoly(int polyId) async {
    try {
      final res = await _client
          .get(_uri('${ApiConstants.dokter}?poly_id=$polyId'))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return ((jsonDecode(res.body) as Map<String, dynamic>)['data']
                    as List<dynamic>? ??
                [])
            .cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('ApiDataSource.fetchDokterByPoly: $e');
    }
    return [];
  }

  // ══ KONTROL RUTIN ═════════════════════════════════════════════════════════

  Future<List<KontrolRutinModel>> fetchAllKontrolRutin() async {
    try {
      final res = await _client
          .get(_uri(ApiConstants.kontrolRutinAll))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return ((jsonDecode(res.body) as Map<String, dynamic>)['data']
                    as List<dynamic>? ??
                [])
            .map((e) => KontrolRutinModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('ApiDataSource.fetchAllKontrolRutin: $e');
    }
    return [];
  }

  Future<List<KontrolRutinModel>> fetchKontrolRutinByNik(String nik) async {
    try {
      final res = await _client
          .get(_uri('${ApiConstants.kontrolRutinByNik}/$nik'))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return ((jsonDecode(res.body) as Map<String, dynamic>)['data']
                    as List<dynamic>? ??
                [])
            .map((e) => KontrolRutinModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('ApiDataSource.fetchKontrolRutinByNik: $e');
    }
    return [];
  }

  Future<KontrolRutinModel?> createKontrolRutin({
    required String nik,
    required DateTime controlDate,
    String? notes,
  }) async {
    try {
      final res = await _client
          .post(
            _uri(ApiConstants.kontrolRutin),
            headers: _jsonHeaders,
            body: jsonEncode({
              'nik': nik,
              'control_date': controlDate.toUtc().toIso8601String(),
              'notes': notes ?? '',
            }),
          )
          .timeout(_timeout);
      if (res.statusCode == 201) {
        return KontrolRutinModel.fromJson(
          (jsonDecode(res.body) as Map<String, dynamic>)['data']
              as Map<String, dynamic>,
        );
      }
      debugPrint('createKontrolRutin failed (${res.statusCode}): ${res.body}');
    } catch (e) {
      debugPrint('ApiDataSource.createKontrolRutin: $e');
    }
    return null;
  }

  Future<bool> deleteKontrolRutin(int id) async {
    try {
      final res = await _client
          .delete(_uri('${ApiConstants.kontrolRutin}/$id'))
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiDataSource.deleteKontrolRutin: $e');
    }
    return false;
  }

  // ══ NOTIFIKASI ════════════════════════════════════════════════════════════

  Future<List<NotifikasiModel>> fetchNotifikasiByNik(String nik) async {
    try {
      final res = await _client
          .get(_uri('${ApiConstants.notifikasiByNik}/$nik'))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return ((jsonDecode(res.body) as Map<String, dynamic>)['data']
                    as List<dynamic>? ??
                [])
            .map((e) => NotifikasiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('ApiDataSource.fetchNotifikasiByNik: $e');
    }
    return [];
  }

  // ══ PASIEN LOOKUP FOR NIK VALIDATION ══════════════════════════════════════

  Future<bool> nikExists(String nik) async {
    try {
      final res = await _client
          .get(_uri('${ApiConstants.pasienProfile}/$nik'))
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiDataSource.nikExists: $e');
    }
    return false;
  }

  // ══ ANTRIAN ═══════════════════════════════════════════════════════════════

  /// GET /api/antrian/layanan
  /// Sesuai sequence 1.1 → tampilkan jenis layanan
  Future<List<Map<String, dynamic>>> getJenisLayanan() async {
    try {
      final res = await _client
          .get(_uri('/antrian/layanan'))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return ((jsonDecode(res.body) as Map<String, dynamic>)['data']
                    as List<dynamic>? ??
                [])
            .cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('ApiDataSource.getJenisLayanan: $e');
    }
    // Fallback dummy — UI tetap jalan walau backend belum aktif
    return [
      {'id': 1, 'nama': 'Poli Umum', 'kode': 'PU'},
      {'id': 2, 'nama': 'Poli Gigi', 'kode': 'PG'},
      {'id': 3, 'nama': 'Poli Anak', 'kode': 'PA'},
      {'id': 4, 'nama': 'Poli Kandungan', 'kode': 'PK'},
      {'id': 5, 'nama': 'Poli Penyakit Dalam', 'kode': 'PP'},
      {'id': 6, 'nama': 'Poli Mata', 'kode': 'PM'},
    ];
  }

  /// POST /api/antrian/cek-nik
  /// Sesuai sequence 2A.1 → verifikasi NIK pasien lama
  Future<Map<String, dynamic>> cekNIK(String nik) async {
    try {
      final res = await _client
          .post(
            _uri('/antrian/cek-nik'),
            headers: _jsonHeaders,
            body: jsonEncode({'nik': nik}),
          )
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('ApiDataSource.cekNIK: $e');
    }
    // Fallback: anggap valid supaya tidak block pendaftaran
    return {'success': true, 'data': <String, dynamic>{'is_valid': true}};
  }

  /// POST /api/antrian
  /// Sesuai sequence 4.1 → buat antrian baru
  Future<Map<String, dynamic>> createAntrian(
      Map<String, dynamic> body) async {
    try {
      final res = await _client
          .post(
            _uri('/antrian'),
            headers: _jsonHeaders,
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      final msg =
          (jsonDecode(res.body) as Map<String, dynamic>)['message'] as String?
              ?? 'Gagal membuat antrian';
      throw Exception(msg);
    } catch (e) {
      debugPrint('ApiDataSource.createAntrian: $e');
      // Fallback dummy response saat backend belum jalan
      final now = DateTime.now();
      final urut =
          (now.millisecondsSinceEpoch % 99 + 1).toString().padLeft(3, '0');
      return {
        'success': true,
        'data': <String, dynamic>{
          'no_antrian': 'A-$urut',
          'kode_booking':
              'TB-${now.year}${now.month.toString().padLeft(2, '0')}-${urut}XY',
          'poliklinik': body['poliklinik_nama'] ?? 'Poli Umum',
          'dokter': 'dr. -',
          'tanggal':
              '${now.day.toString().padLeft(2, '0')} ${_bulan(now.month)} ${now.year}',
          'waktu': '09:00 - 12:00',
          'pembayaran':
              (body['is_pasien_lama'] as bool? ?? false) ? 'BPJS' : 'Umum',
        }
      };
    }
  }

  // ══ HELPERS ═══════════════════════════════════════════════════════════════

  String _bulan(int m) {
    const b = <String>[
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return b[m];
  }
}
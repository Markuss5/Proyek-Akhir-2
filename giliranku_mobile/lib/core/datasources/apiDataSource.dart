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
      // Embed server message in phone field to surface it to the caller.
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
}

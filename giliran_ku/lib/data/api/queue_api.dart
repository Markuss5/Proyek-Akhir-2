import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/poli.dart';
import '../models/ticket.dart';
import 'api_exception.dart';

class QueueApi {
  QueueApi._internal({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  static final QueueApi _instance = QueueApi._internal();

  factory QueueApi() => _instance;

  final http.Client _client;
  final String _baseUrl;

  Future<Ticket> createBpjsTicket(String nikOrBpjs) async {
    final payload = await _post('/tickets/consultation/bpjs', {
      'nik_or_bpjs': nikOrBpjs,
    });
    final data = _dataMap(payload);
    return Ticket.fromJson(data);
  }

  Future<Patient> validateNik(String nik) async {
    final payload = await _post('/patients/validate', {'nik_or_bpjs': nik});
    final data = _dataMap(payload);
    return Patient.fromJson(data);
  }

  Future<List<Poli>> getPoliList() async {
    final payload = await _get('/polis');
    final data = _dataList(payload);
    return data
        .map((item) => Poli.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Doctor>> getDoctors(String poliId) async {
    final payload = await _get(
      '/doctors',
      queryParameters: {'poli_id': poliId},
    );
    final data = _dataList(payload);
    return data
        .map((item) => Doctor.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Ticket> createGeneralTicket({
    required String nik,
    required Poli poli,
    required Doctor doctor,
  }) async {
    final payload = await _post('/tickets/consultation/general', {
      'nik': nik,
      'poli_id': poli.id,
      'doctor_id': doctor.id,
    });
    final data = _dataMap(payload);
    return Ticket.fromJson(data);
  }

  Future<Ticket> getNextPharmacyTicket() async {
    final payload = await _post('/tickets/pharmacy', null);
    final data = _dataMap(payload);
    return Ticket.fromJson(data);
  }

  Future<Ticket> getTicketByBookingCode(String code) async {
    final payload = await _get('/tickets/booking/$code');
    final data = _dataMap(payload);
    return Ticket.fromJson(data);
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    return _request('GET', path, queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic>? body,
  ) async {
    return _request('POST', path, body: body);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    http.Response response;

    if (method == 'GET') {
      response = await _client.get(uri);
    } else if (method == 'POST') {
      response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: body == null ? null : jsonEncode(body),
      );
    } else {
      throw ApiException('Metode HTTP tidak didukung');
    }

    final decoded = _decodeBody(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    }

    final message = _extractError(decoded) ?? 'Gagal memproses permintaan';
    throw ApiException(message);
  }

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final base = Uri.parse(_baseUrl);
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final resolvedPath = '$basePath$normalizedPath';
    return base.replace(path: resolvedPath, queryParameters: queryParameters);
  }

  dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {};
    }
  }

  String? _extractError(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
    }
    return null;
  }

  Map<String, dynamic> _dataMap(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw ApiException('Format data dari server tidak valid');
  }

  List<dynamic> _dataList(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is List) {
      return data;
    }
    return [];
  }
}

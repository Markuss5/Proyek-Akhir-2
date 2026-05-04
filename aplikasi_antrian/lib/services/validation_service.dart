import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/validation_models.dart';

class ValidationService {
  ValidationService._();

  static const Duration _requestTimeout = Duration(seconds: 5);
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8081',
  );

  static final RegExp _nikRegex = RegExp(r'^\d{16}$');
  static final RegExp _bpjsRegex = RegExp(r'^\d{13}$');
  static final RegExp _queueCodeRegex = RegExp(r'^[A-Z0-9]{12}$');

  static Future<NikValidationResponse> validateNik(String nikInput) async {
    final nik = _digitsOnly(nikInput);

    if (!_nikRegex.hasMatch(nik)) {
      return const NikValidationResponse(
        isValid: false,
        message: 'NIK harus terdiri dari 16 digit angka.',
      );
    }

    try {
      final json = await _postJson(
        '/api/v1/validate/nik',
        {'nik': nik},
      );
      return NikValidationResponse.fromJson(json);
    } on TimeoutException {
      return const NikValidationResponse(
        isValid: false,
        message: 'Validasi NIK timeout. Silakan coba lagi.',
      );
    } on _ValidationApiException catch (error) {
      return NikValidationResponse(
        isValid: false,
        message: error.message,
      );
    } catch (_) {
      return const NikValidationResponse(
        isValid: false,
        message: 'Tidak dapat terhubung ke API backend.',
      );
    }
  }

  static Future<BpjsValidationResponse> validateBpjsOrNik(String input) async {
    final cleaned = _digitsOnly(input);

    if (!_nikRegex.hasMatch(cleaned) && !_bpjsRegex.hasMatch(cleaned)) {
      return const BpjsValidationResponse(
        isValid: false,
        message: 'Input harus 16 digit NIK atau 13 digit nomor BPJS.',
      );
    }

    try {
      final json = await _postJson(
        '/api/v1/validate/bpjs-or-nik',
        {'input': cleaned},
      );
      return BpjsValidationResponse.fromJson(json);
    } on TimeoutException {
      return const BpjsValidationResponse(
        isValid: false,
        message: 'Validasi NIK/BPJS timeout. Silakan coba lagi.',
      );
    } on _ValidationApiException catch (error) {
      return BpjsValidationResponse(
        isValid: false,
        message: error.message,
      );
    } catch (_) {
      return const BpjsValidationResponse(
        isValid: false,
        message: 'Tidak dapat terhubung ke API backend.',
      );
    }
  }

  static Future<QueueCodeValidationResponse> validateQueueCode(
    String queueCodeInput,
  ) async {
    final queueCode = queueCodeInput
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (!_queueCodeRegex.hasMatch(queueCode)) {
      return const QueueCodeValidationResponse(
        isValid: false,
        message: 'Kode antrian harus 12 karakter (huruf/angka).',
      );
    }

    try {
      final json = await _postJson(
        '/api/v1/validate/queue-code',
        {'queueCode': queueCode},
      );
      return QueueCodeValidationResponse.fromJson(json);
    } on TimeoutException {
      return const QueueCodeValidationResponse(
        isValid: false,
        message: 'Validasi kode antrian timeout. Silakan coba lagi.',
      );
    } on _ValidationApiException catch (error) {
      return QueueCodeValidationResponse(
        isValid: false,
        message: error.message,
      );
    } catch (_) {
      return const QueueCodeValidationResponse(
        isValid: false,
        message: 'Tidak dapat terhubung ke API backend.',
      );
    }
  }

  static Future<BpjsValidationResponse> generatePharmacyQueue({
    required String patientID,
    required String patientName,
  }) async {
    try {
      final json = await _postJson(
        '/api/v1/pharmacy/queue',
        {
          'patientId': patientID,
          'patientName': patientName,
        },
      );
      return BpjsValidationResponse.fromJson(json);
    } on TimeoutException {
      return const BpjsValidationResponse(
        isValid: false,
        message: 'Generate antrian farmasi timeout. Silakan coba lagi.',
      );
    } on _ValidationApiException catch (error) {
      return BpjsValidationResponse(
        isValid: false,
        message: error.message,
      );
    } catch (_) {
      return const BpjsValidationResponse(
        isValid: false,
        message: 'Tidak dapat terhubung ke API backend.',
      );
    }
  }

  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('$_apiBaseUrl$path');
    final response = await http
        .post(
          uri,
          headers: const {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(payload),
        )
        .timeout(_requestTimeout);

    Map<String, dynamic> jsonBody;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const _ValidationApiException('Response API tidak valid.');
      }
      jsonBody = decoded;
    } on FormatException {
      throw const _ValidationApiException('Response API tidak valid.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody;
    }

    throw _ValidationApiException(
      jsonBody['message']?.toString() ??
          'Server mengembalikan error ${response.statusCode}.',
    );
  }

  static String _digitsOnly(String input) {
    return input.replaceAll(RegExp(r'\D'), '');
  }
}

class _ValidationApiException implements Exception {
  final String message;

  const _ValidationApiException(this.message);
}

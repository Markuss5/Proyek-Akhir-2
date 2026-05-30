import 'package:shared_preferences/shared_preferences.dart';
import 'package:giliranku/core/models/pasienModel.dart';

enum SessionType { none, patient, guest, admin }

class SessionService {
  SessionService._();
  static final SessionService _instance = SessionService._();
  factory SessionService() => _instance;

  static const String _typeKey = 'session_type';
  static const String _nikKey = 'session_nik';
  static const String _nameKey = 'session_name';
  static const String _phoneKey = 'session_phone';
  static const String _bpjsKey = 'session_bpjs';
  static const String _bloodTypeKey = 'session_blood_type';
  static const String _tokenKey = 'session_token';
  static const String _expiryKey = 'session_expiry';

  Future<SessionType> getSessionType() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_typeKey) ?? '';
    
    if (raw == 'patient') {
      final expiryStr = prefs.getString(_expiryKey);
      if (expiryStr != null) {
        final expiryDate = DateTime.tryParse(expiryStr);
        if (expiryDate != null && DateTime.now().isAfter(expiryDate)) {
          await logout();
          return SessionType.none;
        }
      }
      return SessionType.patient;
    }
    
    switch (raw) {
      case 'admin':
        return SessionType.admin;
      case 'guest':
        return SessionType.guest;
      default:
        return SessionType.none;
    }
  }

  Future<PasienModel?> getPatient() async {
    final prefs = await SharedPreferences.getInstance();
    final nik = prefs.getString(_nikKey);
    if (nik == null) return null;
    return PasienModel(
      nik: nik,
      name: prefs.getString(_nameKey) ?? '',
      phone: prefs.getString(_phoneKey),
      bpjs: prefs.getString(_bpjsKey),
      bloodType: prefs.getString(_bloodTypeKey),
    );
  }

  Future<Map<String, dynamic>?> getPatientMap() async {
    final patient = await getPatient();
    if (patient == null) return null;
    return {
      'nik': patient.nik,
      'patient_name': patient.name,
      'phone': patient.phone,
      'bpjs': patient.bpjs,
      'blood_type': patient.bloodType,
    };
  }

  Future<void> savePatientMap(Map<String, dynamic> data, {String? token}) async {
    final patient = PasienModel(
      nik: data['nik'] ?? '',
      name: data['patient_name'] ?? '',
      phone: data['phone'],
      bpjs: data['no_bpjs'] ?? data['bpjs'],
      bloodType: data['golongan_darah'] ?? data['blood_type'],
    );
    await savePatient(patient, token: token);
  }

  Future<void> savePatient(PasienModel patient, {String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_typeKey, 'patient');
    await prefs.setString(_nikKey, patient.nik);
    await prefs.setString(_nameKey, patient.name);
    if (patient.phone != null) await prefs.setString(_phoneKey, patient.phone!);
    if (patient.bpjs != null) await prefs.setString(_bpjsKey, patient.bpjs!);
    if (patient.bloodType != null) {
      await prefs.setString(_bloodTypeKey, patient.bloodType!);
    }
    if (token != null) {
      await prefs.setString(_tokenKey, token);
      final expiryDate = DateTime.now().add(const Duration(days: 7));
      await prefs.setString(_expiryKey, expiryDate.toIso8601String());
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_typeKey, 'guest');
  }

  Future<void> saveAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_typeKey, 'admin');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
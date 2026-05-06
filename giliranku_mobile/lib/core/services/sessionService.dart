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

  Future<SessionType> getSessionType() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_typeKey) ?? '';
    switch (raw) {
      case 'patient':
        return SessionType.patient;
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

  Future<void> savePatientMap(Map<String, dynamic> data) async {
    final patient = PasienModel(
      nik: data['nik'] ?? '',
      name: data['patient_name'] ?? '',
      phone: data['phone'],
      bpjs: data['no_bpjs'] ?? data['bpjs'],
      bloodType: data['golongan_darah'] ?? data['blood_type'],
    );
    await savePatient(patient);
  }

  Future<void> savePatient(PasienModel patient) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_typeKey, 'patient');
    await prefs.setString(_nikKey, patient.nik);
    await prefs.setString(_nameKey, patient.name);
    if (patient.phone != null) await prefs.setString(_phoneKey, patient.phone!);
    if (patient.bpjs != null) await prefs.setString(_bpjsKey, patient.bpjs!);
    if (patient.bloodType != null) {
      await prefs.setString(_bloodTypeKey, patient.bloodType!);
    }
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:giliranku/core/models/pasienModel.dart';

/// Session types stored on-device.
enum SessionType { none, patient, guest, admin }

/// Manages persistent login state using SharedPreferences.
/// Call [SessionService.init()] once in main() before reading the session.
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

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Returns the current session type persisted on disk.
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

  /// Returns the saved patient if session type is [SessionType.patient].
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

  /// Convenience: returns patient data as a raw map (for pages that still use Map).
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

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Persist a patient login session.
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

  /// Persist a guest session (skip-login pressed, remembered).
  Future<void> saveGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_typeKey, 'guest');
  }

  /// Persist an admin session.
  Future<void> saveAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_typeKey, 'admin');
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  /// Clear all session data (logout).
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

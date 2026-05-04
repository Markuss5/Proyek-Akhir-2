class ValidationResponse {
  final bool isValid;
  final String message;

  const ValidationResponse({
    required this.isValid,
    required this.message,
  });
}

class NikValidationResponse extends ValidationResponse {
  final String? patientId;
  final String? queueNumber;
  final String? patientName;

  const NikValidationResponse({
    required super.isValid,
    required super.message,
    this.patientId,
    this.queueNumber,
    this.patientName,
  });

  factory NikValidationResponse.fromJson(Map<String, dynamic> json) {
    return NikValidationResponse(
      isValid: _asBool(json['isValid']),
      message: _asString(json['message']),
      patientId: _asNullableString(json['patientId']),
      queueNumber: _asNullableString(json['queueNumber']),
      patientName: _asNullableString(json['patientName']),
    );
  }
}

class BpjsValidationResponse extends ValidationResponse {
  final String? queueNumber;
  final String? patientName;

  const BpjsValidationResponse({
    required super.isValid,
    required super.message,
    this.queueNumber,
    this.patientName,
  });

  factory BpjsValidationResponse.fromJson(Map<String, dynamic> json) {
    return BpjsValidationResponse(
      isValid: _asBool(json['isValid']),
      message: _asString(json['message']),
      queueNumber: _asNullableString(json['queueNumber']),
      patientName: _asNullableString(json['patientName']),
    );
  }
}

class QueueVerificationData {
  final String queueCode;
  final String queueNumber;
  final String patientName;
  final String clinicName;
  final String doctorName;
  final String scheduleInfo;
  final DateTime createdAt;

  const QueueVerificationData({
    required this.queueCode,
    required this.queueNumber,
    required this.patientName,
    required this.clinicName,
    required this.doctorName,
    required this.scheduleInfo,
    required this.createdAt,
  });

  factory QueueVerificationData.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = _asNullableString(json['createdAt']);
    final parsedCreatedAt = rawCreatedAt == null
        ? DateTime.now()
        : DateTime.tryParse(rawCreatedAt) ?? DateTime.now();

    return QueueVerificationData(
      queueCode: _asString(json['queueCode']),
      queueNumber: _asString(json['queueNumber']),
      patientName: _asString(json['patientName']),
      clinicName: _asString(json['clinicName']),
      doctorName: _asString(json['doctorName']),
      scheduleInfo: _asString(json['scheduleInfo']),
      createdAt: parsedCreatedAt,
    );
  }
}

class QueueCodeValidationResponse extends ValidationResponse {
  final QueueVerificationData? data;

  const QueueCodeValidationResponse({
    required super.isValid,
    required super.message,
    this.data,
  });

  factory QueueCodeValidationResponse.fromJson(Map<String, dynamic> json) {
    final dynamic dataJson = json['data'];

    return QueueCodeValidationResponse(
      isValid: _asBool(json['isValid']),
      message: _asString(json['message']),
      data: dataJson is Map<String, dynamic>
          ? QueueVerificationData.fromJson(dataJson)
          : null,
    );
  }
}

bool _asBool(dynamic value) {
  return value == true;
}

String _asString(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

String? _asNullableString(dynamic value) {
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  if (text.isEmpty) {
    return null;
  }
  return text;
}

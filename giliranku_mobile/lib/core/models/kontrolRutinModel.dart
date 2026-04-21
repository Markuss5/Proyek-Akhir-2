/// Standalone KontrolRutin model (entity + DTO combined).
class KontrolRutinModel {
  final int controlId;
  final String nik;
  final DateTime controlDate;
  final String? notes;
  final DateTime createdAt;

  const KontrolRutinModel({
    required this.controlId,
    required this.nik,
    required this.controlDate,
    this.notes,
    required this.createdAt,
  });

  factory KontrolRutinModel.fromJson(Map<String, dynamic> json) =>
      KontrolRutinModel(
        controlId: json['control_id'] as int,
        nik: json['nik'] as String,
        controlDate: DateTime.parse(json['control_date'] as String),
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'control_id': controlId,
    'nik': nik,
    'control_date': controlDate.toUtc().toIso8601String(),
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };
}

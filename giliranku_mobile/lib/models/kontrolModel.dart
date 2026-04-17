class KontrolRutinModel {
  final int controlId;
  final DateTime controlDate;
  final String? notes;
  final DateTime createdAt;
  final String nik;

  KontrolRutinModel({
    required this.controlId,
    required this.controlDate,
    this.notes,
    required this.createdAt,
    required this.nik,
  });

  factory KontrolRutinModel.fromJson(Map<String, dynamic> json) {
    return KontrolRutinModel(
      controlId: json['control_id'] as int,
      controlDate: DateTime.parse(json['control_date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      nik: json['nik'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'control_id': controlId,
      'control_date':
          '${controlDate.year}-${controlDate.month.toString().padLeft(2, '0')}-${controlDate.day.toString().padLeft(2, '0')}',
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'nik': nik,
    };
  }
}

class Doctor {
  final String id;
  final String name;
  final String poliId;
  final int kuota;

  const Doctor({
    required this.id,
    required this.name,
    required this.poliId,
    this.kuota = 0,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final poliId = json['poly_id']?.toString() ?? json['poliId']?.toString() ?? '';
    return Doctor(
      id: json['doctor_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['doctor_name'] ?? json['name'] ?? '',
      poliId: poliId,
      kuota: json['kuota_non_jkn'] ?? 0,
    );
  }
}
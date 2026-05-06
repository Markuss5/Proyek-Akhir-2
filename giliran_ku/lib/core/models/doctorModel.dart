class Doctor {
  final String id;
  final String name;
  final String poliId;

  const Doctor({
    required this.id,
    required this.name,
    required this.poliId,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final poliId = json['poli_id'] ?? json['poliId'];
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String,
      poliId: poliId as String,
    );
  }
}

class Poli {
  final String id;
  final String name;

  const Poli({
    required this.id,
    required this.name,
  });

  factory Poli.fromJson(Map<String, dynamic> json) {
    return Poli(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

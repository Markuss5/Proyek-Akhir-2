class Patient {
  final String nik;
  final String name;

  const Patient({
    required this.nik,
    required this.name,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? json['patient_name'] ?? json['patientName'];
    return Patient(
      nik: json['nik'] as String,
      name: name as String,
    );
  }
}

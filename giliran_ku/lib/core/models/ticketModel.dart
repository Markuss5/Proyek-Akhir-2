class Ticket {
  final String id;
  final int queueNumber;
  final String? poliQueueCode;
  final String type;
  final String? poliName;
  final String? doctorName;
  final String? patientName; 
  final String? patientNik;
  final String? bookingCode;
  final DateTime createdAt;

  const Ticket({
    required this.id,
    required this.queueNumber,
    this.poliQueueCode,
    required this.type,
    this.poliName,
    this.doctorName,
    this.patientName,
    this.patientNik,
    this.bookingCode,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('queue_number')) {
      final queueNumber = json['queue_number'] as int;
      return Ticket(
        id: json['no_antrian'] ?? 'APT-$queueNumber',
        queueNumber: queueNumber,
        poliQueueCode: json['no_antrian'],
        type: 'farmasi',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
      );
    }

    final noAntrian = json['no_antrian'] ?? '';
    int qNumber = 0;
    if (noAntrian.toString().length > 2) {
      qNumber = int.tryParse(noAntrian.toString().substring(2)) ?? 0;
    }

    return Ticket(
      id: noAntrian,
      queueNumber: qNumber,
      poliQueueCode: noAntrian,
      type: (json['pembayaran'] == 'BPJS') ? 'konsultasi-bpjs' : 'konsultasi-umum',
      poliName: json['poliklinik'],
      doctorName: json['dokter'],
      bookingCode: json['kode_booking'],
      createdAt: DateTime.now(),
    );
  }

  int? get admissionNumber => null;
}

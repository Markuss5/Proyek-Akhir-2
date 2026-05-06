class Ticket {
  final String id;
  final int queueNumber;
  final int? admissionNumber;
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
    required this.admissionNumber,
    required this.poliQueueCode,
    required this.type,
    required this.poliName,
    required this.doctorName,
    required this.patientName,
    required this.patientNik,
    required this.bookingCode,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final poli = json['poli'] as Map<String, dynamic>?;
    final doctor = json['doctor'] as Map<String, dynamic>?;
    final patient = json['patient'] as Map<String, dynamic>?;
    final queueNumber = json['queue_number'] ?? json['queueNumber'];
    final admissionNumber =
        json['admission_number'] ?? json['admissionNumber'];
    final poliQueueCode = json['poli_queue_code'] ?? json['poliQueueCode'];
    final createdAt = json['created_at'] ?? json['createdAt'];
    final bookingCode = json['booking_code'] ?? json['bookingCode'];
    return Ticket(
      id: json['id'] as String,
      queueNumber: queueNumber as int,
      admissionNumber: admissionNumber as int?,
      poliQueueCode: poliQueueCode as String?,
      type: json['type'] as String,
      poliName: (poli ?? const {})['name'] as String?,
      doctorName: (doctor ?? const {})['name'] as String?,
      patientName: (patient ?? const {})['name'] as String?,
      patientNik: (patient ?? const {})['nik'] as String?,
      bookingCode: bookingCode as String?,
      createdAt: DateTime.parse(createdAt as String),
    );
  }
}

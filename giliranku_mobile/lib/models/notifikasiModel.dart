class NotifikasiModel {
  final int notificationId;
  final String message;
  final DateTime scheduledDate;
  final bool isSent;
  final DateTime? sentAt;
  final String nik;

  NotifikasiModel({
    required this.notificationId,
    required this.message,
    required this.scheduledDate,
    required this.isSent,
    this.sentAt,
    required this.nik,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      notificationId: json['notification_id'] as int,
      message: json['message'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      isSent: json['is_sent'] as bool,
      sentAt:
          json['sent_at'] != null ? DateTime.parse(json['sent_at'] as String) : null,
      nik: json['nik'] as String,
    );
  }
}

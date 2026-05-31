class NotifikasiModel {
  final int notificationId;
  final String nik;
  final String message;
  final DateTime scheduledDate;
  final bool isSent;
  final DateTime? sentAt;

  const NotifikasiModel({
    required this.notificationId,
    required this.nik,
    required this.message,
    required this.scheduledDate,
    required this.isSent,
    this.sentAt,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) =>
      NotifikasiModel(
        notificationId: json['notification_id'] as int,
        nik: json['nik'] as String,
        message: json['message'] as String,
        scheduledDate: DateTime.parse(json['scheduled_date'] as String).toLocal(),
        isSent: json['is_sent'] as bool,
        sentAt: json['sent_at'] != null
            ? DateTime.parse(json['sent_at'] as String).toLocal()
            : null,
      );
}
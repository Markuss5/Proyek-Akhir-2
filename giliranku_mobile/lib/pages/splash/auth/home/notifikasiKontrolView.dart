import 'package:flutter/material.dart';
import 'package:giliranku_mobile/services/apiService.dart';

class PatientNotifikasiPage extends StatefulWidget {
  final String? nik;

  const PatientNotifikasiPage({super.key, this.nik});

  @override
  State<PatientNotifikasiPage> createState() => _PatientNotifikasiPageState();
}

class _PatientNotifikasiPageState extends State<PatientNotifikasiPage> {
  String _activeFilter = 'Semua';
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (widget.nik == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final data = await apiService.fetchNotifikasiByNIK(widget.nik!);
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_activeFilter == 'Belum Dibaca') {
      return _notifications.where((n) => n['is_sent'] == false).toList();
    }
    return _notifications;
  }

  // Group notifications by relative date
  Map<String, List<Map<String, dynamic>>> get _groupedNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    final Map<String, List<Map<String, dynamic>>> groups = {};

    for (final n in _filteredNotifications) {
      DateTime? date;
      try {
        date = DateTime.parse(n['scheduled_date'] ?? '');
      } catch (_) {}

      String label;
      if (date == null) {
        label = 'Lainnya';
      } else {
        final d = DateTime(date.year, date.month, date.day);
        if (d == today || d == today.subtract(const Duration(days: 1))) {
          label = 'Hari Ini';
        } else if (d.isAfter(weekAgo)) {
          label = 'Minggu Ini';
        } else {
          label = 'Sebelumnya';
        }
      }

      groups.putIfAbsent(label, () => []);
      groups[label]!.add(n);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // AppBar-style header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF2F9E8F),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Notifikasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.white, size: 24),
              ],
            ),
          ),

          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('Semua'),
                const SizedBox(width: 12),
                _buildFilterChip('Belum Dibaca'),
              ],
            ),
          ),

          // Notification list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2F9E8F)))
                : _filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadNotifications,
                        color: const Color(0xFF2F9E8F),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          children: _buildGroupedList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedList() {
    final groups = _groupedNotifications;
    final List<Widget> widgets = [];

    // Ordered labels
    for (final label in ['Hari Ini', 'Minggu Ini', 'Sebelumnya', 'Lainnya']) {
      if (groups.containsKey(label)) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        );
        for (final n in groups[label]!) {
          widgets.add(_buildNotificationCard(n));
        }
      }
    }

    return widgets;
  }

  Widget _buildFilterChip(String label) {
    final isActive = _activeFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2F9E8F) : Colors.grey[200],
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final message = notification['message'] ?? '';
    final scheduledDate = notification['scheduled_date'] ?? '';
    final isSent = notification['is_sent'] ?? false;

    // Parse title + body from message
    String title = 'Pengingat Kontrol';
    String body = message;

    // Try to extract a meaningful title from the message
    if (message.contains('H-7')) {
      title = 'Pengingat Pemeriksaan Rutin';
      body = 'Waktu pemeriksaan rutin Anda akan segera tiba. Disarankan untuk menyiapkan pertanyaan terkait kondisi kesehatan Anda.';
    } else if (message.contains('H-3')) {
      title = 'Pengingat Kontrol Lanjutan';
      body = 'Waktunya melakukan kontrol lanjutan sesuai anjuran dokter. Silakan melakukan pengambilan antrian melalui aplikasi.';
    } else if (message.contains('H-1')) {
      title = 'Pengingat Pemeriksaan Berkala';
      body = 'Anda dijadwalkan untuk pemeriksaan berkala. Disarankan untuk menjaga kondisi tubuh dan beristirahat cukup sebelum pemeriksaan.';
    }

    // Format time from scheduled date
    String timeStr = '';
    try {
      final date = DateTime.parse(scheduledDate);
      timeStr = '${date.day} ${_monthName(date.month)}';
    } catch (_) {
      timeStr = scheduledDate;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSent
              ? Colors.grey.withValues(alpha: 0.2)
              : const Color(0xFF2F9E8F).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stethoscope icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD7EDEB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: Color(0xFF2F9E8F),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      isSent ? Icons.check_circle : Icons.calendar_today,
                      size: 14,
                      color: isSent ? Colors.green : const Color(0xFF2F9E8F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      scheduledDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSent ? Colors.green : const Color(0xFF2F9E8F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            widget.nik == null
                ? 'Masuk untuk melihat notifikasi'
                : 'Belum ada notifikasi',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }
}

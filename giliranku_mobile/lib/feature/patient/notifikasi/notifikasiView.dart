import 'package:flutter/material.dart';
import 'package:giliranku/core/repositories/notifikasiRepository.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/models/notifikasiModel.dart';
import 'package:giliranku/core/widgets/header.dart';

class NotifikasiView extends StatefulWidget {
  final String? nik;

  const NotifikasiView({super.key, this.nik});

  @override
  State<NotifikasiView> createState() => _NotifikasiViewState();
}

class _NotifikasiViewState extends State<NotifikasiView> {
  String _activeFilter = 'Akan Datang';
  List<NotifikasiModel> _notifications = [];
  bool _isLoading = true;

  bool _isSelecting = false;
  final Set<int> _selectedIds = {};

  late final _refreshTimer = _startRefreshTimer();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  _startRefreshTimer() {
    return Stream.periodic(const Duration(seconds: 30)).listen((_) {
      if (mounted) _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    if (widget.nik == null) {
      setState(() => _isLoading = false);
      return;
    }
    if (!_isLoading) {
    } else {
      setState(() => _isLoading = true);
    }
    try {
      final data = await NotifikasiRepository().getByNik(widget.nik!);
      if (!mounted) return;
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<NotifikasiModel> get _filteredNotifications {
    final now = DateTime.now();
    if (_activeFilter == 'Akan Datang') {
      return _notifications.where((n) => !n.scheduledDate.toLocal().isBefore(now)).toList();
    } else {
      return _notifications.where((n) => n.scheduledDate.toLocal().isBefore(now)).toList();
    }
  }

  bool get _isSelesaiTab => _activeFilter == 'Selesai';

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelecting = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _startSelection(int id) {
    if (!_isSelesaiTab) return;
    setState(() {
      _isSelecting = true;
      _selectedIds.add(id);
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds.addAll(_filteredNotifications.map((n) => n.notificationId));
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Hapus $count notifikasi yang dipilih?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    int deleted = 0;
    for (final id in _selectedIds.toList()) {
      final success = await ApiDataSource().deleteNotifikasi(id);
      if (success) deleted++;
    }

    if (!mounted) return;

    setState(() {
      _notifications.removeWhere((n) => _selectedIds.contains(n.notificationId));
      _selectedIds.clear();
      _isSelecting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$deleted notifikasi berhasil dihapus'),
        backgroundColor: const Color(0xFF2F9E8F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          AppHeader(
            mode: HeaderMode.page,
            title: 'Notifikasi Kontrol',
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: _isSelecting
                ? Row(
                    children: [
                      GestureDetector(
                        onTap: _cancelSelection,
                        child: const Icon(Icons.close, color: Colors.black54),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedIds.length} dipilih',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _selectAll,
                        child: const Text(
                          'Pilih Semua',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF2F9E8F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _deleteSelected,
                        child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      _buildFilterChip('Akan Datang'),
                      const SizedBox(width: 12),
                      _buildFilterChip('Selesai'),
                    ],
                  ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2F9E8F)),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    color: const Color(0xFF2F9E8F),
                    child: _filteredNotifications.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.4,
                                child: _buildEmptyState(),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: _filteredNotifications.length,
                            itemBuilder: (context, index) {
                              final n = _filteredNotifications[index];
                              return _buildNotificationCard(n);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isActive = _activeFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeFilter = label;
            _isSelecting = false;
            _selectedIds.clear();
          });
          _loadNotifications();
        },
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

  Widget _buildNotificationCard(NotifikasiModel notification) {
    final message = notification.message;
    final scheduledDate = notification.scheduledDate.toLocal();
    final isSelected = _selectedIds.contains(notification.notificationId);

    String title = 'Pengingat Kontrol';
    String body = message;
    if (message.contains('H-0')) {
      title = 'Kontrol 1 Jam Lagi!';
      body = 'Segera menuju RSUD Porsea untuk melakukan kontrol rutin.';
    } else if (message.contains('H-7')) {
      title = 'Pengingat Kontrol Lanjutan';
      body = 'Waktu pemeriksaan rutin Anda akan segera tiba.';
    } else if (message.contains('H-3')) {
      title = 'Pengingat Kontrol Lanjutan';
      body = 'Waktu pemeriksaan rutin Anda akan segera tiba.';
    } else if (message.contains('H-1')) {
      title = 'Pengingat Kontrol Lanjutan';
      body = 'Anda dijadwalkan untuk melakukan pemeriksaan besok.';
    }

    final timeStr = '${scheduledDate.day} ${_monthName(scheduledDate.month)}';
    final dateLabel =
        '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year} '
        '${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}';

    final isPast = scheduledDate.isBefore(DateTime.now());

    return GestureDetector(
      onLongPress: _isSelesaiTab && !_isSelecting
          ? () => _startSelection(notification.notificationId)
          : null,
      onTap: _isSelecting && _isSelesaiTab
          ? () => _toggleSelect(notification.notificationId)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5F3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2F9E8F)
                : isPast
                    ? Colors.grey.withValues(alpha: 0.2)
                    : const Color(0xFF2F9E8F).withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSelecting && _isSelesaiTab) ...[
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 12),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? const Color(0xFF2F9E8F) : Colors.grey[400],
                  size: 22,
                ),
              ),
            ] else ...[
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
            ],
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                        isPast ? Icons.check_circle : Icons.calendar_today,
                        size: 14,
                        color: isPast ? Colors.green : const Color(0xFF2F9E8F),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: isPast ? Colors.green : const Color(0xFF2F9E8F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            widget.nik == null
                ? 'Masuk untuk melihat notifikasi'
                : _activeFilter == 'Akan Datang'
                    ? 'Anda belum memiliki jadwal kontrol'
                    : 'Belum ada data kontrol yang selesai',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return months[month - 1];
  }
}
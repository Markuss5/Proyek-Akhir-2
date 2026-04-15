import 'package:flutter/material.dart';
import 'package:giliranku/services/notification_service.dart';

class NotifikasiKontrolPage extends StatefulWidget {
  const NotifikasiKontrolPage({super.key});

  @override
  State<NotifikasiKontrolPage> createState() => _NotifikasiKontrolPageState();
}

class _NotifikasiKontrolPageState extends State<NotifikasiKontrolPage> {
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  DateTime? _selectedDate;
  final NotificationService _notificationService = NotificationService();
  final List<Map<String, dynamic>> _scheduledKontrol = [];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2F9E8F)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _scheduleKontrol() async {
    if (_nikController.text.isEmpty || _namaController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon isi NIK, Nama, dan Tanggal Kontrol"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Generate a simple control ID based on timestamp
    final controlId = DateTime.now().millisecondsSinceEpoch % 100000;

    // Schedule local notifications (H-7, H-3, H-1)
    await _notificationService.scheduleKontrolRutinReminders(
      controlId: controlId,
      controlDate: _selectedDate!,
      patientName: _namaController.text,
      notes: _catatanController.text.isNotEmpty ? _catatanController.text : null,
    );

    // Add to local list for display
    setState(() {
      _scheduledKontrol.insert(0, {
        'id': controlId,
        'nik': _nikController.text,
        'nama': _namaController.text,
        'tanggal': _selectedDate!,
        'catatan': _catatanController.text,
      });
    });

    // Clear form
    _nikController.clear();
    _namaController.clear();
    _catatanController.clear();
    setState(() => _selectedDate = null);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Jadwal kontrol berhasil dibuat! Notifikasi H-7, H-3, dan H-1 dijadwalkan."),
          backgroundColor: Color(0xFF2F9E8F),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F9E8F),
        foregroundColor: Colors.white,
        title: const Text("Notifikasi Kontrol Rutin"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Jadwalkan Kontrol Rutin",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Notifikasi akan dikirim H-7, H-3, dan H-1 sebelum jadwal",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 20),

                  _buildFormField("NIK Pasien", "Masukkan 16 digit NIK", _nikController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildFormField("Nama Pasien", "Masukkan nama lengkap", _namaController),
                  const SizedBox(height: 16),

                  // Date picker
                  const Text("Tanggal Kontrol",
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF2F9E8F), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? _formatDate(_selectedDate!)
                                : "Pilih tanggal kontrol",
                            style: TextStyle(
                              color: _selectedDate != null ? Colors.black : Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFormField("Catatan (opsional)", "Catatan kontrol", _catatanController,
                      maxLines: 2),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F9E8F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.notifications_active),
                      label: const Text("Jadwalkan & Kirim Notifikasi", style: TextStyle(fontSize: 15)),
                      onPressed: _scheduleKontrol,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Scheduled list
            if (_scheduledKontrol.isNotEmpty) ...[
              const Text(
                "Kontrol Terjadwal",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._scheduledKontrol.map((item) => _buildKontrolCard(item)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2F9E8F), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildKontrolCard(Map<String, dynamic> item) {
    final tanggal = item['tanggal'] as DateTime;
    final daysLeft = tanggal.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF2F9E8F).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD7EDEB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event, color: Color(0xFF2F9E8F)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("NIK: ${item['nik']}", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                Text(_formatDate(tanggal), style: const TextStyle(color: Color(0xFF2F9E8F), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: daysLeft <= 1 ? Colors.red[50] : const Color(0xFFD7EDEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "H-$daysLeft",
              style: TextStyle(
                color: daysLeft <= 1 ? Colors.red : const Color(0xFF2F9E8F),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

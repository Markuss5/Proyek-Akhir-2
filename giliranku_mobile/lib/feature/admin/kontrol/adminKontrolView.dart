import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/repositories/kontrolRutinRepository.dart';
import 'package:giliranku/core/services/notificationService.dart';
import 'package:giliranku/feature/admin/adminHeader.dart';

class KontrolItem {
  final int? controlId;
  final String nik;
  final String nama;
  final String poliklinik;
  final String dokter;
  final DateTime tanggal;
  final TimeOfDay waktu;
  final String status;

  KontrolItem({
    this.controlId,
    required this.nik,
    required this.nama,
    required this.poliklinik,
    required this.dokter,
    required this.tanggal,
    required this.waktu,
    this.status = 'terjadwal',
  });

  factory KontrolItem.fromApiJson(Map<String, dynamic> json) {
    final dateStr = json['control_date'] ?? '';
    DateTime date;
    try {
      date = DateTime.parse(dateStr);
    } catch (_) {
      date = DateTime.now();
    }

    final notes = (json['notes'] ?? '') as String;
    final parts = notes.split(' - ');
    final poli = parts.isNotEmpty ? parts[0] : '';
    final dokter = parts.length > 1 ? parts[1] : '';

    return KontrolItem(
      controlId: json['control_id'],
      nik: json['nik'] ?? '',
      nama: json['nik'] ?? '',
      poliklinik: poli,
      dokter: dokter,
      tanggal: date,
      waktu: TimeOfDay(
        hour: date.toLocal().hour,
        minute: date.toLocal().minute,
      ),
      status: date.isBefore(DateTime.now()) ? 'selesai' : 'terjadwal',
    );
  }

  factory KontrolItem.fromEntity(dynamic entity) {
    final date = (entity.controlDate as DateTime).toLocal();
    final notes = (entity.notes ?? '') as String;
    final parts = notes.split(' - ');
    final poli = parts.isNotEmpty ? parts[0] : '';
    final dokter = parts.length > 1 ? parts[1] : '';

    return KontrolItem(
      controlId: entity.controlId as int?,
      nik: entity.nik as String,
      nama: entity.nik as String,
      poliklinik: poli,
      dokter: dokter,
      tanggal: date,
      waktu: TimeOfDay(hour: date.hour, minute: date.minute),
      status: date.isBefore(DateTime.now()) ? 'selesai' : 'terjadwal',
    );
  }
}

class AdminKontrolView extends StatefulWidget {
  const AdminKontrolView({super.key});

  @override
  State<AdminKontrolView> createState() => _AdminKontrolViewState();
}

class _AdminKontrolViewState extends State<AdminKontrolView> {
  String _activeFilter = 'Semua';
  List<KontrolItem> _kontrolList = [];
  bool _isLoading = true;
  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await KontrolRutinRepository().getAll();
      setState(() {
        _kontrolList = data.map((e) => KontrolItem.fromEntity(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading kontrol data: $e');
    }
  }

  List<KontrolItem> get _filteredList {
    if (_activeFilter == 'Terjadwal') {
      return _kontrolList.where((e) => e.status == 'terjadwal').toList();
    } else if (_activeFilter == 'Selesai') {
      return _kontrolList.where((e) => e.status == 'selesai').toList();
    }
    return _kontrolList;
  }

  int get _terjadwalCount =>
      _kontrolList.where((e) => e.status == 'terjadwal').length;
  int get _selesaiCount =>
      _kontrolList.where((e) => e.status == 'selesai').length;

  void _cancelSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds.addAll(
        _filteredList.where((e) => e.controlId != null).map((e) => e.controlId!),
      );
    });
  }

  void _showAddDialog() async {
    final nikCtrl = TextEditingController();
    final namaCtrl = TextEditingController();

    List<Map<String, dynamic>> poliList = [];
    List<Map<String, dynamic>> dokterList = [];
    Map<String, dynamic>? selectedPoli;
    Map<String, dynamic>? selectedDokter;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    bool isLoadingDokter = false;

    try {
      poliList = await ApiDataSource().fetchPoliklinik();
    } catch (e) {
      poliList = [];
    }
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 40,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F9E8F),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Tambah Jadwal Kontrol",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dialogTextField(
                            nikCtrl,
                            "NIK Pasien (16 digit)",
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            maxLength: 16,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                          const SizedBox(height: 14),
                          _dialogTextField(
                            namaCtrl,
                            "Nama Pasien",
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 14),

                          _dropdownContainer(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Map<String, dynamic>>(
                                isExpanded: true,
                                hint: Row(
                                  children: [
                                    Icon(Icons.local_hospital_outlined,
                                        size: 18, color: Colors.grey[400]),
                                    const SizedBox(width: 10),
                                    Text("Poliklinik",
                                        style: TextStyle(
                                            color: Colors.grey[400])),
                                  ],
                                ),
                                value: selectedPoli,
                                items: poliList.map((poli) {
                                  return DropdownMenuItem<
                                      Map<String, dynamic>>(
                                    value: poli,
                                    child: Text(poli['poly_name'] ?? ''),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedPoli = val;
                                    selectedDokter = null;
                                    dokterList = [];
                                    isLoadingDokter = true;
                                  });
                                  if (val != null) {
                                    try {
                                      final doks = ApiDataSource()
                                          .fetchDokterByPoly(val['poly_id']);
                                      doks.then((data) {
                                        if (!mounted) return;
                                        setDialogState(() {
                                          dokterList = data;
                                          isLoadingDokter = false;
                                        });
                                      });
                                    } catch (e) {
                                      if (!mounted) return;
                                      setDialogState(() {
                                        dokterList = [];
                                        isLoadingDokter = false;
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          _dropdownContainer(
                            child: isLoadingDokter
                                ? const Padding(
                                    padding: EdgeInsets.all(14),
                                    child: Center(
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF2F9E8F),
                                        ),
                                      ),
                                    ),
                                  )
                                : DropdownButtonHideUnderline(
                                    child: DropdownButton<
                                        Map<String, dynamic>>(
                                      isExpanded: true,
                                      hint: Row(
                                        children: [
                                          Icon(Icons.medical_services_outlined,
                                              size: 18,
                                              color: Colors.grey[400]),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              selectedPoli == null
                                                  ? "Pilih poliklinik dulu"
                                                  : "Nama Dokter",
                                              style: TextStyle(
                                                  color: Colors.grey[400]),
                                            ),
                                          ),
                                        ],
                                      ),
                                      value: selectedDokter,
                                      items: dokterList.map((doc) {
                                        return DropdownMenuItem<
                                            Map<String, dynamic>>(
                                          value: doc,
                                          child:
                                              Text(doc['doctor_name'] ?? ''),
                                        );
                                      }).toList(),
                                      onChanged: selectedPoli == null
                                          ? null
                                          : (val) => setDialogState(
                                              () => selectedDokter = val),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 14),

                          _pickerField(
                            icon: Icons.calendar_today_outlined,
                            label: selectedDate != null
                                ? "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}"
                                : "Pilih Tanggal",
                            hasValue: selectedDate != null,
                            onTap: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: now.add(const Duration(days: 7)),
                                firstDate: now,
                                lastDate: DateTime(now.year + 2),
                                builder: (c, child) => Theme(
                                  data: Theme.of(c).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF2F9E8F),
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setDialogState(() => selectedDate = picked);
                              }
                            },
                          ),
                          const SizedBox(height: 14),

                          _pickerField(
                            icon: Icons.access_time_rounded,
                            label: selectedTime != null
                                ? "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}"
                                : "Pilih Waktu",
                            hasValue: selectedTime != null,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime:
                                    const TimeOfDay(hour: 9, minute: 0),
                                builder: (c, child) => Theme(
                                  data: Theme.of(c).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF2F9E8F),
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setDialogState(() => selectedTime = picked);
                              }
                            },
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2F9E8F),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                if (nikCtrl.text.isEmpty ||
                                    namaCtrl.text.isEmpty ||
                                    selectedPoli == null ||
                                    selectedDokter == null ||
                                    selectedDate == null ||
                                    selectedTime == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Mohon lengkapi semua data"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final nikText = nikCtrl.text.trim();
                                if (nikText.length != 16 ||
                                    double.tryParse(nikText) == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "NIK harus terdiri dari tepat 16 digit angka."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final poliName =
                                    selectedPoli!['poly_name'] ?? '';
                                final dokterName =
                                    selectedDokter!['doctor_name'] ?? '';
                                final exactDateTime = DateTime(
                                  selectedDate!.year,
                                  selectedDate!.month,
                                  selectedDate!.day,
                                  selectedTime!.hour,
                                  selectedTime!.minute,
                                );

                                final entity =
                                    await KontrolRutinRepository().create(
                                  nik: nikText,
                                  controlDate: exactDateTime,
                                  notes: "$poliName - $dokterName",
                                );
                                final success = entity != null;

                                if (success) {
                                  final cId = entity.controlId;
                                  await NotificationService()
                                      .scheduleKontrolRutinReminders(
                                    controlId: cId,
                                    controlDate: exactDateTime,
                                    patientName: nikText,
                                    notes: "$poliName - $dokterName",
                                  );
                                  Navigator.pop(ctx);
                                  _loadData();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Jadwal kontrol berhasil! Notifikasi H-7, H-3, H-1 dijadwalkan."),
                                        backgroundColor: Color(0xFF2F9E8F),
                                      ),
                                    );
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Gagal membuat jadwal. Pastikan NIK terdaftar di database."),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                "Simpan Jadwal",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _dropdownContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }

  Widget _pickerField({
    required IconData icon,
    required String label,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[500]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: hasValue ? Colors.black87 : Colors.grey[500],
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _dialogTextField(
    TextEditingController controller,
    String hint, {
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: Colors.grey[500])
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2F9E8F), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        counterText: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          AdminHeader(
            type: AdminHeaderType.page,
            pageTitle: "Notifikasi Kontrol",
          ),
          if (_selectionMode)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
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
                    onTap: _deleteSelectedControls,
                    child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2F9E8F),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: const Color(0xFF2F9E8F),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            _buildSummaryCard(),

                            Padding(
                              padding: const EdgeInsets.only(top: 12, bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _activeFilter == 'Semua'
                                        ? "Semua Jadwal (${_kontrolList.length})"
                                        : "$_activeFilter (${_filteredList.length})",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (_filteredList.isEmpty)
                              _buildEmptyState()
                            else
                              ..._filteredList
                                  .map((item) => _buildKontrolCard(item)),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(
              onPressed: _showAddDialog,
              backgroundColor: const Color(0xFF2F9E8F),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8,
        ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatBadge(
                icon: Icons.access_time_rounded,
                count: _terjadwalCount,
                label: "Terjadwal",
                bgColor: const Color(0xFFFFF8E1),
                iconColor: Colors.amber[700]!,
              ),
              const SizedBox(width: 12),
              _buildStatBadge(
                icon: Icons.check_circle_rounded,
                count: _selesaiCount,
                label: "Selesai",
                bgColor: const Color(0xFFE8F5E9),
                iconColor: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatBadge(
                icon: Icons.list_alt_rounded,
                count: _kontrolList.length,
                label: "Total",
                bgColor: const Color(0xFFE8F4FD),
                iconColor: const Color(0xFF2196F3),
              ),
            ],
          ),
          const SizedBox(height: 18),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Semua', 'Terjadwal', 'Selesai'].map((filter) {
                final isActive = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF2F9E8F)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF2F9E8F)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required int count,
    required String label,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(
              "$count",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_busy_rounded,
                  size: 48, color: Colors.grey[350]),
            ),
            const SizedBox(height: 16),
            Text(
              "Belum ada jadwal kontrol",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Tap tombol + untuk menambah jadwal",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSelectedControls() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Hapus ${_selectedIds.length} Jadwal"),
        content: Text(
            "Yakin ingin menghapus ${_selectedIds.length} jadwal kontrol yang dipilih?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isLoading = true);

    int successCount = 0;
    for (int id in _selectedIds) {
      final success = await KontrolRutinRepository().delete(id);
      if (success) {
        successCount++;
        await NotificationService().cancelKontrolRutinReminders(id);
      }
    }

    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$successCount jadwal berhasil dihapus"),
          backgroundColor:
              successCount > 0 ? const Color(0xFF2F9E8F) : Colors.red,
        ),
      );
    }
  }

  Widget _buildKontrolCard(KontrolItem item) {
    final isSelesai = item.status == 'selesai';
    final isSelected = _selectedIds.contains(item.controlId);

    final tanggalStr =
        "${item.tanggal.day.toString().padLeft(2, '0')}/${item.tanggal.month.toString().padLeft(2, '0')}/${item.tanggal.year}";
    final waktuStr =
        "${item.waktu.hour.toString().padLeft(2, '0')}:${item.waktu.minute.toString().padLeft(2, '0')}";

    return GestureDetector(
      onLongPress: () {
        if (item.controlId != null) {
          setState(() {
            _selectionMode = true;
            _selectedIds.add(item.controlId!);
          });
        }
      },
      onTap: () {
        if (_selectionMode && item.controlId != null) {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(item.controlId!);
              if (_selectedIds.isEmpty) _selectionMode = false;
            } else {
              _selectedIds.add(item.controlId!);
            }
          });
        }
      },
      child: Stack(
        children: [
          Dismissible(
            key: Key(item.controlId?.toString() ?? item.hashCode.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.delete_rounded, color: Colors.white, size: 24),
                  SizedBox(height: 4),
                  Text("Hapus",
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text("Hapus Jadwal"),
                  content: const Text(
                      "Yakin ingin menghapus jadwal kontrol ini?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text("Hapus",
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) async {
              if (item.controlId != null) {
                final success =
                    await KontrolRutinRepository().delete(item.controlId!);
                if (success) {
                  await NotificationService()
                      .cancelKontrolRutinReminders(item.controlId!);
                  setState(() {
                    _kontrolList
                        .removeWhere((k) => k.controlId == item.controlId);
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Jadwal berhasil dihapus"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Gagal menghapus jadwal"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelesai
                      ? Colors.green.withValues(alpha: 0.25)
                      : const Color(0xFF2F9E8F).withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelesai
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSelesai
                          ? Icons.check_circle_rounded
                          : Icons.notifications_active_rounded,
                      color: isSelesai ? Colors.green : Colors.amber[700],
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NIK: ${item.nik}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (item.poliklinik.isNotEmpty ||
                            item.dokter.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            "${item.poliklinik}${item.dokter.isNotEmpty ? ' · ${item.dokter}' : ''}",
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(tanggalStr,
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12)),
                            const SizedBox(width: 10),
                            Icon(Icons.access_time_rounded,
                                size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(waktuStr,
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelesai
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isSelesai ? "Selesai" : "Terjadwal",
                      style: TextStyle(
                        color: isSelesai ? Colors.green : Colors.amber[800],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isSelected)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F9E8F).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: const Color(0xFF2F9E8F), width: 2),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2F9E8F), size: 36),
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/repositories/kontrolRutinRepository.dart';
import 'package:giliranku/core/services/notificationService.dart';

class KontrolItem {
  final int? controlId;
  final String nik;
  final String nama;
  final String poliklinik;
  final String dokter;
  final DateTime tanggal;
  final TimeOfDay waktu;
  final String status; // 'terjadwal' or 'selesai'

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
    // notes format: "PoliName - DoctorName"
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

  /// Build a [KontrolItem] from a domain entity returned by Use Cases.
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

  void _showAddDialog() async {
    final nikCtrl = TextEditingController();
    final namaCtrl = TextEditingController();

    // Pre-load polyclinics before showing dialog
    List<Map<String, dynamic>> poliList = [];
    List<Map<String, dynamic>> dokterList = [];
    Map<String, dynamic>? selectedPoli;
    Map<String, dynamic>? selectedDokter;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    bool isLoadingDokter = false;

    // Fetch poli data once before showing dialog
    poliList = await ApiDataSource().fetchPoliklinik();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 40,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tambah Jadwal Kontrol",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: const Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // NIK
                      _dialogTextField(
                        nikCtrl,
                        "NIK Pasien (16 digit)",
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),

                      // Nama Pasien
                      _dialogTextField(namaCtrl, "Nama Pasien"),
                      const SizedBox(height: 14),

                      // Poliklinik Dropdown
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Map<String, dynamic>>(
                            isExpanded: true,
                            hint: Text(
                              "Poliklinik",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            value: selectedPoli,
                            items: poliList.map((poli) {
                              return DropdownMenuItem<Map<String, dynamic>>(
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
                              // Fetch doctors for selected poli
                              if (val != null) {
                                ApiDataSource()
                                    .fetchDokterByPoly(val['poly_id'])
                                    .then((data) {
                                      setDialogState(() {
                                        dokterList = data;
                                        isLoadingDokter = false;
                                      });
                                    });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Dokter Dropdown
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: isLoadingDokter
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<Map<String, dynamic>>(
                                  isExpanded: true,
                                  hint: Text(
                                    selectedPoli == null
                                        ? "Pilih poliklinik terlebih dahulu"
                                        : "Nama Dokter",
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                  value: selectedDokter,
                                  items: dokterList.map((doc) {
                                    return DropdownMenuItem<
                                      Map<String, dynamic>
                                    >(
                                      value: doc,
                                      child: Text(doc['doctor_name'] ?? ''),
                                    );
                                  }).toList(),
                                  onChanged: selectedPoli == null
                                      ? null
                                      : (val) {
                                          setDialogState(
                                            () => selectedDokter = val,
                                          );
                                        },
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),

                      // Date picker
                      GestureDetector(
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
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selectedDate != null
                                      ? "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}"
                                      : "dd/mm/yyyy",
                                  style: TextStyle(
                                    color: selectedDate != null
                                        ? Colors.black
                                        : Colors.grey[500],
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Time picker
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: const TimeOfDay(hour: 9, minute: 0),
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
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selectedTime != null
                                      ? "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}"
                                      : "--:--",
                                  style: TextStyle(
                                    color: selectedTime != null
                                        ? Colors.black
                                        : Colors.grey[500],
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.access_time,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F9E8F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                                  content: Text("Mohon lengkapi semua data"),
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
                                    "NIK harus terdiri dari tepat 16 digit angka.",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final poliName = selectedPoli!['poly_name'] ?? '';
                            final dokterName =
                                selectedDokter!['doctor_name'] ?? '';

                            final exactDateTime = DateTime(
                              selectedDate!.year,
                              selectedDate!.month,
                              selectedDate!.day,
                              selectedTime!.hour,
                              selectedTime!.minute,
                            );

                            // Schedule via domain use case — sends UTC ISO-8601 internally
                            final entity = await KontrolRutinRepository()
                                .create(
                                  nik: nikText,
                                  controlDate: exactDateTime,
                                  notes: "$poliName - $dokterName",
                                );
                            final success = entity != null;

                            if (success) {
                              // Schedule local phone notifications (H-7, H-3, H-1)
                              final cId = entity.controlId;
                              await NotificationService()
                                  .scheduleKontrolRutinReminders(
                                    controlId: cId,
                                    controlDate: exactDateTime,
                                    patientName: nikText,
                                    notes: "$poliName - $dokterName",
                                  );

                              Navigator.pop(ctx);
                              // Reload data from API
                              _loadData();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Jadwal kontrol berhasil! Notifikasi H-7, H-3, H-1 dijadwalkan.",
                                    ),
                                    backgroundColor: Color(0xFF2F9E8F),
                                  ),
                                );
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Gagal membuat jadwal. Pastikan NIK terdaftar di database.",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            "Simpan Jadwal",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dialogTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header with logo
          Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scaleX: 1.5,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F9E8F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(180),
                      bottomRight: Radius.circular(180),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      "GiliranKu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2F9E8F)),
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
                            Transform.translate(
                              offset: const Offset(0, -25),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title + Button
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Notifikasi Kontrol",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "Jadwal kontrol rutin pasien",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2F9E8F,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: _showAddDialog,
                                          child: const Text(
                                            "+ Jadwal",
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Stats
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF8E1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  color: Colors.amber[700],
                                                  size: 22,
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "$_terjadwalCount",
                                                      style: const TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Terjadwal",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E9),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 22,
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "$_selesaiCount",
                                                      style: const TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Selesai",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Filter chips
                                    Row(
                                      children: ['Semua', 'Terjadwal', 'Selesai']
                                          .map(
                                            (filter) => Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              child: GestureDetector(
                                                onTap: () => setState(
                                                  () => _activeFilter = filter,
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        _activeFilter == filter
                                                        ? const Color(
                                                            0xFF2F9E8F,
                                                          )
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          _activeFilter ==
                                                              filter
                                                          ? const Color(
                                                              0xFF2F9E8F,
                                                            )
                                                          : Colors
                                                                .grey
                                                                .shade300,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    filter,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          _activeFilter ==
                                                              filter
                                                          ? Colors.white
                                                          : Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Kontrol list
                            if (_filteredList.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 60,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Belum ada jadwal kontrol",
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ..._filteredList.map(
                                (item) => _buildKontrolCard(item),
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _selectionMode
          ? FloatingActionButton.extended(
              onPressed: () => _deleteSelectedControls(),
              backgroundColor: Colors.red,
              icon: const Icon(Icons.delete, color: Colors.white),
              label: Text(
                "Hapus (${_selectedIds.length})",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _deleteSelectedControls() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Hapus ${_selectedIds.length} Jadwal"),
        content: Text(
          "Yakin ingin menghapus ${_selectedIds.length} jadwal kontrol yang dipilih?",
        ),
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
          backgroundColor: successCount > 0
              ? const Color(0xFF2F9E8F)
              : Colors.red,
        ),
      );
    }
  }

  Widget _buildKontrolCard(KontrolItem item) {
    final isSelesai = item.status == 'selesai';
    final isSelected = _selectedIds.contains(item.controlId);

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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Hapus Jadwal"),
                  content: const Text(
                    "Yakin ingin menghapus jadwal kontrol ini?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text(
                        "Hapus",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) async {
              if (item.controlId != null) {
                final success = await KontrolRutinRepository().delete(
                  item.controlId!,
                );
                if (success) {
                  await NotificationService().cancelKontrolRutinReminders(
                    item.controlId!,
                  );
                  setState(() {
                    _kontrolList.removeWhere(
                      (k) => k.controlId == item.controlId,
                    );
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
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelesai
                      ? Colors.green.withValues(alpha: 0.3)
                      : const Color(0xFF2F9E8F).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelesai
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isSelesai
                          ? Icons.check_circle
                          : Icons.notifications_active,
                      color: isSelesai ? Colors.green : Colors.amber[700],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        const SizedBox(height: 2),
                        if (item.poliklinik.isNotEmpty ||
                            item.dokter.isNotEmpty)
                          Text(
                            "${item.poliklinik}${item.dokter.isNotEmpty ? ' · ${item.dokter}' : ''}",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${item.tanggal.year}-${item.tanggal.month.toString().padLeft(2, '0')}-${item.tanggal.day.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${item.waktu.hour.toString().padLeft(2, '0')}:${item.waktu.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelesai
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        color: isSelesai ? Colors.green : Colors.amber[800],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
                  color: const Color(0xFF2F9E8F).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF2F9E8F), width: 2),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2F9E8F),
                  size: 40,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

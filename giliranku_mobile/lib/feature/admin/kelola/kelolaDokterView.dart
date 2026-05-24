import 'package:flutter/material.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/theme/theme.dart';

class KelolaDokterView extends StatefulWidget {
  const KelolaDokterView({super.key});

  @override
  State<KelolaDokterView> createState() => _KelolaDokterViewState();
}

class _KelolaDokterViewState extends State<KelolaDokterView> {
  List<Map<String, dynamic>> _dokterList = [];
  List<Map<String, dynamic>> _filtered = [];
  List<Map<String, dynamic>> _poliList = [];
  bool _isLoading = true;
  final _searchCtrl = TextEditingController();

  static const _days = ['senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu'];
  static const _dayLabels = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final poli = await ApiDataSource().fetchPoliklinik();
    final dokter = await ApiDataSource().fetchDokterByPoly(null);
    setState(() {
      _poliList = poli;
      _dokterList = dokter;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_dokterList)
          : _dokterList.where((d) {
              final name =
                  (d['doctor_name'] ?? '').toString().toLowerCase();
              final poli =
                  (d['poly_name'] ?? '').toString().toLowerCase();
              final spec =
                  (d['specialization'] ?? '').toString().toLowerCase();
              return name.contains(q) ||
                  poli.contains(q) ||
                  spec.contains(q);
            }).toList();
    });
  }

  String _buildScheduleSummary(Map<String, dynamic> doc) {
    final parts = <String>[];
    for (int i = 0; i < _days.length; i++) {
      final val = (doc[_days[i]] ?? '').toString().trim();
      if (val.isNotEmpty) {
        parts.add('${_dayLabels[i].substring(0, 3)}: $val');
      }
    }
    return parts.isEmpty ? '-' : parts.join(' · ');
  }

  void _showFormDialog({Map<String, dynamic>? dokter}) {
    final isEdit = dokter != null;
    final namaCtrl = TextEditingController(text: isEdit ? dokter['doctor_name'] : '');
    final spesialisasiCtrl = TextEditingController(text: isEdit ? dokter['specialization'] : '');
    final noTelpCtrl = TextEditingController(text: isEdit ? (dokter['phone'] ?? '') : '');
    final kuotaCtrl = TextEditingController(
      text: isEdit ? (dokter['max_kuota_non_jkn'] ?? '30').toString() : '30',
    );
    int? selectedPoly = isEdit ? dokter['poly_id'] : null;

    final dayControllers = <String, TextEditingController>{};
    for (final day in _days) {
      dayControllers[day] = TextEditingController(
        text: isEdit ? (dokter[day] ?? '') : '',
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Data Dokter' : 'Tambah Data Dokter',
                        style: const TextStyle(
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
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
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
                      _styledField(namaCtrl, 'Nama Dokter', icon: Icons.person_outline),
                      const SizedBox(height: 14),
                      _styledField(spesialisasiCtrl, 'Spesialisasi', icon: Icons.medical_services_outlined),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            hint: Row(
                              children: [
                                Icon(Icons.local_hospital_outlined, size: 18, color: Colors.grey[400]),
                                const SizedBox(width: 10),
                                Text('Poliklinik', style: TextStyle(color: Colors.grey[400])),
                              ],
                            ),
                            value: selectedPoly,
                            items: _poliList.map((p) {
                              return DropdownMenuItem<int>(
                                value: p['poly_id'],
                                child: Text(p['poly_name'] ?? ''),
                              );
                            }).toList(),
                            onChanged: (val) => setDialogState(() => selectedPoly = val),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _styledField(noTelpCtrl, 'No. Telepon', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                      const SizedBox(height: 14),
                      _styledField(kuotaCtrl, 'Kuota Harian Non-JKN', icon: Icons.confirmation_number_outlined, keyboardType: TextInputType.number),

                      const SizedBox(height: 20),
                      const Text(
                        'Jadwal Praktik',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Isi waktu praktik (contoh: 08:00-12:00), kosongkan jika libur',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_days.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: Text(
                                  _dayLabels[i],
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: dayControllers[_days[i]],
                                  style: const TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Libur',
                                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFF2F9E8F), width: 2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F9E8F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            if (namaCtrl.text.isEmpty || selectedPoly == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nama dan Poliklinik wajib diisi'), backgroundColor: Colors.red),
                              );
                              return;
                            }
                            final req = <String, dynamic>{
                              'doctor_name': namaCtrl.text,
                              'specialization': spesialisasiCtrl.text,
                              'poly_id': selectedPoly,
                              'phone': noTelpCtrl.text,
                              'max_kuota_non_jkn': int.tryParse(kuotaCtrl.text) ?? 30,
                            };
                            for (final day in _days) {
                              req[day] = dayControllers[day]!.text;
                            }
                            Navigator.pop(ctx);
                            setState(() => _isLoading = true);
                            bool success;
                            if (isEdit) {
                              success = await ApiDataSource().updateDokter(dokter['doctor_id'], req);
                            } else {
                              success = await ApiDataSource().createDokter(req);
                            }
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(success ? 'Perubahan data berhasil disimpan' : 'Gagal menyimpan perubahan data'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ));
                            }
                            _fetchData();
                          },
                          child: Text(
                            isEdit ? 'Simpan Perubahan Data' : 'Tambah Data Dokter',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _styledField(
    TextEditingController controller,
    String hint, {
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.grey[500]) : null,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Data Dokter?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Anda yakin ingin menghapus dr. $name?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              final success = await ApiDataSource().deleteDokter(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? 'Data dokter berhasil dihapus'
                      : 'Gagal menghapus data dokter'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ));
              }
              _fetchData();
            },
            child:
                const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari data dokter…',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(
                        child: Text('Tidak ada data',
                            style: TextStyle(color: Colors.grey)))
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        color: AppColors.primary,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          final kuota = item['max_kuota_non_jkn'] ?? 30;
                          final schedule = _buildScheduleSummary(item);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                        child: const Icon(Icons.person, color: AppColors.primary, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['doctor_name'] ?? '',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${item['poly_name'] ?? ''} · ${item['specialization'] ?? '-'}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _showFormDialog(dokter: item),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _confirmDelete(item['doctor_id'], item['doctor_name']),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.delete, color: Colors.red, size: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Row(
                                    children: [
                                      Icon(Icons.phone_outlined, size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text(
                                        (item['phone'] ?? '-').toString().isEmpty ? '-' : item['phone'],
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(Icons.confirmation_number_outlined, size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Kuota: $kuota',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          schedule,
                                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
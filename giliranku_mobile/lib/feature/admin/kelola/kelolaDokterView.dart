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

  void _showFormDialog({Map<String, dynamic>? dokter}) {
    final isEdit = dokter != null;
    final namaController =
        TextEditingController(text: isEdit ? dokter['doctor_name'] : '');
    final spesialisasiController =
        TextEditingController(text: isEdit ? dokter['specialization'] : '');
    final noTelpController =
        TextEditingController(text: isEdit ? (dokter['phone'] ?? '') : '');
    final jadwalController =
        TextEditingController(text: isEdit ? (dokter['schedule'] ?? '') : '');
    int? selectedPoly = isEdit ? dokter['poly_id'] : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Dokter' : 'Tambah Dokter'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration:
                      const InputDecoration(labelText: 'Nama Dokter'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: spesialisasiController,
                  decoration:
                      const InputDecoration(labelText: 'Spesialisasi'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: selectedPoly,
                  decoration:
                      const InputDecoration(labelText: 'Poliklinik'),
                  items: _poliList.map((p) {
                    return DropdownMenuItem<int>(
                      value: p['poly_id'],
                      child: Text(p['poly_name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setDialogState(() => selectedPoly = val),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noTelpController,
                  decoration:
                      const InputDecoration(labelText: 'No. Telepon'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: jadwalController,
                  decoration: const InputDecoration(
                      labelText: 'Jadwal Praktik',
                      hintText: 'Contoh: Senin, Selasa'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedPoly == null) return;
                final req = {
                  'doctor_name': namaController.text,
                  'specialization': spesialisasiController.text,
                  'poly_id': selectedPoly,
                  'phone': noTelpController.text,
                  'schedule': jadwalController.text,
                };
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                bool success;
                if (isEdit) {
                  success = await ApiDataSource()
                      .updateDokter(dokter['doctor_id'], req);
                } else {
                  success = await ApiDataSource().createDokter(req);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success
                        ? 'Berhasil disimpan'
                        : 'Gagal menyimpan'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ));
                }
                _fetchData();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Dokter?'),
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
                      ? 'Dokter berhasil dihapus'
                      : 'Gagal menghapus dokter'),
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
          // ── Search Bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari dokter, poli, atau spesialisasi…',
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
          // ── List ────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(
                        child: Text('Tidak ada data',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final item = _filtered[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary
                                    .withValues(alpha: 0.2),
                                child: const Icon(Icons.person,
                                    color: AppColors.primary),
                              ),
                              title: Text(item['doctor_name'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                      '${item['poly_name'] ?? ''} - ${item['specialization'] ?? ''}'),
                                  if (item['schedule'] != null &&
                                      item['schedule']
                                          .toString()
                                          .isNotEmpty)
                                    Text('Jadwal: ${item['schedule']}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _showFormDialog(dokter: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _confirmDelete(
                                        item['doctor_id'],
                                        item['doctor_name']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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

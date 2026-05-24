import 'package:flutter/material.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/theme/theme.dart';

class KelolaPoliView extends StatefulWidget {
  const KelolaPoliView({super.key});

  @override
  State<KelolaPoliView> createState() => _KelolaPoliViewState();
}

class _KelolaPoliViewState extends State<KelolaPoliView> {
  List<Map<String, dynamic>> _poliList = [];
  List<Map<String, dynamic>> _filtered = [];
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
    final data = await ApiDataSource().fetchPoliklinik();
    setState(() {
      _poliList = data;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_poliList)
          : _poliList.where((p) {
              final name = (p['poly_name'] ?? '').toString().toLowerCase();
              final kode = (p['kode_poli'] ?? '').toString().toLowerCase();
              return name.contains(q) || kode.contains(q);
            }).toList();
    });
  }

  void _showFormDialog({Map<String, dynamic>? poli}) {
    final isEdit = poli != null;
    final namaController =
        TextEditingController(text: isEdit ? poli['poly_name'] : '');
    final kodeController =
        TextEditingController(text: isEdit ? (poli['kode_poli'] ?? '') : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Poliklinik' : 'Tambah Poliklinik'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: kodeController,
              decoration: const InputDecoration(labelText: 'Kode Poli'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Poli'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final req = {
                'kode_poli': kodeController.text,
                'poly_name': namaController.text,
              };
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              bool success;
              if (isEdit) {
                success =
                    await ApiDataSource().updatePoli(poli['poly_id'], req);
              } else {
                success = await ApiDataSource().createPoli(req);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      success ? 'Berhasil disimpan' : 'Gagal menyimpan'),
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
    );
  }

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Poli?'),
        content: Text('Anda yakin ingin menghapus $name?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              final success = await ApiDataSource().deletePoli(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? 'Poli berhasil dihapus'
                      : 'Gagal menghapus poli'),
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
                hintText: 'Cari data poli...',
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
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              title: Text(item['poly_name'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  'Kode: ${item['kode_poli'] ?? '-'}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => _showFormDialog(poli: item),
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
                                    onTap: () => _confirmDelete(
                                        item['poly_id'],
                                        item['poly_name']),
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
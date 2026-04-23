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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await ApiDataSource().fetchPoliklinik();
    setState(() {
      _poliList = data;
      _isLoading = false;
    });
  }

  void _showFormDialog({Map<String, dynamic>? poli}) {
    final isEdit = poli != null;
    final namaController = TextEditingController(text: isEdit ? poli['poly_name'] : '');
    final kodeController = TextEditingController(text: isEdit ? (poli['kode_poli'] ?? '') : '');

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
                success = await ApiDataSource().updatePoli(poli['poly_id'], req);
              } else {
                success = await ApiDataSource().createPoli(req);
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Berhasil disimpan' : 'Gagal menyimpan'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
              _fetchData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              final success = await ApiDataSource().deletePoli(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Poli berhasil dihapus' : 'Gagal menghapus poli'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
              _fetchData();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _poliList.length,
              itemBuilder: (context, index) {
                final item = _poliList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(item['poly_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Kode: ${item['kode_poli'] ?? '-'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showFormDialog(poli: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(item['poly_id'], item['poly_name']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

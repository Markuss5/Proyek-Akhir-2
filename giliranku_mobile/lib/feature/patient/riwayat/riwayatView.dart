import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:giliranku/core/widgets/header.dart';
import 'package:giliranku/core/repositories/pasienRepository.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/services/sessionService.dart';

class RiwayatView extends StatefulWidget {
  const RiwayatView({super.key});

  @override
  State<RiwayatView> createState() => _RiwayatViewState();
}

class _RiwayatViewState extends State<RiwayatView> {
  List<Map<String, dynamic>> _riwayatList = [];
  bool _isLoading = true;
  String? _nik;

  String _selectedTimeFilter = 'Semua Waktu';
  String _selectedPoliFilter = 'Semua Poli';

  List<String> get _availablePoli {
    final poliSet = {'Semua Poli'};
    for (var item in _riwayatList) {
      final poli = item['poliklinik']?.toString() ?? '';
      if (poli.isNotEmpty) {
        poliSet.add(poli);
      }
    }
    return poliSet.toList();
  }

  List<Map<String, dynamic>> get _filteredRiwayat {
    List<Map<String, dynamic>> result = _riwayatList;

    // Filter by Time
    if (_selectedTimeFilter != 'Semua Waktu') {
      final today = DateTime.now();
      result = result.where((item) {
        final tgl = item['tanggal']?.toString() ?? '';
        if (tgl.length != 10) return false;
        final parts = tgl.split('-');
        if (parts.length != 3) return false;
        final itemDate = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
        if (itemDate == null) return false;

        final itemDateOnly = DateTime(itemDate.year, itemDate.month, itemDate.day);
        final todayOnly = DateTime(today.year, today.month, today.day);

        if (_selectedTimeFilter == 'Hari Ini') {
          return itemDateOnly.isAtSameMomentAs(todayOnly);
        } else if (_selectedTimeFilter == 'Mendatang') {
          return itemDateOnly.isAfter(todayOnly);
        } else if (_selectedTimeFilter == 'Selesai') {
          return item['status']?.toString().toLowerCase() == 'selesai';
        }
        return true;
      }).toList();
    }

    // Filter by Poli
    if (_selectedPoliFilter != 'Semua Poli') {
      result = result.where((item) => (item['poliklinik'] ?? '') == _selectedPoliFilter).toList();
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final patientData = await SessionService().getPatientMap();
    _nik = patientData?['nik'];

    if (_nik != null) {
      final data = await PasienRepository().getRiwayatAntrian(_nik!);
      
      // Sort logic
      data.sort((a, b) {
        // 1. Sort by Poliklinik Name (Ascending)
        final poliA = (a['poliklinik'] ?? 'Poli Umum').toString();
        final poliB = (b['poliklinik'] ?? 'Poli Umum').toString();
        final poliComp = poliA.compareTo(poliB);
        if (poliComp != 0) return poliComp;

        // 2. Sort by Tanggal (Ascending)
        final tglA = a['tanggal']?.toString() ?? '';
        final tglB = b['tanggal']?.toString() ?? '';
        
        DateTime? dateA;
        if (tglA.isNotEmpty && tglA.length == 10) {
          final parts = tglA.split('-');
          if (parts.length == 3) {
            dateA = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
          }
        }
        
        DateTime? dateB;
        if (tglB.isNotEmpty && tglB.length == 10) {
          final parts = tglB.split('-');
          if (parts.length == 3) {
            dateB = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
          }
        }

        if (dateA != null && dateB != null) {
          final dateComp = dateA.compareTo(dateB);
          if (dateComp != 0) return dateComp;
        } else if (dateA != null) {
          return -1;
        } else if (dateB != null) {
          return 1;
        }

        // 3. Sort by No Antrian (Ascending)
        final noAStr = a['no_antrian']?.toString() ?? '0';
        final noBStr = b['no_antrian']?.toString() ?? '0';
        
        final noA = int.tryParse(noAStr) ?? 0;
        final noB = int.tryParse(noBStr) ?? 0;
        
        return noA.compareTo(noB);
      });

      if (mounted) {
        setState(() {
          _riwayatList = data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final kodeBooking = item['kode_booking'] as String? ?? '';
    if (kodeBooking.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Riwayat', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Hapus riwayat antrian dengan kode booking $kodeBooking?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ApiDataSource().deleteAntrian(kodeBooking);
    if (!mounted) return;

    if (success) {
      setState(() => _riwayatList.removeWhere(
          (e) => e['kode_booking'] == kodeBooking));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Riwayat berhasil dihapus'),
          backgroundColor: Color(0xFF25A699),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus riwayat.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          AppHeader(
            mode: HeaderMode.page,
            title: 'Riwayat Antrian',
          ),
          if (!_isLoading && _riwayatList.isNotEmpty) _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF25A699),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchRiwayat,
                    color: const Color(0xFF25A699),
                    child: _filteredRiwayat.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _filteredRiwayat.length,
                            itemBuilder: (context, index) {
                              final item = _filteredRiwayat[index];
                              final status = item['status'] ?? 'Menunggu';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: QueueCard(
                                  poliName: item['poliklinik'] ?? 'Poli Umum',
                                  doctorName: item['dokter'] ?? '-',
                                  date: item['tanggal'] ?? '-',
                                  time: item['waktu'] ?? '-',
                                  code: item['kode_booking'] ?? '-',
                                  queueNo: item['no_antrian']?.toString() ?? '-',
                                  status: status,
                                  icon: Icons.medical_services_outlined,
                                  onDelete: () => _confirmDelete(item),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    final timeOptions = ['Semua Waktu', 'Hari Ini', 'Mendatang', 'Selesai'];
    final poliOptions = _availablePoli;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedTimeFilter,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD7EFE6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD7EFE6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF25A699)),
                ),
                filled: true,
                fillColor: const Color(0xFFF4F4F4),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF25A699)),
              items: timeOptions.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(
                    opt,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedTimeFilter = val);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPoliFilter,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD7EFE6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD7EFE6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF25A699)),
                ),
                filled: true,
                fillColor: const Color(0xFFF4F4F4),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF25A699)),
              isExpanded: true,
              items: poliOptions.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(
                    opt,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPoliFilter = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.document_1, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Belum ada riwayat antrian",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Text(
                "Silakan ambil antrian terlebih dahulu.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QueueCard extends StatelessWidget {
  final String poliName;
  final String doctorName;
  final String date;
  final String code;
  final String time;
  final String queueNo;
  final String status;
  final IconData icon;
  final bool isDeletable;
  final VoidCallback? onDelete;

  const QueueCard({
    super.key,
    required this.poliName,
    required this.doctorName,
    required this.date,
    required this.code,
    required this.time,
    required this.queueNo,
    required this.status,
    required this.icon,
    this.isDeletable = true,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF25A699)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  poliName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (isDeletable) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Dokter", doctorName),
              _buildInfoColumn("No. Antrian", queueNo),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Tanggal", date),
              _buildInfoColumn("Jam", time),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFB8E4D2), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "KODE BOOKING", 
                  style: TextStyle(
                    color: Color(0xFF0D9B86), 
                    fontSize: 10, 
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  code, 
                  style: const TextStyle(
                    color: Color(0xFF063A25), 
                    fontWeight: FontWeight.w900, 
                    fontSize: 20, 
                    letterSpacing: 3,
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
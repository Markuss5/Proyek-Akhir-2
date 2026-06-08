import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:giliranku/core/widgets/header.dart';
import 'package:giliranku/core/theme/theme.dart';

class RiwayatHelper {
  static List<String> getAvailablePoli(List<Map<String, dynamic>> riwayatList) {
    final poliSet = {'Semua Poli'};
    for (var item in riwayatList) {
      final poli = item['poliklinik']?.toString() ?? '';
      if (poli.isNotEmpty) {
        poliSet.add(poli);
      }
    }
    return poliSet.toList();
  }

  static List<Map<String, dynamic>> filterAndSortRiwayat({
    required List<Map<String, dynamic>> riwayatList,
    required DateTime? selectedDateFilter,
    required String selectedPoliFilter,
    required String selectedStatusFilter,
    required String searchQuery,
    required String selectedSortCategory,
    required bool isSortAscending,
  }) {
    List<Map<String, dynamic>> result = List.from(riwayatList);

    if (selectedDateFilter != null) {
      result = result.where((item) {
        final tgl = item['tanggal']?.toString() ?? '';
        if (tgl.length != 10) return false;
        final parts = tgl.split('-');
        if (parts.length != 3) return false;
        final itemDate = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
        if (itemDate == null) return false;

        return itemDate.year == selectedDateFilter.year &&
               itemDate.month == selectedDateFilter.month &&
               itemDate.day == selectedDateFilter.day;
      }).toList();
    }

    if (selectedPoliFilter != 'Semua Poli') {
      result = result.where((item) => (item['poliklinik'] ?? '') == selectedPoliFilter).toList();
    }

    if (selectedStatusFilter != 'Semua Status') {
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      result = result.where((item) {
        final tgl = item['tanggal']?.toString() ?? '';
        DateTime? itemDate;
        if (tgl.length == 10) {
          final parts = tgl.split('-');
          if (parts.length == 3) {
            itemDate = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
          }
        }
        final isSelesaiDb = (item['status']?.toString() ?? '').toLowerCase() == 'selesai';
        final isBeforeToday = itemDate != null && itemDate.isBefore(today);
        final isSelesai = isSelesaiDb || isBeforeToday;

        if (selectedStatusFilter == 'Akan Datang') {
          if (itemDate == null) return false;
          return itemDate.isAfter(today) && !isSelesai;
        } else if (selectedStatusFilter == 'Hari Ini') {
          if (itemDate == null) return false;
          final isToday = itemDate.year == today.year &&
                           itemDate.month == today.month &&
                           itemDate.day == today.day;
          return isToday && !isSelesai;
        } else if (selectedStatusFilter == 'Selesai') {
          return isSelesai;
        }
        return true;
      }).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      result = result.where((item) {
        final poli = (item['poliklinik'] ?? '').toString().toLowerCase();
        final tgl = (item['tanggal'] ?? '').toString().toLowerCase();
        final dokter = (item['dokter'] ?? '').toString().toLowerCase();
        final kode = (item['kode_booking'] ?? '').toString().toLowerCase();
        
        return poli.contains(q) || tgl.contains(q) || dokter.contains(q) || kode.contains(q);
      }).toList();
    }

    result.sort((a, b) {
      final tglA = a['tanggal']?.toString() ?? '';
      final tglB = b['tanggal']?.toString() ?? '';
      
      DateTime? dateA;
      if (tglA.length == 10) {
        final parts = tglA.split('-');
        if (parts.length == 3) dateA = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
      }
      
      DateTime? dateB;
      if (tglB.length == 10) {
        final parts = tglB.split('-');
        if (parts.length == 3) dateB = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
      }

      if (selectedSortCategory == 'No. Antrian') {
        final noA = int.tryParse(a['no_antrian']?.toString() ?? '') ?? 0;
        final noB = int.tryParse(b['no_antrian']?.toString() ?? '') ?? 0;
        final comp = noA.compareTo(noB);
        if (comp != 0) return isSortAscending ? comp : -comp;
      } else if (selectedSortCategory == 'Poliklinik') {
        final poliA = (a['poliklinik'] ?? '').toString().toLowerCase();
        final poliB = (b['poliklinik'] ?? '').toString().toLowerCase();
        final comp = poliA.compareTo(poliB);
        if (comp != 0) return isSortAscending ? comp : -comp;
      } else if (selectedSortCategory == 'Nama Dokter') {
        final dokA = (a['dokter'] ?? '').toString().toLowerCase();
        final dokB = (b['dokter'] ?? '').toString().toLowerCase();
        final comp = dokA.compareTo(dokB);
        if (comp != 0) return isSortAscending ? comp : -comp;
      }

      if (dateA != null && dateB != null) {
        return isSortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      } else if (dateA != null) {
        return isSortAscending ? -1 : 1;
      } else if (dateB != null) {
        return isSortAscending ? 1 : -1;
      }
      return 0;
    });

    return result;
  }

  static Widget buildScaffold({
    required BuildContext context,
    required bool isLoading,
    required List<Map<String, dynamic>> riwayatList,
    required List<Map<String, dynamic>> filteredRiwayat,
    required TextEditingController searchCtrl,
    required ValueChanged<String> onChangedSearch,
    required VoidCallback onShowFilterModal,
    required VoidCallback onShowSortModal,
    required Future<void> Function() onRefresh,
    required void Function(Map<String, dynamic>) onConfirmDelete,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Column(
        children: [
          AppHeader(
            mode: HeaderMode.page,
            title: 'Riwayat Antrian',
          ),
          if (!isLoading && riwayatList.isNotEmpty) 
            buildFilterSection(
              searchCtrl: searchCtrl,
              onChangedSearch: onChangedSearch,
              onShowFilterModal: onShowFilterModal,
              onShowSortModal: onShowSortModal,
            ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF25A699),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: onRefresh,
                    color: const Color(0xFF25A699),
                    child: filteredRiwayat.isEmpty
                        ? buildEmptyState(context)
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: filteredRiwayat.length,
                            itemBuilder: (context, index) {
                              final item = filteredRiwayat[index];
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
                                  onDelete: () => onConfirmDelete(item),
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

  static Widget buildFilterSection({
    required TextEditingController searchCtrl,
    required ValueChanged<String> onChangedSearch,
    required VoidCallback onShowFilterModal,
    required VoidCallback onShowSortModal,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchCtrl,
              onChanged: onChangedSearch,
              decoration: InputDecoration(
                hintText: 'Cari riwayat...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF4F4F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: IconButton(
              icon: const Icon(Iconsax.setting_4, color: Color(0xFF25A699)),
              onPressed: onShowFilterModal,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: IconButton(
              icon: const Icon(Icons.sort_rounded, color: Color(0xFF25A699)),
              onPressed: onShowSortModal,
            ),
          ),
        ],
      ),
    );
  }

  static void showFilterModal({
    required BuildContext context,
    required List<String> availablePoli,
    required DateTime? selectedDateFilter,
    required String selectedPoliFilter,
    required String selectedStatusFilter,
    required ValueChanged<DateTime?> onDateChanged,
    required ValueChanged<String> onPoliChanged,
    required ValueChanged<String> onStatusChanged,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDateFilter ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF25A699),
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setModalState(() => selectedDateFilter = date);
                        onDateChanged(date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDateFilter == null
                                ? 'Pilih Tanggal'
                                : '${selectedDateFilter!.day.toString().padLeft(2, '0')}-${selectedDateFilter!.month.toString().padLeft(2, '0')}-${selectedDateFilter!.year}',
                            style: TextStyle(
                              color: selectedDateFilter == null ? Colors.grey.shade600 : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          if (selectedDateFilter != null)
                            GestureDetector(
                              onTap: () {
                                setModalState(() => selectedDateFilter = null);
                                onDateChanged(null);
                              },
                              child: const Icon(Icons.close, size: 20, color: Colors.grey),
                            )
                          else
                            const Icon(Icons.calendar_today, size: 20, color: Color(0xFF25A699)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Poli', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPoliFilter,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF25A699), size: 20),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF25A699)),
                      ),
                    ),
                    items: availablePoli.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontSize: 14, color: Colors.black87), overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedPoliFilter = val);
                        onPoliChanged(val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatusFilter,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF25A699), size: 20),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF25A699)),
                      ),
                    ),
                    items: [
                      'Semua Status',
                      'Akan Datang',
                      'Hari Ini',
                      'Selesai',
                    ].map((opt) => DropdownMenuItem(
                      value: opt,
                      child: Text(opt, style: const TextStyle(fontSize: 14, color: Colors.black87), overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedStatusFilter = val);
                        onStatusChanged(val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25A699),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Terapkan'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showSortModal({
    required BuildContext context,
    required String selectedSortCategory,
    required bool isSortAscending,
    required ValueChanged<String> onSortCategoryChanged,
    required VoidCallback onSortAscendingToggled,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Urutkan Berdasar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedSortCategory,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF25A699), size: 20),
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF25A699)),
                            ),
                          ),
                          items: [
                            'Tanggal',
                            'No. Antrian',
                            'Poliklinik',
                            'Nama Dokter',
                          ].map((opt) => DropdownMenuItem(
                            value: opt,
                            child: Text(opt, style: const TextStyle(fontSize: 14, color: Colors.black87), overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedSortCategory = val);
                              onSortCategoryChanged(val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          setModalState(() {
                            isSortAscending = !isSortAscending;
                          });
                          onSortAscendingToggled();
                        },
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF25A699),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isSortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25A699),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Terapkan'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget buildEmptyState(BuildContext context) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "KODE ANTRIAN", 
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
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kode antrian berhasil disalin', style: TextStyle(color: Colors.white)),
                        backgroundColor: Color(0xFF25A699),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, color: Color(0xFF0D9B86)),
                  tooltip: 'Salin Kode Antrian',
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

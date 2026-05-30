import 'package:flutter/material.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/widgets/header.dart';
import 'package:giliranku/core/theme/theme.dart';

const _days = [
  {'label': 'Sen', 'key': 'senin'},
  {'label': 'Sel', 'key': 'selasa'},
  {'label': 'Rab', 'key': 'rabu'},
  {'label': 'Kam', 'key': 'kamis'},
  {'label': 'Jum', 'key': 'jumat'},
  {'label': 'Sab', 'key': 'sabtu'},
  {'label': 'Min', 'key': 'minggu'},
];

class InformasiDokterPage extends StatefulWidget {
  const InformasiDokterPage({super.key});

  @override
  State<InformasiDokterPage> createState() => _InformasiDokterPageState();
}

class _InformasiDokterPageState extends State<InformasiDokterPage> {
  List<Map<String, dynamic>> _allDoctors = [];
  List<Map<String, dynamic>> _filteredDoctors = [];
  bool _isLoading = true;
  String _searchKeyword = '';
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ApiDataSource().fetchDokterByPoly(null);
    if (mounted) {
      setState(() {
        _allDoctors = data;
        _isLoading = false;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    final dayKey = _days[_selectedDayIndex]['key']!;
    final keyword = _searchKeyword.toLowerCase();

    _filteredDoctors = _allDoctors.where((d) {
      final daySchedule = (d[dayKey] ?? '').toString().trim();
      if (daySchedule.isEmpty) return false;

      if (keyword.isEmpty) return true;
      final name = (d['doctor_name'] ?? '').toString().toLowerCase();
      final poly = (d['poly_name'] ?? '').toString().toLowerCase();
      return name.contains(keyword) || poly.contains(keyword);
    }).toList();
  }

  void _onDaySelected(int index) {
    setState(() {
      _selectedDayIndex = index;
      _applyFilters();
    });
  }

  void _onSearch(String value) {
    setState(() {
      _searchKeyword = value;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              mode: HeaderMode.page,
              title: 'Daftar Dokter RSUD Porsea',
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: TextField(
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: "Cari Dokter...",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),

            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedDayIndex == index;
                  return GestureDetector(
                    onTap: () => _onDaySelected(index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE0F2F1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected ? Border.all(color: const Color(0xFF25A699)) : null,
                      ),
                      child: Center(
                        child: Text(
                          _days[index]['label']!,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF25A699) : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 4),

            _isLoading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _filteredDoctors.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada dokter pada hari ini',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: RefreshIndicator(
                          onRefresh: _fetchData,
                          color: const Color(0xFF25A699),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            itemCount: _filteredDoctors.length,
                            itemBuilder: (context, index) {
                              return _buildDoctorCard(_filteredDoctors[index]);
                            },
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final String name = doctor['doctor_name'] ?? '-';
    final String specialty = doctor['poly_name'] ?? '';
    final dayKey = _days[_selectedDayIndex]['key']!;
    final String time = (doctor[dayKey] ?? '').toString().trim();
    final int kuota = int.tryParse('${doctor['kuota_non_jkn'] ?? 0}') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Color(0xFF25A699), size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Text(specialty, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        time.isNotEmpty ? time : '-',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: kuota < 10 
                            ? AppColors.warning.withValues(alpha: 0.1) 
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Sisa kuota: $kuota',
                        style: TextStyle(
                          color: kuota < 10 ? AppColors.warning : Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
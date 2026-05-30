import 'package:flutter/material.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/widgets/header.dart';

class InformasiPoliklinikView extends StatefulWidget {
  const InformasiPoliklinikView({super.key});

  @override
  State<InformasiPoliklinikView> createState() =>
      _InformasiPoliklinikViewState();
}

class _InformasiPoliklinikViewState
    extends State<InformasiPoliklinikView> {
  final TextEditingController _searchController =
      TextEditingController();

  List<Map<String, dynamic>> poliList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ApiDataSource().fetchPoliklinik();
    if (mounted) {
      setState(() {
        poliList = data;
        _isLoading = false;
      });
    }
  }

  String keyword = '';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final filteredList = poliList.where((item) {
      return (item['poly_name'] ?? '')
          .toString()
          .toLowerCase()
          .contains(keyword.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              mode: HeaderMode.page,
              title: 'Daftar Poliklinik RSUD Porsea',
            ),

            _buildSearchBox(),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                color: const Color(0xFF25A699),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFEAEAEA)),
                  itemBuilder: (context, index) {
                    final poli = filteredList[index];
  
                    return _buildPoliItem(
                      nama: poli['poly_name'] ?? '',
                      desc: poli['kode_poli'] != null ? 'Kode: ${poli['kode_poli']}' : '',
                      icon: Icons.local_hospital_outlined,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            keyword = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Cari Poliklinik...",
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15),
        ),
      ),
    );
  }

  Widget _buildPoliItem({
    required String nama,
    required String desc,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF25A699)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
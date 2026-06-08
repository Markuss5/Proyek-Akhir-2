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
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; _isError = false; });
    try {
      final data = await ApiDataSource().fetchPoliklinik();
      if (mounted) {
        setState(() {
          poliList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
      }
    }
  }

  String keyword = '';

  @override
  Widget build(BuildContext context) {
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

            if (_isLoading)
              Expanded(child: _buildLoadingBody())
            else if (_isError)
              Expanded(child: _buildErrorBody())
            else
              Expanded(
                child: Column(
                  children: [
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
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
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

  Widget _buildLoadingBody() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF25A699)),
          SizedBox(height: 16),
          Text('Memuat informasi...', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildErrorBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, color: Colors.grey, size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Terjadi Kesalahan, Silahkan Coba Lagi',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25A699),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
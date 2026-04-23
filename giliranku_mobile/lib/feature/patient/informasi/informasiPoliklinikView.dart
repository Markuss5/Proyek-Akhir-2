import 'package:flutter/material.dart';

class InformasiPoliklinikView extends StatefulWidget {
  const InformasiPoliklinikView({super.key});

  @override
  State<InformasiPoliklinikView> createState() =>
      _InformasiPoliklinikViewState();
}

class _InformasiPoliklinikViewState extends State<InformasiPoliklinikView> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> poliList = [
    {
      "nama": "Poli Umum",
      "desc": "Pemeriksaan kesehatan umum dan konsultasi rutin.",
      "icon": Icons.medical_services_outlined,
    },
    {
      "nama": "Poli Anak",
      "desc": "Layanan kesehatan spesialis anak dan imunisasi.",
      "icon": Icons.child_care,
    },
    {
      "nama": "Poli Dalam",
      "desc": "Penanganan masalah kesehatan organ dalam tubuh.",
      "icon": Icons.local_hospital,
    },
    {
      "nama": "Poli Jiwa",
      "desc": "Layanan konsultasi kesehatan mental dan psikiatri.",
      "icon": Icons.psychology,
    },
    {
      "nama": "Poli Paru",
      "desc": "Spesialis gangguan pernapasan dan kesehatan paru-paru.",
      "icon": Icons.air,
    },
    {
      "nama": "Poli Jantung",
      "desc": "Pemeriksaan ritme dan kesehatan fungsi jantung.",
      "icon": Icons.favorite,
    },
    {
      "nama": "Orthopedi",
      "desc": "Layanan spesialis tulang, sendi, dan ligamen.",
      "icon": Icons.accessibility_new,
    },
    {
      "nama": "Poli Gigi & Endodonti",
      "desc": "Perawatan saluran akar dan estetika gigi khusus.",
      "icon": Icons.mood,
    },
    {
      "nama": "Mikrobiologi Klinik",
      "desc": "Layanan pengujian dan diagnosis infeksi bakteri/virus.",
      "icon": Icons.biotech,
    },
    {
      "nama": "Poli Bedah",
      "desc": "Konsultasi pra dan pasca tindakan pembedahan.",
      "icon": Icons.content_cut,
    },
    {
      "nama": "Poli Kandungan",
      "desc": "Layanan kesehatan reproduksi dan pemeriksaan kehamilan.",
      "icon": Icons.pregnant_woman,
    },
    {
      "nama": "Poli Syaraf",
      "desc": "Penanganan gangguan neurologi dan sistem saraf pusat.",
      "icon": Icons.monitor_heart,
    },
  ];

  String keyword = "";

  @override
  Widget build(BuildContext context) {
    final filteredList = poliList.where((item) {
      return item["nama"]
          .toString()
          .toLowerCase()
          .contains(keyword.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,

      // bottomNavigationBar DIHAPUS

      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBox(),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: filteredList.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFEAEAEA)),
                itemBuilder: (context, index) {
                  final poli = filteredList[index];

                  return _buildPoliItem(
                    nama: poli["nama"],
                    desc: poli["desc"],
                    icon: poli["icon"],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        topPadding + 16,
        16,
        18,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF25A699),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Daftar Poliklinik",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.all(20),
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
          Icon(
            icon,
            size: 24,
            color: const Color(0xFF25A699),
          ),
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
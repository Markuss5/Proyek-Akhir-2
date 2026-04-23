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
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBox(),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                itemCount: filteredList.length,
                separatorBuilder: (_, _) =>
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
      bottomNavigationBar: _buildBottomNavbar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF22B8B0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            "Daftar Poliklinik",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            keyword = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Cari Poliklinik...",
          hintStyle: const TextStyle(fontSize: 14),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
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
            color: const Color(0xFF22B8B0),
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
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
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

  Widget _buildBottomNavbar() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: const Color(0xFF22B8B0),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital),
          label: "Informasi",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: "Antrian",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profil",
        ),
      ],
    );
  }
}
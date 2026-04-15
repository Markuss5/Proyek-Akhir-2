import 'package:flutter/material.dart';
import 'profil_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // --- HEADER HIJAU YANG DIPERBAIKI ---
          Stack(
            alignment: Alignment.center,
            children: [
              // Menggunakan Transform.scale agar lengkungan meluber ke samping (efek lebar)
              Transform.scale(
                scaleX: 1.5, // Melebarkan container ke samping luar layar
                child: Container(
                  height: 280, 
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F9E8F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(180), 
                      bottomRight: Radius.circular(180),
                    ),
                  ),
                ),
              ),
              
              // Logo GiliranKu
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 200, // Ukuran lebar logo ditingkatkan agar lebih jelas
                  fit: BoxFit.contain, 
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      "Logo tidak ditemukan",
                      style: TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ],
          ),

            const SizedBox(height: 25),

            // --- PENGINGAT JANJI TEMU ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Pengingat Janji Temu",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Hari ini",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2F9E8F).withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7EDEB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications, color: Color(0xFF2F9E8F)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Poli Paru - dr. Budi Santoso",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            "ID: PA2-2024-1257",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      "09:45",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // --- LAYANAN ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Layanan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.25, 
                children: [
                  _menuItem(Icons.calendar_month, "Ambil Antrian"),
                  _menuItem(Icons.notifications, "Nontifikasi"),
                 _menuItem(
                    Icons.apartment, 
                    "Informasi", 
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilView()),
                      );
                    },
                  ),
                  
                  _menuItem(Icons.person, "Profil"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- JAM OPRASIONAL ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2F9E8F).withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7EDEB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.apartment, color: Color(0xFF2F9E8F)),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Jam Oprasional",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          "Senin - Sabtu: 08:00 - 16:00 WIB",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          "IGD: 24 Jam",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0, // Beranda aktif
      onTap: (index) {
        if (index == 1) { // Index 1 adalah tombol 'Informasi'
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilView()),
          );
        }
        // Tambahkan logika index lain jika perlu (misal index 3 untuk Profil)
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.apartment), label: "Informasi"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Antrian"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
      ],
    ),
    );
  }

Widget _menuItem(IconData icon, String title, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap, // Menjalankan fungsi saat diklik
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2F9E8F)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFD7EDEB),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2F9E8F), size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2F9E8F),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}}
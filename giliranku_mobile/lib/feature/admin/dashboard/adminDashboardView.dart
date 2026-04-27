import 'package:flutter/material.dart';
import 'package:giliranku/feature/admin/beranda/adminBerandaView.dart';
import 'package:giliranku/feature/admin/kontrol/adminKontrolView.dart';
import 'package:giliranku/feature/admin/kelola/adminKelolaView.dart';
import 'package:giliranku/feature/admin/kunjungan/menuLaporanKunjungan.dart';
import 'package:giliranku/feature/admin/profil/adminProfilView.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => AdminDashboardViewState();
}

class AdminDashboardViewState extends State<AdminDashboardView> {
  int _currentIndex = 0;

  void switchToTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      AdminBerandaView(onSwitchTab: switchToTab),
      const AdminKontrolView(),
      const AdminKelolaView(),
      const LaporanKunjunganView(),
      const AdminProfilView(),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF25A699),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: 'Kontrol',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Kelola Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Kunjungan RS',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

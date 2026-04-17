import 'package:flutter/material.dart';
import 'package:giliranku/pages/splash/auth/admin/admin_beranda_tab.dart';
import 'package:giliranku/pages/splash/auth/admin/kontrolView.dart';
import 'package:giliranku/pages/splash/auth/admin/admin_kelola_tab.dart';
import 'package:giliranku/pages/splash/auth/admin/admin_kunjungan_tab.dart';
import 'package:giliranku/pages/splash/auth/admin/admin_profil_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      AdminBerandaTab(onSwitchTab: switchToTab),
      const AdminKontrolTab(),
      const AdminKelolaTab(),
      const AdminKunjunganTab(),
      const AdminProfilTab(),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2F9E8F),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active), label: "Kontrol"),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "Kelola Data"),
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: "Kunjungan RS"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

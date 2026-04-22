import 'package:flutter/material.dart';
import 'package:giliranku/feature/patient/profil/patientProfilTab.dart';
import 'package:giliranku/feature/patient/profil/profilView.dart';
import 'package:giliranku/feature/patient/notifikasi/notifikasiView.dart';
import 'package:giliranku/feature/patient/antrian/antrianView.dart';

class HomeView extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const HomeView({super.key, this.patientData});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  void _switchTab(int index) => setState(() => _currentIndex = index);

  @override
  void initState() {
    super.initState();
    _pages = [
      _BerandaTab(patientData: widget.patientData, onSwitchTab: _switchTab),
      const ProfilView(),
      const _PlaceholderTab(title: 'Antrian', icon: Icons.calendar_today),
      PatientProfilView(patientData: widget.patientData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2F9E8F),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Informasi"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Antrian"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

// ================= BERANDA =================
class _BerandaTab extends StatelessWidget {
  final Map<String, dynamic>? patientData;
  final void Function(int) onSwitchTab;

  const _BerandaTab({this.patientData, required this.onSwitchTab});

  bool get _isLoggedIn =>
      patientData != null && patientData!.containsKey('nik');

  String? get _nik => _isLoggedIn ? patientData!['nik'] : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2F9E8F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
            child: const Center(
              child: Text(
                "GiliranKu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Welcome
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _isLoggedIn
                          ? "Halo, ${patientData!['patient_name'] ?? 'Pasien'}"
                          : "Halo, Tamu",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Menu
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _menuCard(
                          Icons.add_circle_outline,
                          "Ambil Antrian",
                          const Color(0xFF2F9E8F),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AntrianView(),
                              ),
                            );
                          },
                        ),
                        _menuCard(
                          Icons.notifications,
                          "Notifikasi",
                          Colors.orange,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotifikasiView(nik: _nik),
                              ),
                            );
                          },
                        ),
                        _menuCard(
                          Icons.info,
                          "Informasi",
                          Colors.blue,
                          () => onSwitchTab(1),
                        ),
                        _menuCard(
                          Icons.person,
                          "Profil",
                          Colors.purple,
                          () => onSwitchTab(3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

// ================= PLACEHOLDER =================
class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderTab({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(title),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:giliranku/feature/admin/beranda/adminBerandaView.dart';
import 'package:giliranku/feature/admin/kontrol/adminKontrolView.dart';
import 'package:giliranku/feature/admin/kelola/adminKelolaView.dart';
import 'package:giliranku/feature/admin/kunjungan/adminKunjunganView.dart';
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
      const AdminKunjunganView(),
      const AdminProfilView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _primaryColor = Color(0xFF25A699);

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
    _NavItem(icon: Icons.notifications_active_rounded, label: 'Kontrol'),
    _NavItem(icon: Icons.description_rounded, label: 'Kelola'),
    _NavItem(icon: Icons.apartment_rounded, label: 'Kunjungan'),
    _NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
  return SafeArea(
    bottom: false, 
    child: Container(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.15),
            width: 0.5,
          ),
        ),
      ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: Colors.grey.withOpacity(0.12),
              width: 0.5,
            ),
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? _primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _items[i].icon,
                            key: ValueKey('icon_${i}_$isActive'),
                            size: 24,
                            color: isActive
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                          child: Text(_items[i].label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
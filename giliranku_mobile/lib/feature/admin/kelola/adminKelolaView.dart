import 'package:flutter/material.dart';
import 'package:giliranku/core/theme/theme.dart';
import 'package:giliranku/feature/admin/kelola/kelolaPoliView.dart';
import 'package:giliranku/feature/admin/kelola/kelolaDokterView.dart';
import 'package:giliranku/feature/admin/kelola/kelolaInformasiView.dart';

class AdminKelolaView extends StatefulWidget {
  const AdminKelolaView({super.key});

  @override
  State<AdminKelolaView> createState() => _AdminKelolaViewState();
}

class _AdminKelolaViewState extends State<AdminKelolaView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Kelola Data',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Poli & Layanan'),
            Tab(text: 'Dokter'),
            Tab(text: 'Informasi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          KelolaPoliView(),
          KelolaDokterView(),
          KelolaInformasiView(),
        ],
      ),
    );
  }
}

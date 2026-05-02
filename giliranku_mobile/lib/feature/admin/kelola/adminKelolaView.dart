import 'package:flutter/material.dart';
import 'package:giliranku/core/theme/theme.dart';
import 'package:giliranku/feature/admin/kelola/kelolaPoliView.dart';
import 'package:giliranku/feature/admin/kelola/kelolaDokterView.dart';
import 'package:giliranku/feature/admin/kelola/kelolaInformasiView.dart';
import 'package:giliranku/feature/admin/adminHeader.dart';

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
      body: Column(
      children: [
        AdminHeader(
          type: AdminHeaderType.page,
          pageTitle: "Kelola Data",
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 28),
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Poli & Layanan'),
                Tab(text: 'Dokter'),
                Tab(text: 'Informasi'),
              ],
            ),
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              KelolaPoliView(),
              KelolaDokterView(),
              KelolaInformasiView(),
            ],
          ),
        ),
      ],
    ),
    );
  }
}

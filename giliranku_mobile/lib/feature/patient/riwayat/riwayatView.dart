import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart'; 
import 'package:giliranku/core/widgets/header.dart';

class RiwayatView extends StatelessWidget {
  const RiwayatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [
          AppHeader(
            mode: HeaderMode.page,
            title: 'Riwayat',
            pageIcon: Iconsax.clock,
          ),

          const Expanded(
            child: Center(
              child: Text('Halaman Riwayat'),
            ),
          ),
        ],
      ),
    );
  }
}
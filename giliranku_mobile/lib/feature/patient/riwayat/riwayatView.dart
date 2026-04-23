import 'package:flutter/material.dart';

class RiwayatView extends StatelessWidget {
  const RiwayatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Riwayat')),
      body: const Center(child: Text('Halaman Riwayat')),
    );
  }
}

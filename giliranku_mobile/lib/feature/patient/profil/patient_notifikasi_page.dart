import 'package:flutter/material.dart';

class PatientNotifikasiPage extends StatelessWidget {
  final String? nik;

  const PatientNotifikasiPage({super.key, this.nik});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: const Center(
        child: Text('Halaman Notifikasi'),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AdminKontrolTab extends StatelessWidget {
  const AdminKontrolTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF2F9E8F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Text(
              "Kontrol Rutin",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          // Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Daftar Kontrol Rutin",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Segera Hadir",
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:giliranku/core/widgets/header.dart';

class RiwayatView extends StatelessWidget {
  const RiwayatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      body: Column(
        children: [
          AppHeader(
            mode: HeaderMode.page,
            title: 'Riwayat Antrian',
            pageIcon: Iconsax.clock,
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                QueueCard(
                  poliName: "Poli Umum",
                  doctorName: "dr. Budi Santoso",
                  date: "12 Maret 2025",
                  code: "TB-8891-XY",
                  time: "09:30 WIB",
                  queueNo: "A-012",
                  status: "Selesai",
                  icon: Icons.medical_services_outlined,
                ),

                SizedBox(height: 20),

                QueueCard(
                  poliName: "Poli Gigi",
                  doctorName: "drg. Riani Hutabarat",
                  date: "16 Maret 2025",
                  code: "BC-9972-ZZ",
                  time: "12:00 WIB",
                  queueNo: "C-009",
                  status: "Selesai",
                  icon: Icons.medical_services,
                ),

                SizedBox(height: 20),

                QueueCard(
                  poliName: "Poli Umum",
                  doctorName: "dr. Hendra Siahaan, Sp.PD",
                  date: "16 Maret 2025",
                  code: "GC-8876-AA",
                  time: "12:00 WIB",
                  queueNo: "F-024",
                  status: "Selesai",
                  icon: Icons.health_and_safety_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QueueCard extends StatelessWidget {
  final String poliName;
  final String doctorName;
  final String date;
  final String code;
  final String time;
  final String queueNo;
  final String status;
  final IconData icon;

  const QueueCard({
    super.key,
    required this.poliName,
    required this.doctorName,
    required this.date,
    required this.code,
    required this.time,
    required this.queueNo,
    required this.status,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// TOP SECTION
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F5F3),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF25A699),
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poliName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2A44),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F5F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFF25A699),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// MIDDLE INFO BOX
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Color(0xFF25A699),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        date,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),

                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: Color(0xFF25A699),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Kode: $code",
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "No: $queueNo",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          /// BUTTON
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(0xFF25A699),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Lihat E-Tiket",
                style: TextStyle(
                  color: Color(0xFF25A699),
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
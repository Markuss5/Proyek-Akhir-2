import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:giliranku/core/widgets/header.dart';
import 'package:giliranku/core/repositories/pasienRepository.dart'; 
import 'package:giliranku/core/services/sessionService.dart';

class RiwayatView extends StatefulWidget {
  const RiwayatView({super.key});

  @override
  State<RiwayatView> createState() => _RiwayatViewState();
}

class _RiwayatViewState extends State<RiwayatView> {
  List<Map<String, dynamic>> _riwayatList = [];
  bool _isLoading = true;
  String? _nik;

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    final patientData = await SessionService().getPatientMap();
    _nik = patientData?['nik'];

    if (_nik != null) {
      final data = await PasienRepository().getRiwayatAntrian(_nik!);
      
      if (mounted) {
        setState(() {
          _riwayatList = data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF25A699),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchRiwayat,
                    color: const Color(0xFF25A699),
                    child: _riwayatList.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _riwayatList.length,
                            itemBuilder: (context, index) {
                              final item = _riwayatList[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: QueueCard(
                                  poliName: item['poliklinik'] ?? 'Poli Umum',
                                  doctorName: item['dokter'] ?? '-',
                                  date: item['tanggal'] ?? '-',
                                  code: item['kode_booking'] ?? '-',
                                  time: item['waktu'] ?? '-',
                                  queueNo: item['no_antrian']?.toString() ?? '-',
                                  status: item['status'] ?? 'Menunggu',
                                  icon: item['pembayaran'] == 'BPJS' 
                                      ? Icons.health_and_safety_outlined 
                                      : Icons.medical_services_outlined,
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SChild(height: MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.document_1, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Belum ada riwayat antrian",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Text(
                "Silakan ambil antrian terlebih dahulu.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SChild extends StatelessWidget {
  final double height;
  const SChild({super.key, required this.height});
  @override
  Widget build(BuildContext context) => SizedBox(height: height);
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF25A699)),
              const SizedBox(width: 10),
              Text(poliName, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF25A699).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status, style: const TextStyle(color: Color(0xFF25A699), fontSize: 12)),
              )
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Dokter", doctorName),
              _buildInfoColumn("No. Antrian", queueNo),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Tanggal", date),
              _buildInfoColumn("Jam", time),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
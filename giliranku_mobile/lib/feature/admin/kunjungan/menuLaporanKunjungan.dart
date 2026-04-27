import 'package:flutter/material.dart';

class LaporanKunjunganView extends StatefulWidget {
  const LaporanKunjunganView({super.key});

  @override
  State<LaporanKunjunganView> createState() => _LaporanKunjunganViewState();
}

class _LaporanKunjunganViewState extends State<LaporanKunjunganView> {
  int selectedPeriode = 0;
  int selectedBar = -1;

  final List<String> periode = [
    "Harian",
    "Mingguan",
    "Bulanan",
  ];

  final List<Map<String, dynamic>> statistik = [
    {"judul": "Pasien Hari Ini", "angka": "67"},
    {"judul": "Rata-rata / Hari", "angka": "48"},
    {"judul": "Apotek", "angka": "64"},
  ];

  final List<String> poli = [
    "Poli\nUmum",
    "Poli\nParu",
    "Poli\nJantung",
    "Poli\nAnak",
    "Apotek",
  ];

  final List<double> dataChart = [14, 8, 12, 9, 24];

  final List<Map<String, String>> detailPoli = [
    {"nama": "Poli Umum", "jumlah": "14 Pasien"},
    {"nama": "Poli Paru", "jumlah": "8 Pasien"},
    {"nama": "Poli Jantung", "jumlah": "12 Pasien"},
    {"nama": "Poli Anak", "jumlah": "9 Pasien"},
    {"nama": "Apotek", "jumlah": "24 Pasien"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F9E8F),

      /// NAVBAR DIHAPUS (double)

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER TANPA LOGO
            const SizedBox(height: 25),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 18),
                      _buildStatistik(),
                      const SizedBox(height: 18),
                      _buildPeriode(),
                      const SizedBox(height: 18),
                      _buildChart(),
                      const SizedBox(height: 18),
                      _buildDetail(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TITLE
  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Laporan Kunjungan",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Statistik kunjungan pasien rumah sakit",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  /// CARD STATISTIK
  Widget _buildStatistik() {
    return Row(
      children: statistik.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFDDE8E7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["angka"],
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item["judul"],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// FILTER
  Widget _buildPeriode() {
    return Row(
      children: List.generate(
        periode.length,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedPeriode = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selectedPeriode == index
                    ? const Color(0xFF2F9E8F)
                    : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                periode[index],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selectedPeriode == index
                      ? Colors.white
                      : Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// GRAFIK RAPIIIII
  Widget _buildChart() {
    double maxValue = 24;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Grafik Kunjungan (${periode[selectedPeriode]})",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),

          SizedBox(
            height: 280,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(dataChart.length, (index) {
                double value = dataChart[index];
                double barHeight = (value / maxValue) * 180;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBar =
                            selectedBar == index ? -1 : index;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (selectedBar == index)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),

                        Container(
                          width: 46,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: selectedBar == index
                                ? Colors.orange
                                : const Color(0xFF2F9E8F),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          height: 42,
                          child: Text(
                            poli[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// DETAIL
  Widget _buildDetail() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: const BoxDecoration(
              color: Color(0xFF2F9E8F),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: const Text(
              "Detail per Poli & Layanan",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ...detailPoli.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item["nama"]!,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F5E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item["jumlah"]!,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
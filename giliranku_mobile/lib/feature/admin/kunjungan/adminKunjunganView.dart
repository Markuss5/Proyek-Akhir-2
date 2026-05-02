import 'package:flutter/material.dart';
import 'package:giliranku/feature/admin/adminHeader.dart';

class AdminKunjunganView extends StatefulWidget {
  const AdminKunjunganView({super.key});

  @override
  State<AdminKunjunganView> createState() => _AdminKunjunganViewState();
}

class _AdminKunjunganViewState extends State<AdminKunjunganView> {
  int _selectedPeriode = 0;
  int _selectedBar = -1;

  final List<String> _periode = ["Harian", "Mingguan", "Bulanan"];

  final List<Map<String, dynamic>> _statistik = [
    {
      "judul": "Pasien Hari Ini",
      "angka": "67",
      "icon": Icons.people_alt_rounded,
      "color": const Color(0xFF2A9D8F),
      "bg": const Color(0xFFE6F7F5),
    },
    {
      "judul": "Rata-rata / Hari",
      "angka": "48",
      "icon": Icons.trending_up_rounded,
      "color": const Color(0xFF5C6BC0),
      "bg": const Color(0xFFEEF0FF),
    },
    {
      "judul": "Apotek",
      "angka": "64",
      "icon": Icons.local_pharmacy_rounded,
      "color": const Color(0xFFFF7043),
      "bg": const Color(0xFFFFF0EC),
    },
  ];

  final List<String> _poliLabels = [
    "Poli\nUmum",
    "Poli\nParu",
    "Poli\nJantung",
    "Poli\nAnak",
    "Apotek",
  ];

  final List<double> _dataChart = [14, 8, 12, 9, 24];

  final List<Map<String, dynamic>> _detailPoli = [
    {
      "nama": "Poli Umum",
      "jumlah": "14 Pasien",
      "icon": Icons.medical_services_rounded,
      "color": const Color(0xFF2A9D8F),
    },
    {
      "nama": "Poli Paru",
      "jumlah": "8 Pasien",
      "icon": Icons.air_rounded,
      "color": const Color(0xFF5C6BC0),
    },
    {
      "nama": "Poli Jantung",
      "jumlah": "12 Pasien",
      "icon": Icons.favorite_rounded,
      "color": const Color(0xFFE53935),
    },
    {
      "nama": "Poli Anak",
      "jumlah": "9 Pasien",
      "icon": Icons.child_care_rounded,
      "color": const Color(0xFFFF9800),
    },
    {
      "nama": "Apotek",
      "jumlah": "24 Pasien",
      "icon": Icons.local_pharmacy_rounded,
      "color": const Color(0xFF66BB6A),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          // ── Header (Opsi B) ──────────────────────────────────────
          const AdminHeader(
            type: AdminHeaderType.page,
            pageTitle: "Laporan Kunjungan RS",
          ),

          // ── Content ──────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary cards overlap header
                    const SizedBox(height: 16),
                    _buildSummaryCards(),
                    const SizedBox(height: 16), 
                    const Text(
                      "Statistik Kunjungan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Kunjungan pasien per poliklinik & layanan",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 16),

                    // Periode filter
                    _buildPeriodeFilter(),
                    const SizedBox(height: 16),

                    // Chart card
                    _buildChartCard(),
                    const SizedBox(height: 16),

                    // Detail per poli
                    _buildDetailCard(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary Cards ────────────────────────────────────────────────
  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: _statistik.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == _statistik.length - 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(child: _buildStatItem(item)),
                if (!isLast)
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade100,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: item['bg'] as Color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item['icon'] as IconData,
              color: item['color'] as Color, size: 18),
          const SizedBox(height: 6),
          Text(
            item['angka'] as String,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: item['color'] as Color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item['judul'] as String,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ── Periode Filter ───────────────────────────────────────────────
  Widget _buildPeriodeFilter() {
    return Row(
      children: List.generate(_periode.length, (index) {
        final isActive = _selectedPeriode == index;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPeriode = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF2A9D8F) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF2A9D8F)
                      : Colors.grey.shade300,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color:
                              const Color(0xFF2A9D8F).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Text(
                _periode[index],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isActive ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Chart Card ───────────────────────────────────────────────────
  Widget _buildChartCard() {
    const double maxValue = 24;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Grafik Kunjungan",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _periode[_selectedPeriode],
                    style: TextStyle(
                        fontSize: 12, color: const Color(0xFF2A9D8F)),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2A9D8F),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      "Aktif",
                      style: TextStyle(
                        color: Color(0xFF2A9D8F),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bars
          SizedBox(
            height: 240,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_dataChart.length, (index) {
                final value = _dataChart[index];
                final barHeight = (value / maxValue) * 140;
                final isSelected = _selectedBar == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedBar = isSelected ? -1 : index;
                    }),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Tooltip
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: isSelected ? 1 : 0,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${value.toInt()}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 36,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isSelected
                                  ? [
                                      const Color(0xFFFF9800),
                                      const Color(0xFFFF7043),
                                    ]
                                  : [
                                      const Color(0xFF2A9D8F),
                                      const Color(0xFF1E7B6E),
                                    ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Label
                        SizedBox(
                          height: 36,
                          child: Text(
                            _poliLabels[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? const Color(0xFF1A1A2E)
                                  : Colors.grey[500],
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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

          // Legend hint
          const SizedBox(height: 8),
          Center(
            child: Text(
              "Tap bar untuk melihat detail",
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Detail Card ──────────────────────────────────────────────────
  Widget _buildDetailCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header detail
          Container(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
            decoration: const BoxDecoration(
              color: Color(0xFF2A9D8F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.bar_chart_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  "Detail per Poli & Layanan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Rows
          ListView.separated(
          padding: const EdgeInsets.only(top: 12), 
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
            itemCount: _detailPoli.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.shade100,
              indent: 18,
              endIndent: 18,
            ),
            itemBuilder: (_, index) {
              final item = _detailPoli[index];
              final color = item['color'] as Color;
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item['icon'] as IconData,
                          color: color, size: 18),
                    ),
                    const SizedBox(width: 12),

                    // Name
                    Expanded(
                      child: Text(
                        item['nama'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Progress bar + count
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['jumlah'] as String,
                          style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: 80,
                          height: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _dataChart[index] / 24,
                              backgroundColor: Colors.grey.shade100,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/feature/admin/adminHeader.dart';

class AdminKunjunganView extends StatefulWidget {
  const AdminKunjunganView({super.key});

  @override
  State<AdminKunjunganView> createState() => _AdminKunjunganViewState();
}

class _AdminKunjunganViewState extends State<AdminKunjunganView> {
  int _selectedPeriode = 0;
  int _selectedBar = -1;

  final List<String> _periode = ['Harian', 'Mingguan', 'Bulanan'];
  final List<String> _periodKeys = ['daily', 'weekly', 'monthly'];

  bool _isLoading = true;
  List<Map<String, dynamic>> _perPoliStats = [];

  int get _totalKunjungan =>
      _perPoliStats.fold(0, (s, e) => s + (e['jumlah'] as int? ?? 0));

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() {
      _isLoading = true;
      _selectedBar = -1;
    });
    final period = _periodKeys[_selectedPeriode];
    final data = await ApiDataSource().fetchKunjunganStats(period);
    if (mounted) {
      setState(() {
        _perPoliStats = data;
        _isLoading = false;
      });
    }
  }

  IconData _iconForPoli(String name) {
    final n = name.toLowerCase();
    if (n.contains('paru')) return Icons.air_rounded;
    if (n.contains('jantung')) return Icons.favorite_rounded;
    if (n.contains('anak')) return Icons.child_care_rounded;
    if (n.contains('apotek') || n.contains('farmasi')) {
      return Icons.local_pharmacy_rounded;
    }
    if (n.contains('gigi')) return Icons.sentiment_satisfied_rounded;
    if (n.contains('kandungan') || n.contains('obgyn')) {
      return Icons.pregnant_woman_rounded;
    }
    return Icons.medical_services_rounded;
  }

  Color _colorForIndex(int i) {
    const colors = [
      Color(0xFF2A9D8F),
      Color(0xFF5C6BC0),
      Color(0xFFE53935),
      Color(0xFFFF9800),
      Color(0xFF66BB6A),
      Color(0xFF00ACC1),
      Color(0xFFAB47BC),
    ];
    return colors[i % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          const AdminHeader(
            type: AdminHeaderType.page,
            pageTitle: 'Laporan Kunjungan RS',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchStats,
              color: const Color(0xFF2A9D8F),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSummaryCards(),
                    const SizedBox(height: 16),
                    const Text(
                      'Statistik Kunjungan',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kunjungan pasien per poliklinik & layanan',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 16),
                    _buildPeriodeFilter(),
                    const SizedBox(height: 16),
                    _buildChartCard(),
                    const SizedBox(height: 16),
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

  Widget _buildSummaryCards() {
    final avg = _perPoliStats.isEmpty
        ? 0
        : (_totalKunjungan / _perPoliStats.length).round();

    final summaryItems = [
      {
        'judul': 'Total Kunjungan',
        'angka': '$_totalKunjungan',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF2A9D8F),
        'bg': const Color(0xFFE6F7F5),
      },
      {
        'judul': 'Rata-rata / Poli',
        'angka': '$avg',
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF5C6BC0),
        'bg': const Color(0xFFEEF0FF),
      },
      {
        'judul': 'Periode',
        'angka': _periode[_selectedPeriode],
        'icon': Icons.calendar_today_rounded,
        'color': const Color(0xFFFF7043),
        'bg': const Color(0xFFFFF0EC),
      },
    ];

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
        children: summaryItems.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == summaryItems.length - 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(child: _buildStatItem(item)),
                if (!isLast)
                  Container(
                      width: 1, height: 40, color: Colors.grey.shade100),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: item['color'] as Color,
            ),
          ),
          const SizedBox(height: 2),
          Text(item['judul'] as String,
              style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPeriodeFilter() {
    return Row(
      children: List.generate(_periode.length, (index) {
        final isActive = _selectedPeriode == index;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedPeriode = index);
              _fetchStats();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF2A9D8F)
                    : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF2A9D8F)
                      : Colors.grey.shade300,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2A9D8F)
                              .withValues(alpha: 0.25),
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

  Widget _buildChartCard() {
    if (_isLoading) {
      return const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()));
    }
    if (_perPoliStats.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('Belum ada data kunjungan',
            style: TextStyle(color: Colors.grey[500])),
      );
    }

    final maxValue = _perPoliStats
        .map((e) => (e['jumlah'] as int? ?? 0).toDouble())
        .fold(1.0, (a, b) => a > b ? a : b);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Grafik Kunjungan',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 2),
                  Text(_periode[_selectedPeriode],
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF2A9D8F))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
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
                            color: Color(0xFF2A9D8F))),
                    const SizedBox(width: 5),
                    const Text('Live',
                        style: TextStyle(
                            color: Color(0xFF2A9D8F),
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_perPoliStats.length, (index) {
                final stat = _perPoliStats[index];
                final value = (stat['jumlah'] as int? ?? 0).toDouble();
                final barHeight = maxValue > 0
                    ? (value / maxValue) * 140
                    : 0.0;
                final isSelected = _selectedBar == index;
                final color = _colorForIndex(index);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedBar = isSelected ? -1 : index;
                    }),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                              '${value.toInt()}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
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
                                      const Color(0xFFFF7043)
                                    ]
                                  : [
                                      color,
                                      color.withValues(alpha: 0.7)
                                    ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 36,
                          child: Text(
                            (stat['poly_name'] as String? ?? '')
                                .replaceAll('Poli ', 'Poli\n'),
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
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Tap bar untuk melihat detail',
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Detail Card ────────────────────────────────────────────────────────────
  Widget _buildDetailCard() {
    if (_isLoading) return const SizedBox.shrink();

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
          Container(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
            decoration: const BoxDecoration(
              color: Color(0xFF2A9D8F),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Detail per Poli & Layanan',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),
          if (_perPoliStats.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada data kunjungan',
                  style: TextStyle(color: Colors.grey)),
            )
          else
            ListView.separated(
              padding: const EdgeInsets.only(top: 12),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _perPoliStats.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.shade100,
                indent: 18,
                endIndent: 18,
              ),
              itemBuilder: (_, index) {
                final stat = _perPoliStats[index];
                final color = _colorForIndex(index);
                final jumlah = stat['jumlah'] as int? ?? 0;
                final maxJ = _perPoliStats
                    .map((e) => e['jumlah'] as int? ?? 0)
                    .fold(1, (a, b) => a > b ? a : b);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                            _iconForPoli(
                                stat['poly_name'] as String? ?? ''),
                            color: color,
                            size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stat['poly_name'] as String? ?? '-',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$jumlah Pasien',
                            style: TextStyle(
                                color: color,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 80,
                            height: 5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: jumlah / maxJ,
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
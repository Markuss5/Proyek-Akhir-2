import 'package:flutter/material.dart';

import 'booking/bookingLookupView.dart';
import 'consultation/consultationMenuView.dart';
import 'pharmacy/pharmacyQueueView.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions(context);
    final width = MediaQuery.of(context).size.width;
    
    // Optimasi jumlah kolom untuk layar kiosk (lebih responsif dan lega)
    final crossAxisCount = width >= 1200
        ? 3
        : width >= 750
            ? 3
            : 1; // 1 Kolom jika di smartphone biasa agar tidak overflow

    return Scaffold(
      backgroundColor: const Color(0xFF04261A), // Dark mode base untuk estetika premium
      body: Stack(
        children: [
          // Background Gradient mewah
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF063A25),
                  Color(0xFF031F15),
                  Color(0xFF010A07),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Halo Ornamen Glow
          Positioned(
            top: -100,
            right: -100,
            child: _HaloCircle(size: 400, color: const Color(0xFF1F9E76).withOpacity(0.25)),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: _HaloCircle(size: 500, color: const Color(0xFF0E7054).withOpacity(0.2)),
          ),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _DashboardHeader()),
                
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 28,
                      crossAxisSpacing: 28,
                      childAspectRatio: width >= 750 ? 0.95 : 1.4,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _DashboardCard(action: actions[index]),
                      childCount: actions.length,
                    ),
                  ),
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
                    child: _InfoBanner(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_DashboardAction> _buildActions(BuildContext context) {
    return [
      _DashboardAction(
        title: 'Antrian\nKonsultasi',
        subtitle: 'Pendaftaran BPJS & Umum',
        icon: Icons.medical_services_rounded,
        topColor: const Color(0xFF26D095),
        botColor: const Color(0xFF0E7054),
        iconColor: const Color(0xFFE8FFF5),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConsultationMenuView()),
        ),
      ),
      _DashboardAction(
        title: 'Antrian\nFarmasi',
        subtitle: 'Ambil Nomor Obat & Resep',
        icon: Icons.local_pharmacy_rounded,
        topColor: const Color(0xFF00B4D8),
        botColor: const Color(0xFF0077B6),
        iconColor: const Color(0xFFE0F7FA),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PharmacyQueueView()),
        ),
      ),
      _DashboardAction(
        title: 'Cetak\nAntrian',
        subtitle: 'Scan / Masukkan Kode Booking',
        icon: Icons.qr_code_scanner_rounded,
        topColor: const Color(0xFFFFB703),
        botColor: const Color(0xFFFB8500),
        iconColor: const Color(0xFFFFF6E0),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookingLookupView()),
        ),
      ),
    ];
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF26D095).withOpacity(0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Image.asset(
                  'lib/assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RSUD PORSEA',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F9E76).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFF26D095).withOpacity(0.3)),
                      ),
                      child: const Text(
                        'SISTEM ANTRIAN TERPADU',
                        style: TextStyle(
                          color: Color(0xFF26D095),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Text(
            'Selamat Datang',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Silakan sentuh salah satu layanan di bawah ini untuk memulai.',
            style: TextStyle(
              color: Color(0xFFA2C5B9),
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card Menu ────────────────────────────────────────────────────────────────
class _DashboardCard extends StatefulWidget {
  final _DashboardAction action;
  const _DashboardCard({required this.action});

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> with TickerProviderStateMixin {
  late AnimationController _ctrlScale;
  late Animation<double> _scale;

  late AnimationController _ctrlArrow;
  late Animation<double> _arrowTranslation;

  @override
  void initState() {
    super.initState();
    
    _ctrlScale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrlScale, curve: Curves.easeInOut));

    _ctrlArrow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _arrowTranslation = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(parent: _ctrlArrow, curve: Curves.easeInOut),
    );

    _ctrlArrow.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrlScale.dispose();
    _ctrlArrow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrlScale.forward(),
        onTapUp: (_) {
          _ctrlScale.reverse();
          a.onTap();
        },
        onTapCancel: () => _ctrlScale.reverse(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [a.topColor, a.botColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: a.botColor.withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: 1,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Efek Gradasi Glossy Atas
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Ornamen Lingkaran Modern Abstract
              Positioned(
                bottom: -40,
                right: -40,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.white.withOpacity(0.04),
                ),
              ),
              
              // Konten Utama
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                          ),
                          child: Icon(a.icon, color: a.iconColor, size: 32),
                        ),
                        
                        // Panah Beranimasi (Maju-Mundur)
                        AnimatedBuilder(
                          animation: _arrowTranslation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_arrowTranslation.value, 0),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    // Blok Teks Bawah (Aman dari overflow)
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            a.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            a.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Info Banner ──────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF26D095).withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF26D095),
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Pelayanan',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pastikan Anda mengambil nomor antrian yang sesuai. Jika mengalami kesulitan, silakan hubungi petugas informasi di samping mesin ini.',
                  style: TextStyle(
                    color: Color(0xFFA2C5B9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Decorative Halo Circle ──────────────────────────────────────────────────
class _HaloCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _HaloCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ─── Model Data Action ────────────────────────────────────────────────────────
class _DashboardAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color topColor;
  final Color botColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _DashboardAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.topColor,
    required this.botColor,
    required this.iconColor,
    required this.onTap,
  });
}
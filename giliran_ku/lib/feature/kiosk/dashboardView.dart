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
    
    final crossAxisCount = width >= 900
        ? 3
        : width >= 640
            ? 2
            : 2;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFCBEEDF),
                  Color(0xFFDDF4EB),
                  Color(0xFFF5FFFB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          const Positioned(
            top: -50,
            right: -40,
            child: _HaloCircle(size: 180, color: Color(0xFF7DD4B5)),
          ),
          const Positioned(
            bottom: -60,
            left: -30,
            child: _HaloCircle(size: 200, color: Color(0xFF8ECFB8)),
          ),
          
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _DashboardHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _DashboardCard(action: actions[index]),
                      childCount: actions.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
        subtitle: 'BPJS & Umum',
        icon: Icons.medical_services_outlined,
        topColor: const Color(0xFF1F9E76),
        botColor: const Color(0xFF0E7054),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConsultationMenuView()),
        ),
      ),
      _DashboardAction(
        title: 'Antrian\nFarmasi',
        subtitle: 'Ambil nomor obat',
        icon: Icons.local_pharmacy_outlined,
        topColor: const Color(0xFF17A889),
        botColor: const Color(0xFF0A7D67),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PharmacyQueueView()),
        ),
      ),
      _DashboardAction(
        title: 'Cetak\nAntrian',
        subtitle: 'Kode booking',
        icon: Icons.qr_code_2_outlined,
        topColor: const Color(0xFF0F8C6D),
        botColor: const Color(0xFF07624D),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookingLookupView()),
        ),
      ),
    ];
  }
}

class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 75,
                height: 75,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0A7054).withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'lib/assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RSUD PORSEA',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF063A25),
                            letterSpacing: 0.8,
                            height: 1,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDF4EB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Sistem Antrian Terpadu',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF0E7054),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Layanan Rumah Sakit',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF063A25),
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan pilih layanan yang ingin Anda akses.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4D7C6B),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cek antrian, farmasi, atau cetak tiket booking dengan cepat.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF3A7060),
                  fontWeight: FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final _DashboardAction action;
  const _DashboardCard({required this.action});

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> with TickerProviderStateMixin {
  late final AnimationController _ctrlScale;
  late final Animation<double> _scale;

  late final AnimationController _ctrlArrow;
  late final Animation<double> _arrowTranslation;

  @override
  void initState() {
    super.initState();
    
    _ctrlScale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrlScale, curve: Curves.easeInOut));

    _ctrlArrow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    
    _arrowTranslation = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(parent: _ctrlArrow, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ctrlArrow.repeat(reverse: true);
      }
    });
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
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: a.botColor.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -22, right: -22,
                child: Container(
                  width: 75, height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(a.icon, color: Colors.white, size: 22),
                        ),
                        AnimatedBuilder(
                          animation: _arrowTranslation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_arrowTranslation.value, 0),
                              child: child,
                            );
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            height: 1.15,
                          ),
                    ),
                    const SizedBox(height: 4),
                    
                    Text(
                      a.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
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

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB8E4D2), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E7054).withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFDDF4EB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.favorite_border,
              color: Color(0xFF0E7054),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tetap sehat bersama kami',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF063A25),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gunakan nomor antrian sesuai poli agar pelayanan lebih cepat.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF3A7060),
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
        color: color.withOpacity(0.35),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DashboardAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color topColor;
  final Color botColor;
  final VoidCallback onTap;

  const _DashboardAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.topColor,
    required this.botColor,
    required this.onTap,
  });
}
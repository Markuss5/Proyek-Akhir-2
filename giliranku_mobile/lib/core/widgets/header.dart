// lib/core/widgets/app_header.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:giliranku/core/theme/theme.dart';

enum HeaderMode { home, page }

class AppHeader extends StatelessWidget {
  final HeaderMode mode;
  final String? patientName;
  final bool isLoggedIn;
  final String? title;
  final String subtitle;
  final IconData? pageIcon;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    required this.mode,
    this.patientName,
    this.isLoggedIn = false,
    this.title,
    this.subtitle = 'RSUD Porsea',
    this.pageIcon,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return mode == HeaderMode.home
        ? _HomeHeader(patientName: patientName, isLoggedIn: isLoggedIn)
        : _PageHeader(
            title: title ?? '',
            subtitle: subtitle,
            pageIcon: pageIcon,
            onBack: onBack ?? () => Navigator.maybePop(context),
          );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  final String? patientName;
  final bool isLoggedIn;

  const _HomeHeader({this.patientName, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // Gunakan MediaQuery agar SafeArea diperhitungkan
    final topPad = MediaQuery.of(context).padding.top;

    // Tinggi area gradient: status bar + konten logo
    const double gradientContent = 200;
    final double gradientHeight = topPad + gradientContent;

    // Greeting card mengapung 36px melampaui batas bawah gradient
    const double cardOverlap = 36.0;
    const double cardHeight  = 72.0;

    return SizedBox(
      height: gradientHeight + cardHeight - cardOverlap + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          // ── Gradient + kurva bawah ──
          Positioned(
            top: 0, left: 0, right: 0,
            height: gradientHeight + 10, // beri ruang untuk kurva
            child: ClipPath(
              clipper: _BellClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A8A7A), Color(0xFF18AC9A), Color(0xFF0C9E8C)],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Lingkaran dekorasi
                    Positioned(right: -70, top: -70,
                        child: _Bubble(size: 260, opacity: 0.07)),
                    Positioned(left: -50, bottom: 40,
                        child: _Bubble(size: 190, opacity: 0.05)),
                    Positioned(left: 110, top: 20,
                        child: _Bubble(size: 70, opacity: 0.06)),

                    // Top bar: chip RS + notif
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 0),
                      child: Row(
                        children: [
                          _GlassChip(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6, height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6EFDE0),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text('RSUD Porsea',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const _GlassIconBtn(icon: Iconsax.notification),
                        ],
                      ),
                    ),

                    // Logo + nama app — di tengah area gradient
                    Positioned(
                      top: topPad + 46,
                      left: 0, right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // logo
                          Image.asset(
                            'assets/images/logo.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Iconsax.hospital,
                              color: Colors.white,
                              size: 70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Kurva smooth satu busur —  gelombang lembut di bawah header
class _BellClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..lineTo(0, h - 50);

    //  SINGLE CURVE ( smooth, no patah)
    path.cubicTo(
      w * 0.25, h + 25,
      w * 0.75, h + 25,
      w,        h - 50,
    );

    path
      ..lineTo(w, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE HEADER 
// ─────────────────────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? pageIcon;
  final VoidCallback onBack;

  const _PageHeader({
    required this.title,
    required this.subtitle,
    this.pageIcon,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      height: topPad + 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
                    Color(0xFF0DB89E),
                    Color(0xFF0A6B5C),
                  ],
        ),
      ),
      child: Stack(
        children: [
          //  glow effect
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

           //  garis dekorasi bawah
            Positioned(
              bottom: 20,
              left: 40,
              right: 40,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

          // 🔙 back button
              Positioned(
                top: topPad + 8,
                left: 16,
                child: GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

          //  CONTENT
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (pageIcon != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      pageIcon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                const SizedBox(height: 10),

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
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

// Kurva asimetris halus untuk page header
class _PageWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()..lineTo(0, h - 36);

    path.cubicTo(w * 0.28, h - 36, w * 0.52, h + 16, w * 0.68, h - 10);
    path.cubicTo(w * 0.82, h - 32, w * 0.92, h - 44, w, h - 28);

    path..lineTo(w, 0)..close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// GREETING CARD — status login user
// ─────────────────────────────────────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  final String name;
  final bool isLoggedIn;

  const _GreetingCard({required this.name, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 24, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar gradient
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9B86), Color(0xFF1DB8A0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 8, offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.waving_hand_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),

          // Badge status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              isLoggedIn ? 'Aktif' : 'Tamu',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final double size;
  final double opacity;
  const _Bubble({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}

class _GlassChip extends StatelessWidget {
  final Widget child;
  const _GlassChip({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: child,
      );
}

class _GlassIconBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  const _GlassIconBtn({required this.icon, this.size = 18});

  @override
  Widget build(BuildContext context) => Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        ),
        child: Icon(icon, color: Colors.white, size: size),
      );
}
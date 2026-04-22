import 'package:flutter/material.dart';
import 'package:giliranku/core/theme/theme.dart';

/// Header reusable — bisa dipakai di halaman mana saja.
/// [patientName] & [isLoggedIn] — untuk greeting card di bawah header
/// [showGreeting] — false jika halaman lain tidak butuh greeting card
class AppHeader extends StatelessWidget {
  final String? patientName;
  final bool isLoggedIn;
  final bool showGreeting;

  const AppHeader({
    super.key,
    this.patientName,
    this.isLoggedIn = false,
    this.showGreeting = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Wave background ──
        ClipPath(
          clipper: _WaveClipper(),
          child: Container(
            height: 185,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [   AppColors.primary,  const Color(0xFF1E857B), ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(children: [
              Positioned(top: -30, right: -30, child: _circle(150, 0.06)),
              Positioned(bottom: 10, left: -20, child: _circle(100, 0.05)),
              Positioned(top: 40, right: 80,   child: _circle(60,  0.04)),
            ]),
          ),
        ),

        // ── Logo dari lib/images/logo.png ──
        Positioned(
          top: 48,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              'lib/assets/images/logo.png',
              height: 50,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const _FallbackLogo(),
            ),
          ),
        ),

        // ── Greeting card (opsional) ──
        if (showGreeting)
          Positioned(
            bottom: -26,
            left: 20,
            right: 20,
            child: _GreetingCard(
              name: patientName ?? 'Tamu',
              isLoggedIn: isLoggedIn,
            ),
          ),

        SizedBox(height: showGreeting ? 185 : 160),
      ],
    );
  }

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}

// ── Wave Clipper ──
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2, size.height + 20,
      size.width, size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

// ── Greeting Card ──
class _GreetingCard extends StatelessWidget {
  final String name;
  final bool isLoggedIn;
  const _GreetingCard({required this.name, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? 'Halo, $name 👋' : 'Halo, Tamu 👋',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Selamat datang di RSUD Porsea',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Aktif',
              style: TextStyle(
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

// ── Fallback Logo (jika file tidak ditemukan) ──
class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Giliran',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w300),
              ),
              TextSpan(
                text: 'Ku',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
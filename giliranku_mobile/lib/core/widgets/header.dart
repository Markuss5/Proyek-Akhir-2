import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

enum HeaderMode { home, page, simple }

class AppHeader extends StatelessWidget {
  final HeaderMode mode;
  final String? patientName;
  final bool isLoggedIn;
  final String? title;
  final IconData? pageIcon;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    required this.mode,
    this.patientName,
    this.isLoggedIn = false,
    this.title,
    this.pageIcon,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return mode == HeaderMode.home
        ? _HomeHeader(patientName: patientName, isLoggedIn: isLoggedIn)
        : _PageHeader(
            title: title ?? '',
            pageIcon: pageIcon,
            onBack: onBack ?? () => Navigator.maybePop(context),
          );
  }
}

class _HomeHeader extends StatelessWidget {
  final String? patientName;
  final bool isLoggedIn;

  const _HomeHeader({this.patientName, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    const double gradientContent = 200;
    final double gradientHeight = topPad + gradientContent;

    const double cardOverlap = 36.0;
    const double cardHeight  = 72.0;

    return SizedBox(
      height: gradientHeight + cardHeight - cardOverlap + 8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          Positioned(
            top: 0, left: 0, right: 0,
            height: gradientHeight + 10,
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
                    Positioned(right: -70, top: -70,
                        child: _Bubble(size: 260, opacity: 0.07)),
                    Positioned(left: -50, bottom: 40,
                        child: _Bubble(size: 190, opacity: 0.05)),
                    Positioned(left: 110, top: 20,
                        child: _Bubble(size: 70, opacity: 0.06)),

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
                        ],
                      ),
                    ),

                    Positioned(
                      top: topPad + 46,
                      left: 0, right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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

class _BellClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..lineTo(0, h - 50);

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

class _PageHeader extends StatelessWidget {
  final String title;
  final IconData? pageIcon;
  final VoidCallback onBack;

  const _PageHeader({
    required this.title,
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
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 86,
                      height: 86,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_hospital_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
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

                ],
            ),
          ),
        ],
      ),
    );
  }
}

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
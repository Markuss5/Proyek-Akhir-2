import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giliranku/core/theme/theme.dart';

class _IconPainter extends CustomPainter {
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final void Function(Canvas, double, bool, Color) draw;

  const _IconPainter({
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.draw,
  });

  @override
  void paint(Canvas canvas, Size size) {
    draw(canvas, size.width / 24, isActive, isActive ? activeColor : inactiveColor);
  }

  @override
  bool shouldRepaint(_IconPainter o) =>
      o.isActive != isActive || o.activeColor != activeColor;
}

void _drawHome(Canvas c, double s, bool active, Color color) {
  final stroke = Paint()
    ..color = active ? Colors.white : color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  c.drawPath(Path()..moveTo(3*s,12*s)..lineTo(12*s,3*s)..lineTo(21*s,12*s), stroke);

  final body = Path()
    ..moveTo(5*s,10*s)..lineTo(5*s,20*s)..lineTo(10*s,20*s)
    ..lineTo(10*s,14*s)..lineTo(14*s,14*s)..lineTo(14*s,20*s)
    ..lineTo(19*s,20*s)..lineTo(19*s,10*s)..close();

  if (active) {
    c.drawPath(body, Paint()..color = Colors.white..style = PaintingStyle.fill);
  } else {
    c.drawPath(body, stroke);
  }
}

void _drawInfo(Canvas c, double s, bool active, Color color) {
  final doc = Path()
    ..moveTo(6*s,2*s)..lineTo(14*s,2*s)..lineTo(18*s,6*s)
    ..lineTo(18*s,22*s)..lineTo(6*s,22*s)..close();
  final fold = Path()
    ..moveTo(14*s,2*s)..lineTo(14*s,6*s)..lineTo(18*s,6*s);

  final stroke = Paint()
    ..color = color..style = PaintingStyle.stroke
    ..strokeWidth = 1.6..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

  if (active) {
    c.drawPath(doc, Paint()..color = Colors.white..style = PaintingStyle.fill);
    c.drawPath(fold, stroke..color = color);
  } else {
    c.drawPath(doc, stroke);
    c.drawPath(fold, stroke);
  }

  final line = Paint()
    ..color = active ? color : color..style = PaintingStyle.stroke
    ..strokeWidth = 1.8..strokeCap = StrokeCap.round;
  c.drawLine(Offset(9*s,11*s), Offset(15*s,11*s), line);
  c.drawLine(Offset(9*s,14*s), Offset(15*s,14*s), line);
  c.drawLine(Offset(9*s,17*s), Offset(13*s,17*s), line);
}

void _drawCalendar(Canvas c, double s, bool active, Color color) {
  final stroke = Paint()
    ..color = active ? color : color..style = PaintingStyle.stroke
    ..strokeWidth = active ? 2.0 : 1.6..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  if (active) {
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(3*s,4*s,18*s,17*s), Radius.circular(2*s)),
        Paint()..color = Colors.white..style = PaintingStyle.fill);
    c.drawRRect(RRect.fromRectAndCorners(Rect.fromLTWH(3*s,4*s,18*s,6*s),
        topLeft: Radius.circular(2*s), topRight: Radius.circular(2*s)),
        Paint()..color = color.withValues(alpha: 0.15)..style = PaintingStyle.fill);
  } else {
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(3*s,4*s,18*s,17*s),
        Radius.circular(2*s)), stroke);
    c.drawLine(Offset(3*s,10*s), Offset(21*s,10*s), stroke);
  }

  c.drawLine(Offset(8*s,2*s), Offset(8*s,6*s), stroke);
  c.drawLine(Offset(16*s,2*s), Offset(16*s,6*s), stroke);
  c.drawPath(Path()..moveTo(8*s,16*s)..lineTo(11*s,19*s)..lineTo(16*s,13*s), stroke);
}

void _drawProfile(Canvas c, double s, bool active, Color color) {
  final paint = active
      ? (Paint()..color = Colors.white..style = PaintingStyle.fill)
      : (Paint()..color = color..style = PaintingStyle.stroke
          ..strokeWidth = 1.6..strokeCap = StrokeCap.round);

  c.drawCircle(Offset(12*s,8*s), 4*s, paint);

  final arc = Path()
    ..moveTo(4*s,20*s)
    ..cubicTo(4*s,16*s, 7.6*s,13*s, 12*s,13*s)
    ..cubicTo(16.4*s,13*s, 20*s,16*s, 20*s,20*s);
  if (active) {
    c.drawPath(arc..close(), paint);
  } else {
    c.drawPath(arc, paint);
  }
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  static const _labels = ['Beranda', 'Informasi', 'Antrian', 'Profil'];
  static const _drawFns = [_drawHome, _drawInfo, _drawCalendar, _drawProfile];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.ink5,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.ink4, width: 0.5),
            ),
            child: Row(
              children: List.generate(4, (i) {
                final isActive = i == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () { HapticFeedback.lightImpact(); onTap(i); },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomPaint(
                            size: const Size(20, 20),
                            painter: _IconPainter(
                              isActive: isActive,
                              activeColor: AppColors.primary,
                              inactiveColor: AppColors.ink2,
                              draw: _drawFns[i],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _labels[i],
                            style: TextStyle(
                              fontFamily: AppText.caption.fontFamily,
                              fontSize: 10,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              color: isActive ? AppColors.white : AppColors.ink2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
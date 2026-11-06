import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Cincin progres "Dompet": busur Serene Blue di atas trek abu muda.
class GoalRing extends StatelessWidget {
  final double progress; // 0..1
  final double size;
  final double stroke;
  final Widget? child;
  const GoalRing({
    super.key,
    required this.progress,
    this.size = 72,
    this.stroke = 8,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(value, stroke),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Menggambar trek dan busur progres target.
class _RingPainter extends CustomPainter {
  final double progress;
  final double stroke;
  _RingPainter(this.progress, this.stroke);

  /// Melukis lingkaran dan busur progres.
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.border;
    canvas.drawCircle(center, radius, track);

    if (progress > 0) {
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primary;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2, 2 * math.pi * progress, false, arc);
    }
  }

  /// Memperbarui gambar saat progres atau ketebalan berubah.
  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.stroke != stroke;
}

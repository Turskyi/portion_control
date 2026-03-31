import 'dart:math' as math;

import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    final math.Random random = math.Random();
    _particles = List<_ConfettiParticle>.generate(72, (int index) {
      return _ConfettiParticle(
        startX: random.nextDouble(),
        sway: 0.3 + random.nextDouble() * 0.8,
        phase: random.nextDouble() * math.pi * 2,
        speed: 0.8 + random.nextDouble() * 1.2,
        size: 4 + random.nextDouble() * 5,
        color: _palette[random.nextInt(_palette.length)],
        isSquare: random.nextBool(),
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: _ConfettiPainter(
              progress: Curves.easeOut.transform(_controller.value),
              particles: _particles,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.startX,
    required this.sway,
    required this.phase,
    required this.speed,
    required this.size,
    required this.color,
    required this.isSquare,
  });

  final double startX;
  final double sway;
  final double phase;
  final double speed;
  final double size;
  final Color color;
  final bool isSquare;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.progress,
    required this.particles,
  });

  final double progress;
  final List<_ConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (final _ConfettiParticle particle in particles) {
      final double fall = math.pow(progress, 0.95).toDouble();
      final double y =
          (fall * size.height * (0.85 + particle.speed * 0.35)) - 40;
      if (y > size.height + 24) {
        continue;
      }

      final double x =
          particle.startX * size.width +
          math.sin((progress * 11) + particle.phase) * particle.sway * 22;

      final double fadeOut = progress < 0.7
          ? 1.0
          : (1.0 - (progress - 0.7) / 0.3);
      paint.color = particle.color.withValues(alpha: fadeOut.clamp(0.0, 1.0));

      if (particle.isSquare) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate((progress * 12) + particle.phase);
        final double s = particle.size;
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: s, height: s),
          paint,
        );
        canvas.restore();
      } else {
        canvas.drawCircle(Offset(x, y), particle.size * 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

const List<Color> _palette = <Color>[
  Color(0xFFF94144),
  Color(0xFFF3722C),
  Color(0xFFF8961E),
  Color(0xFF90BE6D),
  Color(0xFF43AA8B),
  Color(0xFF577590),
];

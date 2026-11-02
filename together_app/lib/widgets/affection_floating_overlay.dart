import 'dart:math';
import 'package:flutter/material.dart';

class AffectionFloatingOverlay extends StatefulWidget {
  final Widget child;
  final int triggerCounter;

  const AffectionFloatingOverlay({
    super.key,
    required this.child,
    required this.triggerCounter,
  });

  @override
  State<AffectionFloatingOverlay> createState() => _AffectionFloatingOverlayState();
}

class _AffectionFloatingOverlayState extends State<AffectionFloatingOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingHeart> _hearts = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(AffectionFloatingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerCounter != oldWidget.triggerCounter) {
      _spawnHearts();
    }
  }

  void _spawnHearts() {
    _hearts.clear();
    const emojis = ['❤️', '💖', '💕', '🥰', '✨', '💋', '🫂'];
    for (int i = 0; i < 18; i++) {
      _hearts.add(_FloatingHeart(
        startX: 0.1 + _random.nextDouble() * 0.8,
        startY: 0.8 + _random.nextDouble() * 0.15,
        speed: 0.7 + _random.nextDouble() * 0.6,
        size: 24.0 + _random.nextDouble() * 18.0,
        sway: (_random.nextDouble() - 0.5) * 0.25,
        emoji: emojis[_random.nextInt(emojis.length)],
      ));
    }
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating)
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: _HeartsPainter(hearts: _hearts, progress: _controller.value),
            ),
          ),
      ],
    );
  }
}

class _FloatingHeart {
  final double startX;
  final double startY;
  final double speed;
  final double size;
  final double sway;
  final String emoji;

  _FloatingHeart({
    required this.startX,
    required this.startY,
    required this.speed,
    required this.size,
    required this.sway,
    required this.emoji,
  });
}

class _HeartsPainter extends CustomPainter {
  final List<_FloatingHeart> hearts;
  final double progress;

  _HeartsPainter({required this.hearts, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final heart in hearts) {
      final currentY = (heart.startY - (progress * heart.speed)) * size.height;
      final currentX = (heart.startX + sin(progress * 6.28) * heart.sway) * size.width;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      final textSpan = TextSpan(
        text: heart.emoji,
        style: TextStyle(
          fontSize: heart.size,
          color: Colors.red.withOpacity(opacity),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(currentX, currentY));
    }
  }

  @override
  bool shouldRepaint(covariant _HeartsPainter oldDelegate) => true;
}

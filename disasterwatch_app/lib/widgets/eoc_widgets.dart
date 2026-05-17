import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/eoc_theme.dart';

/// Pulsing dot indicator for live/active status
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulseDot({super.key, required this.color, this.size = 8});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (ctx, _) {
        return SizedBox(
          width: widget.size * 3,
          height: widget.size * 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse
              Container(
                width: widget.size * (1 + _controller.value * 2),
                height: widget.size * (1 + _controller.value * 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(1 - _controller.value),
                ),
              ),
              // Solid center
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color,
                      blurRadius: widget.size,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Sector label with horizontal lines (like military map sections)
class SectorLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const SectorLabel({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? EOC.textSecondary;
    return Row(
      children: [
        Container(width: 12, height: 1, color: c),
        const SizedBox(width: 8),
        Text(text, style: EOC.label.copyWith(color: c)),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: c.withOpacity(0.3))),
      ],
    );
  }
}

/// Radar sweep loading animation
class RadarSweep extends StatefulWidget {
  final double size;
  final Color color;
  const RadarSweep({super.key, this.size = 100, this.color = EOC.amber});

  @override
  State<RadarSweep> createState() => _RadarSweepState();
}

class _RadarSweepState extends State<RadarSweep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (ctx, _) => CustomPaint(
          painter: _RadarPainter(_controller.value, widget.color),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RadarPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Concentric circles
    final circlePaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 3, circlePaint);
    }

    // Crosshairs
    canvas.drawLine(
        Offset(0, center.dy), Offset(size.width, center.dy), circlePaint);
    canvas.drawLine(
        Offset(center.dx, 0), Offset(center.dx, size.height), circlePaint);

    // Sweep
    final sweepAngle = progress * 2 * math.pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: sweepAngle - 0.5,
        endAngle: sweepAngle,
        colors: [color.withOpacity(0), color.withOpacity(0.8)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      sweepAngle - 0.5,
      0.5,
      true,
      sweepPaint,
    );

    // Sweep line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * math.cos(sweepAngle),
        center.dy + radius * math.sin(sweepAngle),
      ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.progress != progress;
}

/// EOC-styled button with chunky tactical feel
class TacticalButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final bool active;

  const TacticalButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color = EOC.cyan,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.15) : EOC.steel,
            border: Border.all(
              color: isEnabled
                  ? (active ? color : EOC.border)
                  : EOC.border.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(color: color.withOpacity(0.3), blurRadius: 8),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isEnabled
                    ? (active ? color : EOC.textPrimary)
                    : EOC.textMuted,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                style: EOC.label.copyWith(
                  color: isEnabled
                      ? (active ? color : EOC.textPrimary)
                      : EOC.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Primary action button (chunky for field use)
class PrimaryActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const PrimaryActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color = EOC.amber,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isEnabled ? color : color.withOpacity(0.3),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black, size: 24),
              const SizedBox(width: 12),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: EOC.monoFont,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// HUD-style stat card
class HudStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const HudStat({
    super.key,
    required this.label,
    required this.value,
    this.color = EOC.cyan,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: EOC.charcoal,
        border: Border(
          left: BorderSide(color: color, width: 2),
          top: BorderSide(color: EOC.border),
          right: BorderSide(color: EOC.border),
          bottom: BorderSide(color: EOC.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 10, color: color),
                const SizedBox(width: 4),
              ],
              Text(label, style: EOC.label),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: EOC.monoFont,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

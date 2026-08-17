import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Doiraviy progress ko'rsatkichi (Bosh sahifadagi "65%" bloki).
class ProgressRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final String? caption;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 96,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0.0, 1.0) * 100).round();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: 8,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kichik statistik katak.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.navy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

/// O'zlashtirish dinamikasi chizmasi — tashqi kutubxonasiz.
class DynamicsChart extends StatelessWidget {
  final List<MapEntry<String, double>> data;

  const DynamicsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'Hali natijalar yo‘q.\nBirorta testni bajaring — dinamika shu yerda chiziladi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      );
    }
    return SizedBox(
      height: 160,
      child: CustomPaint(
        painter: _ChartPainter(data),
        size: Size.infinite,
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;
  _ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0;
    const bottom = 22.0;
    final chartW = size.width - left - 8;
    final chartH = size.height - bottom - 8;

    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    final textStyle = const TextStyle(color: AppColors.textMuted, fontSize: 10);

    // gorizontal to'r va o'q belgilari
    for (var i = 0; i <= 4; i++) {
      final y = 8 + chartH * i / 4;
      canvas.drawLine(Offset(left, y), Offset(left + chartW, y), grid);
      final tp = TextPainter(
        text: TextSpan(text: '${100 - i * 25}%', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 6));
    }

    if (data.isEmpty) return;

    Offset pointAt(int i) {
      final x = data.length == 1
          ? left + chartW / 2
          : left + chartW * i / (data.length - 1);
      final v = data[i].value.clamp(0.0, 100.0);
      final y = 8 + chartH * (1 - v / 100);
      return Offset(x, y);
    }

    final path = Path();
    final fill = Path();
    for (var i = 0; i < data.length; i++) {
      final p = pointAt(i);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
        fill.moveTo(p.dx, 8 + chartH);
        fill.lineTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
        fill.lineTo(p.dx, p.dy);
      }
    }
    fill.lineTo(pointAt(data.length - 1).dx, 8 + chartH);
    fill.close();

    // 0x1F ≈ 12% shaffoflik — Flutter versiyasidan qat'i nazar ishlaydi.
    canvas.drawPath(
      fill,
      Paint()..color = const Color(0x1F2563EB),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < data.length; i++) {
      final p = pointAt(i);
      canvas.drawCircle(p, 4, Paint()..color = Colors.white);
      canvas.drawCircle(
        p,
        4,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final tp = TextPainter(
        text: TextSpan(text: data[i].key, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          math.max(0, math.min(size.width - tp.width, p.dx - tp.width / 2)),
          size.height - 14,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => old.data != data;
}

/// Bosqich belgisi (nazariya / test / lab ...).
IconData stageIcon(String stage) {
  switch (stage) {
    case 'theory':
      return Icons.menu_book_outlined;
    case 'interactive':
      return Icons.extension_outlined;
    case 'vlab':
      return Icons.science_outlined;
    case 'protocol':
      return Icons.assignment_outlined;
    case 'test':
      return Icons.check_box_outlined;
    default:
      return Icons.circle_outlined;
  }
}

/// Test/topshiriq varianti. Diagnostika va test ekranlarida ishlatiladi.
class OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final bool selected;
  final Color? borderColor;
  final Color? fillColor;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.label,
    required this.text,
    required this.selected,
    this.borderColor,
    this.fillColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border =
        borderColor ?? (selected ? AppColors.primary : AppColors.border);
    final fill =
        fillColor ?? (selected ? const Color(0xFFEFF6FF) : Colors.white);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: selected ? 1.5 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? border : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Xabar ko'rsatish uchun qulaylik.
void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

import 'package:flutter/material.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../theme/app_theme.dart';
import 'hold_to_confirm_button.dart';

/// Pause/resume detection + press-and-hold finish, both labelled and 56 dp.
///
/// The two actions sit apart (16 dp gap, different shapes) so a gloved
/// thumb does not hit "Terminar" when reaching for pause.
class SessionActionBar extends StatelessWidget {
  const SessionActionBar({
    super.key,
    required this.held,
    required this.onToggleHold,
    required this.onFinish,
  });

  final bool held;
  final VoidCallback onToggleHold;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onToggleHold,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                foregroundColor: held ? AppTheme.lineHot : AppTheme.mist,
                side: BorderSide(color: AppTheme.mist.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              icon: Icon(
                held ? Icons.play_arrow_rounded : Icons.pause_rounded,
                size: 28,
              ),
              label: Text(
                held ? l10n.resumeMotionDetection : l10n.pauseMotionDetection,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: HoldToConfirmButton(
              onConfirmed: onFinish,
              label: l10n.rideFinishShort,
              icon: const CheckeredFlagIcon(size: 24, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Racing finish flag: 4×3 checkerboard.
class CheckeredFlagIcon extends StatelessWidget {
  const CheckeredFlagIcon({
    super.key,
    this.size = 24,
    this.color = AppTheme.mist,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CheckeredFlagPainter(color)),
    );
  }
}

class _CheckeredFlagPainter extends CustomPainter {
  _CheckeredFlagPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final pole = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.08),
      Offset(size.width * 0.12, size.height * 0.92),
      pole,
    );

    const cols = 4;
    const rows = 3;
    final left = size.width * 0.2;
    final top = size.height * 0.1;
    final flagW = size.width * 0.74;
    final flagH = size.height * 0.58;
    final cellW = flagW / cols;
    final cellH = flagH / rows;
    final fill = Paint()..color = color;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if ((r + c).isEven) {
          canvas.drawRect(
            Rect.fromLTWH(left + c * cellW, top + r * cellH, cellW, cellH),
            fill,
          );
        }
      }
    }
    canvas.drawRect(
      Rect.fromLTWH(left, top, flagW, flagH),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.05,
    );
  }

  @override
  bool shouldRepaint(covariant _CheckeredFlagPainter oldDelegate) =>
      oldDelegate.color != color;
}

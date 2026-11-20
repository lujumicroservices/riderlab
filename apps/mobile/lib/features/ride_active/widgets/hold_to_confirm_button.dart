import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/l10n_ext.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_snack.dart';

/// Press-and-hold button for destructive ride actions (finish / end session).
///
/// Holding for [holdDuration] fills the button left to right, then fires
/// [onConfirmed] with a heavy haptic. Releasing early rewinds the fill and
/// shows [hint] ("Mantén presionado para terminar"), so a stray tap with a
/// glove never ends a ride.
///
/// Uses raw pointer events (not the gesture arena): a slightly moving glove
/// or a parent scroll view does not cancel the hold.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    super.key,
    required this.onConfirmed,
    required this.label,
    this.icon,
    this.hint,
    this.color = AppTheme.signal,
    this.foregroundColor = Colors.white,
    this.filled = true,
    this.holdDuration = const Duration(milliseconds: 1000),
    this.minHeight = 56,
  });

  /// Null disables the button.
  final VoidCallback? onConfirmed;
  final String label;
  final Widget? icon;

  /// Shown on a short tap. Defaults to the l10n "hold to finish" hint.
  final String? hint;
  final Color color;
  final Color foregroundColor;

  /// Filled (solid [color]) or outlined.
  final bool filled;
  final Duration holdDuration;
  final double minHeight;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: widget.holdDuration,
  )..addStatusListener(_onStatus);

  bool _pressed = false;
  bool _fired = false;

  bool get _enabled => widget.onConfirmed != null;

  @override
  void didUpdateWidget(covariant HoldToConfirmButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.holdDuration != widget.holdDuration) {
      _progress.duration = widget.holdDuration;
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _fired || !_pressed) return;
    _fired = true;
    HapticFeedback.heavyImpact();
    widget.onConfirmed?.call();
  }

  void _down(PointerDownEvent _) {
    if (!_enabled) return;
    _pressed = true;
    _fired = false;
    HapticFeedback.selectionClick();
    _progress.forward(from: 0);
    setState(() {});
  }

  void _up(PointerEvent _) {
    if (!_pressed) return;
    _pressed = false;
    if (!_fired) {
      _progress.animateBack(0, duration: const Duration(milliseconds: 180));
      showAppSnack(
        context,
        widget.hint ?? context.l10n.rideHoldToFinishHint,
        tone: AppToastTone.warning,
      );
    } else {
      _progress.value = 0;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;
    final base = enabled ? widget.color : AppTheme.steel;
    final fg = widget.filled
        ? widget.foregroundColor
        : (enabled ? widget.color : AppTheme.steel);
    final radius = BorderRadius.circular(16);

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      hint: widget.hint ?? context.l10n.rideHoldToFinishHint,
      onLongPress: enabled ? widget.onConfirmed : null,
      excludeSemantics: true,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _down,
        onPointerUp: _up,
        onPointerCancel: _up,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: widget.minHeight),
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, child) {
              return AnimatedScale(
                scale: _pressed ? 0.97 : 1,
                duration: const Duration(milliseconds: 120),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.filled
                        ? base.withValues(alpha: enabled ? 0.55 : 0.25)
                        : Colors.transparent,
                    borderRadius: radius,
                    border: Border.all(color: base, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progress.value,
                            child: ColoredBox(
                              color: widget.filled
                                  ? base
                                  : base.withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                        child!,
                      ],
                    ),
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      IconTheme.merge(
                        data: IconThemeData(color: fg, size: 24),
                        child: widget.icon!,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: fg,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

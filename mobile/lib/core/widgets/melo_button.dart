import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

enum MeloButtonVariant { primary, secondary, text }

/// Melo's standard button.
///
/// - [primary]: filled plum, for the single main action on a screen.
/// - [secondary]: outlined, for alternative actions.
/// - [text]: low-emphasis inline action.
///
/// Passing `onPressed: null` disables the button; [isLoading] shows a spinner
/// and blocks taps while keeping the button's size stable.
class MeloButton extends StatefulWidget {
  const MeloButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MeloButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  const MeloButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  }) : variant = MeloButtonVariant.secondary;

  const MeloButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
  }) : variant = MeloButtonVariant.text,
       isLoading = false;

  final String label;
  final VoidCallback? onPressed;
  final MeloButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  @override
  State<MeloButton> createState() => _MeloButtonState();
}

class _MeloButtonState extends State<MeloButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final (background, foreground, borderSide) = switch (widget.variant) {
      MeloButtonVariant.primary => (
        _enabled || widget.isLoading ? AppColors.plum : AppColors.sandDeep,
        _enabled || widget.isLoading ? AppColors.onPlum : AppColors.inkSubtle,
        BorderSide.none,
      ),
      MeloButtonVariant.secondary => (
        AppColors.surface,
        _enabled ? AppColors.ink : AppColors.inkSubtle,
        const BorderSide(color: AppColors.border),
      ),
      MeloButtonVariant.text => (
        Colors.transparent,
        _enabled ? AppColors.plum : AppColors.inkSubtle,
        BorderSide.none,
      ),
    };

    final isText = widget.variant == MeloButtonVariant.text;
    final labelStyle = Theme.of(context).textTheme.labelLarge!
        .copyWith(color: foreground, fontSize: isText ? 15 : 16);

    final content = widget.isLoading
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: foreground),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: labelStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final shape = StadiumBorder(side: borderSide);

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.isLoading ? '${widget.label}, loading' : null,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: AppMotion.fast,
        curve: AppMotion.curve,
        child: SizedBox(
          width: widget.expand ? double.infinity : null,
          height: isText ? 44 : 56,
          child: Material(
            color: background,
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _enabled ? widget.onPressed : null,
              onHighlightChanged: _enabled ? _setPressed : null,
              highlightColor: widget.variant == MeloButtonVariant.primary
                  ? AppColors.plumPressed.withValues(alpha: 0.4)
                  : AppColors.sand,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isText ? AppSpacing.sm : AppSpacing.lg,
                ),
                child: Center(widthFactor: 1, child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

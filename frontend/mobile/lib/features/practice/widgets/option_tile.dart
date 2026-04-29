import 'package:flutter/material.dart';

enum OptionState { idle, selected, revealedCorrect, revealedWrong, revealedOther }

class OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.label,
    required this.text,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color border;
    Color? fill;
    Color labelBg;
    Color labelFg;
    IconData? trailingIcon;
    Color? iconColor;

    switch (state) {
      case OptionState.idle:
        border = cs.outlineVariant;
        fill = null;
        labelBg = cs.surfaceContainerHighest;
        labelFg = cs.onSurface;
        break;
      case OptionState.selected:
        border = cs.primary;
        fill = cs.primaryContainer.withValues(alpha: 0.25);
        labelBg = cs.primary;
        labelFg = cs.onPrimary;
        break;
      case OptionState.revealedCorrect:
        border = Colors.green;
        fill = Colors.green.withValues(alpha: 0.12);
        labelBg = Colors.green;
        labelFg = Colors.white;
        trailingIcon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case OptionState.revealedWrong:
        border = cs.error;
        fill = cs.errorContainer.withValues(alpha: 0.25);
        labelBg = cs.error;
        labelFg = cs.onError;
        trailingIcon = Icons.cancel;
        iconColor = cs.error;
        break;
      case OptionState.revealedOther:
        border = cs.outlineVariant;
        fill = null;
        labelBg = cs.surfaceContainerHighest;
        labelFg = cs.onSurface;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: fill ?? Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: border, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: labelBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: labelFg,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailingIcon, color: iconColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

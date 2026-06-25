// Design Ref: §5.3, §5.4 — token status badge (4 states).

import 'package:flutter/material.dart';

import '../../core/domain/token_status.dart';
import '../../l10n/app_localizations.dart';

class StatusBadge extends StatelessWidget {
  final TokenStatus status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _style(status);
    final label = _label(AppLocalizations.of(context), status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static (Color, IconData) _style(TokenStatus s) {
    switch (s) {
      case TokenStatus.valid:
        return (Colors.green, Icons.check_circle_outline);
      case TokenStatus.expiringSoon:
        return (Colors.orange, Icons.warning_amber_outlined);
      case TokenStatus.expired:
        return (Colors.red, Icons.error_outline);
      case TokenStatus.noExpiry:
        return (Colors.grey, Icons.shield_outlined);
    }
  }

  static String _label(AppLocalizations l, TokenStatus s) {
    switch (s) {
      case TokenStatus.valid:
        return l.statusValid;
      case TokenStatus.expiringSoon:
        return l.statusSoon;
      case TokenStatus.expired:
        return l.statusExpired;
      case TokenStatus.noExpiry:
        return l.statusNoExpiry;
    }
  }
}

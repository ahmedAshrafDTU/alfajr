import 'package:flutter/material.dart';
import '../../domain/models/user_status.dart';

class UserStatusBadge extends StatelessWidget {
  final UserStatus status;
  final bool showIcon;
  final double fontSize;

  const UserStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              status.icon,
              size: fontSize + 2,
              color: color,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            status.localizedArabic,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

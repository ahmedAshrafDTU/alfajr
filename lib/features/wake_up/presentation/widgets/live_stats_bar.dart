import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../users/domain/models/user_model.dart';
import '../../../users/domain/models/user_status.dart';

class LiveStatsBar extends StatelessWidget {
  final List<UserModel> users;

  const LiveStatsBar({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    final total = users.length;
    final awake = users.where((u) => u.status == UserStatus.awake || u.status == UserStatus.needsFollowUp || u.status == UserStatus.secondFollowUp || u.status == UserStatus.prayed).length;
    final prayed = users.where((u) => u.status == UserStatus.prayed).length;
    final failed = users.where((u) => u.status == UserStatus.failed || u.status == UserStatus.notPrayed).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(context, 'المسجلون', '$total', AppColors.primaryLight, Icons.people_rounded),
          _buildDivider(context),
          _buildItem(context, 'استيقظوا', '$awake', AppColors.amber, Icons.wb_sunny_rounded),
          _buildDivider(context),
          _buildItem(context, 'صلوا الفجر', '$prayed', AppColors.statusPrayed, Icons.check_circle_rounded),
          _buildDivider(context),
          _buildItem(context, 'لم يجيبوا', '$failed', AppColors.statusNoAnswer, Icons.cancel_rounded),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String label, String value, Color color, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textDarkSecondary
                : AppColors.textLightSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBorder
          : AppColors.lightBorder,
    );
  }
}

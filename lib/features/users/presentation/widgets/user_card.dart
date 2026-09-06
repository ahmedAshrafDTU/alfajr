import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/user_model.dart';
import 'user_status_badge.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onQuickCall;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onQuickCall,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar with priority indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: user.status.color.withOpacity(0.2),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0] : '؟',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: user.status.color,
                      ),
                    ),
                  ),
                  if (user.priority == 1)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.textLightPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!user.isOptedIn) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'غير موافق',
                              style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badge & Quick Action
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  UserStatusBadge(status: user.status),
                  if (user.retryCount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'محاولات: ${user.retryCount}',
                      style: const TextStyle(fontSize: 11, color: AppColors.amber),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

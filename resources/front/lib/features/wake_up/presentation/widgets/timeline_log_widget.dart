import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_date_formatter.dart';
import '../../domain/models/session_log_model.dart';

class TimelineLogWidget extends StatelessWidget {
  final List<SessionLogModel> logs;
  final bool isCompact;

  const TimelineLogWidget({
    super.key,
    required this.logs,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 44,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 8),
            Text(
              'لا توجد أحداث مسجلة في جلسة اليوم بعد',
              style: TextStyle(
                color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final displayLogs = isCompact ? logs.take(5).toList() : logs;

    return ListView.separated(
      shrinkWrap: true,
      physics: isCompact ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      itemCount: displayLogs.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 48),
      itemBuilder: (context, index) {
        final log = displayLogs[index];
        final iconData = _getEventIcon(log.eventType);
        final iconColor = _getEventColor(log.eventType);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  size: 18,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.message,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textLightPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ArabicDateFormatter.formatTime(log.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary,
                      ),
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

  IconData _getEventIcon(SessionEventType type) {
    switch (type) {
      case SessionEventType.sessionStarted:
        return Icons.play_arrow_rounded;
      case SessionEventType.callInitiated:
        return Icons.phone_in_talk_rounded;
      case SessionEventType.callAnswered:
        return Icons.phone_callback_rounded;
      case SessionEventType.callNoAnswer:
        return Icons.phone_missed_rounded;
      case SessionEventType.callFailed:
        return Icons.error_outline_rounded;
      case SessionEventType.userAwake:
        return Icons.wb_sunny_rounded;
      case SessionEventType.followUpTriggered:
        return Icons.help_outline_rounded;
      case SessionEventType.prayerConfirmed:
        return Icons.check_circle_rounded;
      case SessionEventType.prayerNotDone:
        return Icons.directions_run_rounded;
      case SessionEventType.snoozed:
        return Icons.snooze_rounded;
      case SessionEventType.optedOut:
        return Icons.person_off_rounded;
      case SessionEventType.emergencyStopped:
        return Icons.stop_circle_rounded;
      case SessionEventType.sessionFinished:
        return Icons.task_alt_rounded;
    }
  }

  Color _getEventColor(SessionEventType type) {
    switch (type) {
      case SessionEventType.prayerConfirmed:
      case SessionEventType.sessionFinished:
        return AppColors.statusPrayed;
      case SessionEventType.callAnswered:
      case SessionEventType.userAwake:
        return AppColors.statusAwake;
      case SessionEventType.callInitiated:
      case SessionEventType.sessionStarted:
        return AppColors.statusCalling;
      case SessionEventType.callNoAnswer:
      case SessionEventType.callFailed:
      case SessionEventType.emergencyStopped:
        return AppColors.statusNoAnswer;
      case SessionEventType.followUpTriggered:
      case SessionEventType.prayerNotDone:
        return AppColors.gold;
      case SessionEventType.snoozed:
        return AppColors.statusSnoozed;
      case SessionEventType.optedOut:
        return AppColors.statusOptedOut;
    }
  }
}

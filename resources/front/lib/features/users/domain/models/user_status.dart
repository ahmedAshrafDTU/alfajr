import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Enum defining all explicit statuses in the Wake-up lifecycle.
enum UserStatus {
  pending,
  calling,
  needsRetry,
  awake,
  needsFollowUp,
  secondFollowUp,
  prayed,
  notPrayed,
  snoozed,
  failed,
  optedOut,
  paused;

  String get localizedArabic {
    switch (this) {
      case UserStatus.pending:
        return AppStrings.statusPending;
      case UserStatus.calling:
        return AppStrings.statusCalling;
      case UserStatus.needsRetry:
        return 'إعادة محاولة';
      case UserStatus.awake:
        return AppStrings.statusAwake;
      case UserStatus.needsFollowUp:
        return AppStrings.statusNeedsFollowUp;
      case UserStatus.secondFollowUp:
        return AppStrings.statusSecondFollowUp;
      case UserStatus.prayed:
        return AppStrings.statusPrayed;
      case UserStatus.notPrayed:
        return AppStrings.statusNotPrayed;
      case UserStatus.snoozed:
        return AppStrings.statusSnoozed;
      case UserStatus.failed:
        return AppStrings.statusFailed;
      case UserStatus.optedOut:
        return AppStrings.statusOptedOut;
      case UserStatus.paused:
        return AppStrings.statusPaused;
    }
  }

  Color get color {
    switch (this) {
      case UserStatus.prayed:
        return AppColors.statusPrayed;
      case UserStatus.awake:
        return AppColors.statusAwake;
      case UserStatus.calling:
        return AppColors.statusCalling;
      case UserStatus.needsRetry:
        return AppColors.amber;
      case UserStatus.needsFollowUp:
      case UserStatus.secondFollowUp:
        return AppColors.gold;
      case UserStatus.notPrayed:
      case UserStatus.failed:
        return AppColors.statusNoAnswer;
      case UserStatus.snoozed:
        return AppColors.statusSnoozed;
      case UserStatus.optedOut:
      case UserStatus.paused:
      case UserStatus.pending:
        return AppColors.statusPending;
    }
  }

  IconData get icon {
    switch (this) {
      case UserStatus.prayed:
        return Icons.check_circle_rounded;
      case UserStatus.awake:
        return Icons.wb_sunny_rounded;
      case UserStatus.calling:
        return Icons.phone_in_talk_rounded;
      case UserStatus.needsRetry:
        return Icons.replay_rounded;
      case UserStatus.needsFollowUp:
      case UserStatus.secondFollowUp:
        return Icons.access_time_rounded;
      case UserStatus.notPrayed:
        return Icons.cancel_rounded;
      case UserStatus.failed:
        return Icons.phone_missed_rounded;
      case UserStatus.snoozed:
        return Icons.snooze_rounded;
      case UserStatus.optedOut:
        return Icons.person_off_rounded;
      case UserStatus.paused:
        return Icons.pause_circle_rounded;
      case UserStatus.pending:
        return Icons.hourglass_top_rounded;
    }
  }

  bool get isTerminal {
    return this == UserStatus.prayed ||
        this == UserStatus.notPrayed ||
        this == UserStatus.failed ||
        this == UserStatus.optedOut;
  }
}

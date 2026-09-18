import '../constants/app_strings.dart';

/// Type of audio prompt to play during calls.
enum AudioPromptType {
  firstWakeUp,
  prayerQuestion,
  notPrayedReply,
  finalFollowUpQuestion,
  prayedConfirmation,
  snoozeConfirmation,
  optOutConfirmation,
}

/// Helper model for voice prompt content and transcript.
class AudioPrompt {
  final AudioPromptType type;
  final String arabicText;
  final Duration estimatedDuration;

  const AudioPrompt({
    required this.type,
    required this.arabicText,
    required this.estimatedDuration,
  });

  String get textArabic => arabicText;

  static AudioPrompt fromType(AudioPromptType type) {
    switch (type) {
      case AudioPromptType.firstWakeUp:
        return const AudioPrompt(
          type: AudioPromptType.firstWakeUp,
          arabicText: AppStrings.voiceFirstWakeUp,
          estimatedDuration: Duration(seconds: 4),
        );
      case AudioPromptType.prayerQuestion:
        return const AudioPrompt(
          type: AudioPromptType.prayerQuestion,
          arabicText: AppStrings.voicePrayerQuestion,
          estimatedDuration: Duration(seconds: 2),
        );
      case AudioPromptType.notPrayedReply:
        return const AudioPrompt(
          type: AudioPromptType.notPrayedReply,
          arabicText: AppStrings.voiceNotPrayedReply,
          estimatedDuration: Duration(seconds: 3),
        );
      case AudioPromptType.finalFollowUpQuestion:
        return const AudioPrompt(
          type: AudioPromptType.finalFollowUpQuestion,
          arabicText: AppStrings.voiceFinalFollowUpQuestion,
          estimatedDuration: Duration(seconds: 2),
        );
      case AudioPromptType.prayedConfirmation:
        return const AudioPrompt(
          type: AudioPromptType.prayedConfirmation,
          arabicText: AppStrings.voicePrayedConfirmation,
          estimatedDuration: Duration(seconds: 3),
        );
      case AudioPromptType.snoozeConfirmation:
        return const AudioPrompt(
          type: AudioPromptType.snoozeConfirmation,
          arabicText: AppStrings.voiceSnoozeConfirmation,
          estimatedDuration: Duration(seconds: 4),
        );
      case AudioPromptType.optOutConfirmation:
        return const AudioPrompt(
          type: AudioPromptType.optOutConfirmation,
          arabicText: AppStrings.voiceOptOutConfirmation,
          estimatedDuration: Duration(seconds: 4),
        );
    }
  }
}

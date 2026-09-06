import 'package:flutter/material.dart';
import '../../../../core/audio/audio_prompts.dart';
import '../../../../core/speech/arabic_intent_classifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../users/domain/models/user_model.dart';

class LiveCallModal extends StatefulWidget {
  final UserModel user;
  final AudioPrompt prompt;
  final Function(String spokenResponse, ArabicVoiceIntent intent) onCompleted;

  const LiveCallModal({
    super.key,
    required this.user,
    required this.prompt,
    required this.onCompleted,
  });

  @override
  State<LiveCallModal> createState() => _LiveCallModalState();
}

class _LiveCallModalState extends State<LiveCallModal> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final TextEditingController _customSpeechController = TextEditingController();
  bool _isSpeakingPrompt = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulate prompt audio playing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSpeakingPrompt = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _customSpeechController.dispose();
    super.dispose();
  }

  void _sendResponse(String text) {
    final intent = ArabicIntentClassifier.classify(text);
    Navigator.of(context).pop();
    widget.onCompleted(text, intent);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Calling Animation / Avatar
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.all(12 + (_pulseController.value * 8)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.2 + (_pulseController.value * 0.2)),
                  ),
                  child: const CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.phone_in_talk_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              widget.user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.user.phone,
              style: const TextStyle(
                color: AppColors.textDarkSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),

            // Voice Prompt Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSpeakingPrompt ? Icons.volume_up_rounded : Icons.record_voice_over_rounded,
                        color: AppColors.gold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isSpeakingPrompt ? 'الرسالة الصوتية المشغلة الآن:' : 'الرسالة الصوتية:',
                        style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.prompt.arabicText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Interactive Voice Responses
            const Text(
              'اختر رد المستخدم أو اكتب استجابة مخصصة:',
              style: TextStyle(color: AppColors.textDarkSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.check_circle, color: AppColors.statusPrayed, size: 18),
                  label: const Text('نعم، الحمد لله صليت'),
                  onPressed: () => _sendResponse('نعم الحمد لله صليت'),
                  backgroundColor: AppColors.darkSurface,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                ActionChip(
                  avatar: const Icon(Icons.wb_sunny, color: AppColors.amber, size: 18),
                  label: const Text('صحيت قايم اتوضا'),
                  onPressed: () => _sendResponse('صحيت قايم اتوضا'),
                  backgroundColor: AppColors.darkSurface,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                ActionChip(
                  avatar: const Icon(Icons.access_time, color: AppColors.gold, size: 18),
                  label: const Text('لسه ما صليتش'),
                  onPressed: () => _sendResponse('لسه ما صليتش'),
                  backgroundColor: AppColors.darkSurface,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                ActionChip(
                  avatar: const Icon(Icons.snooze, color: AppColors.statusSnoozed, size: 18),
                  label: const Text('خمس دقائق غفوة'),
                  onPressed: () => _sendResponse('خمس دقائق'),
                  backgroundColor: AppColors.darkSurface,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                ActionChip(
                  avatar: const Icon(Icons.person_off, color: AppColors.statusNoAnswer, size: 18),
                  label: const Text('إلغاء اشتراكي'),
                  onPressed: () => _sendResponse('الغاء الاشتراك احذفني'),
                  backgroundColor: AppColors.darkSurface,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Custom Spoken Text Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customSpeechController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'أو اكتب رد صوتي مخصص...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: AppColors.darkSurface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (_customSpeechController.text.trim().isNotEmpty) {
                      _sendResponse(_customSpeechController.text.trim());
                    }
                  },
                  icon: const Icon(Icons.send_rounded, color: AppColors.primaryAccent),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reject / End Call Button
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCompleted('', ArabicVoiceIntent.unrecognized);
              },
              icon: const Icon(Icons.call_end_rounded, color: Colors.redAccent),
              label: const Text(
                'عدم الرد / إنهاء المكالمة',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

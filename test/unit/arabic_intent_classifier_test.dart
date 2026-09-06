import 'package:flutter_test/flutter_test.dart';
import 'package:alfager/core/speech/arabic_intent_classifier.dart';

void main() {
  group('ArabicIntentClassifier Tests', () {
    test('Positive prayer responses are recognized correctly across dialects', () {
      expect(ArabicIntentClassifier.classify('نعم'), equals(ArabicVoiceIntent.positivePrayer));
      expect(ArabicIntentClassifier.classify('ايوه صليت'), equals(ArabicVoiceIntent.positivePrayer));
      expect(ArabicIntentClassifier.classify('أيوه'), equals(ArabicVoiceIntent.positivePrayer));
      expect(ArabicIntentClassifier.classify('اه'), equals(ArabicVoiceIntent.positivePrayer));
      expect(ArabicIntentClassifier.classify('حاضر'), equals(ArabicVoiceIntent.positivePrayer));
      expect(ArabicIntentClassifier.classify('الحمد لله صليت الفجر'), equals(ArabicVoiceIntent.positivePrayer));
      expect(ArabicIntentClassifier.classify('أديت الصلاة'), equals(ArabicVoiceIntent.positivePrayer));
      expect(ArabicIntentClassifier.classify('أديت صلاتي'), equals(ArabicVoiceIntent.positivePrayer));
      expect(ArabicIntentClassifier.classify('تمام'), equals(ArabicVoiceIntent.positivePrayer));
    });

    test('Negative prayer responses are recognized correctly across dialects', () {
      expect(ArabicIntentClassifier.classify('لا'), equals(ArabicVoiceIntent.negativePrayer));
      expect(ArabicIntentClassifier.classify('لسه'), equals(ArabicVoiceIntent.negativePrayer));
      expect(ArabicIntentClassifier.classify('لسه نايم'), equals(ArabicVoiceIntent.negativePrayer));
      expect(ArabicIntentClassifier.classify('مش هقوم'), equals(ArabicVoiceIntent.negativePrayer));
      expect(ArabicIntentClassifier.classify('مش قادر'), equals(ArabicVoiceIntent.negativePrayer));
      expect(ArabicIntentClassifier.classify('لم أصلِّ'), equals(ArabicVoiceIntent.negativePrayer));
      expect(ArabicIntentClassifier.classify('ما صليتش بعدني'), equals(ArabicVoiceIntent.negativePrayer));
      expect(ArabicIntentClassifier.classify('مش لسه'), equals(ArabicVoiceIntent.negativePrayer));
      expect(ArabicIntentClassifier.classify('كلا'), equals(ArabicVoiceIntent.negativePrayer));
    });

    test('Snooze responses are recognized correctly', () {
      expect(ArabicIntentClassifier.classify('خمس دقائق'), equals(ArabicVoiceIntent.snoozeRequest));
      expect(ArabicIntentClassifier.classify('٥ دقائق لو سمحت'), equals(ArabicVoiceIntent.snoozeRequest));
      expect(ArabicIntentClassifier.classify('شوية بعدين'), equals(ArabicVoiceIntent.snoozeRequest));
      expect(ArabicIntentClassifier.classify('بعد شوية'), equals(ArabicVoiceIntent.snoozeRequest));
      expect(ArabicIntentClassifier.classify('كمان شوي'), equals(ArabicVoiceIntent.snoozeRequest));
      expect(ArabicIntentClassifier.classify('اعطيني وقت'), equals(ArabicVoiceIntent.snoozeRequest));
    });

    test('Opt-out responses are recognized with high priority', () {
      expect(ArabicIntentClassifier.classify('إلغاء الاشتراك'), equals(ArabicVoiceIntent.optOutRequest));
      expect(ArabicIntentClassifier.classify('احذفني من الخدمة'), equals(ArabicVoiceIntent.optOutRequest));
      expect(ArabicIntentClassifier.classify('لا تتصل بي أبداً'), equals(ArabicVoiceIntent.optOutRequest));
      expect(ArabicIntentClassifier.classify('اسكت'), equals(ArabicVoiceIntent.optOutRequest));
      expect(ArabicIntentClassifier.classify('الغاء'), equals(ArabicVoiceIntent.optOutRequest));
      expect(ArabicIntentClassifier.classify('وقف الاتصال'), equals(ArabicVoiceIntent.optOutRequest));
    });

    test('Wake confirmation responses are recognized correctly', () {
      expect(ArabicIntentClassifier.classify('صحيت'), equals(ArabicVoiceIntent.wakeConfirmation));
      expect(ArabicIntentClassifier.classify('أنا صاحي'), equals(ArabicVoiceIntent.wakeConfirmation));
      expect(ArabicIntentClassifier.classify('قمت'), equals(ArabicVoiceIntent.wakeConfirmation));
      expect(ArabicIntentClassifier.classify('استيقظت الحمد لله'), equals(ArabicVoiceIntent.wakeConfirmation));
      expect(ArabicIntentClassifier.classify('صباح الخير'), equals(ArabicVoiceIntent.wakeConfirmation));
    });

    test('Normalization removes tashkeel and standardizes Arabic letters', () {
      final normalized = ArabicIntentClassifier.normalizeArabic('الْحَمْدُ لِلَّهِ، أَنَا صَلَّيْتُ!');
      expect(normalized.contains('الحمد لله'), isTrue);
      expect(normalized.contains('صليت'), isTrue);
    });
  });
}

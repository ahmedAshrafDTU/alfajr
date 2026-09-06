/// Detected intent classification from user's voice input or text.
enum ArabicVoiceIntent {
  positivePrayer, // "نعم", "ايوه", "أيوه", "اه", "حاضر", "صليت", "الحمد لله"
  negativePrayer, // "لا", "لسه", "لسه نايم", "مش هقوم", "مش قادر", "ما صليت", "بعدني"
  snoozeRequest, // "خمس دقائق", "شوية", "بعد شوية", "غفوة", "تأجيل"
  optOutRequest, // "الغاء", "إلغاء الاشتراك", "احذفني", "لا تتصل بي", "اسكت"
  wakeConfirmation, // "أنا صاحي", "استيقظت", "صحيت", "قمت", "صباح الخير"
  unrecognized,
}

/// Normalizer and intent classifier for spoken/written Arabic user responses.
class ArabicIntentClassifier {
  /// Normalizes Arabic text (removes tashkeel, standardizes alef, taa marbuta, etc.).
  static String normalizeArabic(String input) {
    String text = input.trim().toLowerCase();

    // Remove tashkeel (diacritics)
    final tashkeelRegex = RegExp(r'[\u064B-\u065F\u0670]');
    text = text.replaceAll(tashkeelRegex, '');

    // Normalize Alefs: أ, إ, آ -> ا
    text = text.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // Normalize Taa Marbuta & Haa: ة -> ه
    text = text.replaceAll('ة', 'ه');

    // Normalize Yaa: ى -> ي
    text = text.replaceAll('ى', 'ي');

    // Remove punctuation & extra spaces
    text = text.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  /// Classifies normalized input into an ArabicVoiceIntent.
  static ArabicVoiceIntent classify(String rawText) {
    if (rawText.trim().isEmpty) return ArabicVoiceIntent.unrecognized;

    final text = normalizeArabic(rawText);
    final words = text.split(' ');

    // 1. Opt-out Intent check (highest priority for user privacy & anti-spam)
    final optOutPhrases = [
      'الغاء الاشتراك',
      'الغاء اشتراكي',
      'ايقاف الخدمه',
      'لا تتصل بي',
      'لا تتصل',
      'لا ترن',
      'وقف الاتصال',
      'ايقاف نهائي',
      'احذفني',
      'امسحني',
    ];
    for (final kw in optOutPhrases) {
      if (text.contains(kw)) {
        return ArabicVoiceIntent.optOutRequest;
      }
    }
    final optOutWords = ['الغاء', 'اسكت', 'خروج', 'وقف'];
    for (final word in optOutWords) {
      if (text == word || words.contains(word)) {
        return ArabicVoiceIntent.optOutRequest;
      }
    }

    // 2. Snooze Intent check ("خمس دقائق", "غفوة", "بعد شوية", etc.)
    final snoozePhrases = [
      'خمس دقائق',
      '٥ دقائق',
      'خمس دقايق',
      'بعد شوية',
      'بعد شوي',
      'كمان شوي',
      'اعطيني وقت',
    ];
    for (final kw in snoozePhrases) {
      if (text.contains(kw)) {
        return ArabicVoiceIntent.snoozeRequest;
      }
    }
    final snoozeWords = ['غفوه', 'تاجيل', 'شوي', 'شوية', 'بعدين', 'دقايق'];
    for (final word in snoozeWords) {
      if (text == word || words.contains(word)) {
        return ArabicVoiceIntent.snoozeRequest;
      }
    }

    // 3. Negative Prayer Intent ("لا", "لسه", "لسه نايم", "مش هقوم", "مش قادر", "ما صليت", etc.)
    final negativePhrases = [
      'ما صليتش',
      'ما صليت',
      'لم اصل',
      'لم اؤد',
      'مش لسه',
      'لسه ما صليت',
      'لسه نايم',
      'مش هقوم',
      'مش قادر',
      'قايم اتوضا',
      'بتوضا',
      'الان قايم',
    ];
    for (final phrase in negativePhrases) {
      if (text.contains(phrase)) {
        return ArabicVoiceIntent.negativePrayer;
      }
    }
    final negativeWords = ['لا', 'لسه', 'لسة', 'بعدني', 'كلا'];
    for (final word in negativeWords) {
      if (text == word || words.contains(word)) {
        return ArabicVoiceIntent.negativePrayer;
      }
    }

    // 4. Explicit Prayer Confirmation Phrases & Words
    final explicitPrayerPhrases = [
      'اديت الصلاه',
      'صليت الفجر',
      'خلصت صلاه',
      'اديت صلاتي',
    ];
    for (final phrase in explicitPrayerPhrases) {
      if (text.contains(phrase)) {
        return ArabicVoiceIntent.positivePrayer;
      }
    }
    if (words.contains('صليت') || text == 'صليت') {
      return ArabicVoiceIntent.positivePrayer;
    }

    // 5. Explicit Wake Confirmation Phrases & Words ("صحيت", "استيقظت", "صاحي", "قمت")
    final wakeKeywords = [
      'صحيت',
      'صاحي',
      'استيقظت',
      'قمت',
      'قايم',
      'صباح الخير',
      'السلام عليكم',
      'وعليكم السلام',
    ];
    for (final kw in wakeKeywords) {
      if (text.contains(kw) || words.contains(kw)) {
        return ArabicVoiceIntent.wakeConfirmation;
      }
    }

    // 6. General Affirmative / Positive Responses ("نعم", "ايوه", "أيوه", "اه", "حاضر", "الحمد لله", etc.)
    final generalAffirmativePhrases = [
      'الحمد لله',
      'الحمدلله',
    ];
    for (final phrase in generalAffirmativePhrases) {
      if (text.contains(phrase)) {
        return ArabicVoiceIntent.positivePrayer;
      }
    }
    final generalAffirmativeWords = [
      'نعم',
      'ايوه',
      'ايوا',
      'اي',
      'اه',
      'حاضر',
      'اجل',
      'جاهز',
      'تمام',
    ];
    for (final word in generalAffirmativeWords) {
      if (text == word || words.contains(word)) {
        return ArabicVoiceIntent.positivePrayer;
      }
    }

    return ArabicVoiceIntent.unrecognized;
  }
}

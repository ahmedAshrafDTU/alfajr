/// Arabic strings and localization constants for the Al-Fajr application.
class AppStrings {
  static const String appName = 'نظام الفجر للإيقاظ';
  static const String appTagline = 'إيقاظ المسلمين لصلاة الفجر ومتابعتهم حتى الصلاة';

  // Navigation
  static const String navDashboard = 'الرئيسية';
  static const String navLiveMonitoring = 'المتابعة الحية';
  static const String navUsers = 'المشتركون';
  static const String navGroups = 'المجموعات';
  static const String navHistory = 'السجل والإحصائيات';
  static const String navSettings = 'الإعدادات';

  // Wake-up Session
  static const String startWakeUpSession = 'بدء جلسة الإيقاظ';
  static const String stopWakeUpSession = 'إيقاف الجلسة';
  static const String emergencyStop = 'إيقاف طارئ لجميع المكالمات';
  static const String sessionInProgress = 'جلسة الإيقاظ جارية الآن';
  static const String sessionIdle = 'لا توجد جلسة جارية حالياً';
  static const String sessionCompleted = 'اكتملت جلسة اليوم بنجاح';

  // Phases
  static const String phase1Title = 'المرحلة الأولى: الاتصال الأولي';
  static const String phase2Title = 'المرحلة الثانية: إعادة المحاولة';
  static const String phase3Title = 'المرحلة الثالثة: متابعة الصلاة (Follow-up)';
  static const String phase4Title = 'المرحلة الرابعة: التأكيد النهائي';

  // Voice Prompts
  static const String voiceFirstWakeUp =
      'السلام عليكم، استيقظ لصلاة الفجر، فالصلاة خير من النوم.';
  static const String voicePrayerQuestion = 'هل صليت الفجر؟';
  static const String voiceNotPrayedReply = 'إذن قم فصلِّ، هيا هيا.';
  static const String voiceFinalFollowUpQuestion = 'هل صليت الفجر الآن؟';
  static const String voicePrayedConfirmation =
      'تقبل الله منا ومنكم صالح الأعمال.';
  static const String voiceSnoozeConfirmation =
      'تم تأجيل التنبيه لمدة 5 دقائق. لا تنم وتفوتك الصلاة.';
  static const String voiceOptOutConfirmation =
      'تم إلغاء اشتراكك في خدمة الإيقاظ. لن يتم الاتصال بك مجدداً.';

  // Statuses in Arabic
  static const String statusPending = 'قيد الانتظار';
  static const String statusCalling = 'جارٍ الاتصال...';
  static const String statusAnswered = 'تم الرد';
  static const String statusAwake = 'مستيقظ';
  static const String statusNeedsFollowUp = 'بانتظار الصلاة';
  static const String statusSecondFollowUp = 'متابعة أخيرة';
  static const String statusPrayed = 'أدى الصلاة';
  static const String statusNotPrayed = 'لم يصلِّ بعد';
  static const String statusSnoozed = 'غفوة مؤقتة';
  static const String statusFailed = 'تعذر الوصول';
  static const String statusOptedOut = 'ألغى الاشتراك';
  static const String statusPaused = 'متوقف مؤقتاً';

  // Metric Labels
  static const String totalUsers = 'إجمالي المسجلين';
  static const String pendingUsers = 'قيد الانتظار';
  static const String awakeUsers = 'استيقظوا';
  static const String prayedUsers = 'صلوا الفجر';
  static const String notPrayedUsers = 'لم يصلوا';
  static const String failedUsers = 'لم يجيبوا';
  static const String successRate = 'نسبة الاستيقاظ';
  static const String prayerRate = 'نسبة إتمام الصلاة';

  // Prayer Info
  static const String nextFajr = 'موعد الفجر القادم';
  static const String timeRemaining = 'الوقت المتبقي';
  static const String calculationAuto = 'تلقائي (حسب الموقع)';
  static const String calculationManual = 'يدوي (محدد مسبقاً)';

  // Privacy & Consent
  static const String consentTitle = 'الموافقة والخصوصية';
  static const String consentDescription =
      'لا يتم الاتصال بأي شخص إلا بعد موافقته الصريحة المسبقة (Opt-in). يمكنك إلغاء الاشتراك في أي وقت.';
  static const String optInConfirmed = 'تم الحصول على الموافقة';
  static const String optOutButton = 'إلغاء الاشتراك نهائياً';
  static const String pauseToday = 'إيقاف اليوم فقط';
  static const String vacationMode = 'وضع الإجازة';

  // Anti-Spam
  static const String antiSpamTitle = 'حماية ضد الإزعاج';
  static const String maxRetriesReached = 'تم الوصول للحد الأقصى للمحاولات';
  static const String cooldownActive = 'فترة الانتظار بين الاتصالات نشطة';
}

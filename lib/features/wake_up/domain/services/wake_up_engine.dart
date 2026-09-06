import 'dart:async';
import '../../../../core/audio/audio_prompts.dart';
import '../../../../core/speech/arabic_intent_classifier.dart';
import '../../../../core/state/state_machine.dart';
import '../../../../core/utils/anti_spam_validator.dart';
import '../../../groups/domain/models/wake_up_config.dart';
import '../../../users/domain/models/user_model.dart';
import '../../../users/domain/models/user_status.dart';
import '../models/session_log_model.dart';
import 'call_service.dart';

/// Engine session state.
enum EngineSessionStatus {
  idle,
  phase1InitialWakeUp,
  phase2Retrying,
  phase3PrayerFollowUp,
  phase4FinalConfirmation,
  completed,
  emergencyStopped,
}

/// The Central Orchestrator managing multi-phase wake-up execution and live timeline.
class WakeUpEngine {
  CallService callService;
  WakeUpConfig config;
  DateTime fajrTime;

  EngineSessionStatus sessionStatus = EngineSessionStatus.idle;
  bool isRunning = false;

  final List<UserModel> _users = [];
  final List<SessionLogModel> _logs = [];

  // Stream controllers for live updates to UI
  final _usersStreamController = StreamController<List<UserModel>>.broadcast();
  final _logsStreamController = StreamController<List<SessionLogModel>>.broadcast();
  final _sessionStatusController = StreamController<EngineSessionStatus>.broadcast();

  Stream<List<UserModel>> get usersStream => _usersStreamController.stream;
  Stream<List<SessionLogModel>> get logsStream => _logsStreamController.stream;
  Stream<EngineSessionStatus> get sessionStatusStream => _sessionStatusController.stream;

  List<UserModel> get users => List.unmodifiable(_users);
  List<SessionLogModel> get logs => List.unmodifiable(_logs);

  WakeUpEngine({
    required this.callService,
    this.config = const WakeUpConfig(),
    DateTime? fajrTime,
  }) : fajrTime = fajrTime ?? DateTime.now();

  /// Initializes the engine with participants.
  void setUsers(List<UserModel> usersList) {
    _users.clear();
    _users.addAll(usersList);
    _usersStreamController.add(_users);
  }

  /// Adds a single log entry and notifies listeners.
  void addLog({
    String? userId,
    String? userName,
    required SessionEventType eventType,
    required String message,
    UserStatus? oldStatus,
    UserStatus? newStatus,
  }) {
    final log = SessionLogModel(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}_${_logs.length}',
      timestamp: DateTime.now(),
      userId: userId,
      userName: userName,
      eventType: eventType,
      message: message,
      oldStatus: oldStatus,
      newStatus: newStatus,
    );
    _logs.insert(0, log);
    _logsStreamController.add(_logs);
  }

  /// Emergency Stop: Halts all ongoing calls and engine execution immediately.
  void emergencyStop() {
    isRunning = false;
    sessionStatus = EngineSessionStatus.emergencyStopped;
    _sessionStatusController.add(sessionStatus);

    for (int i = 0; i < _users.length; i++) {
      if (_users[i].status == UserStatus.calling) {
        final res = WakeUpStateMachine.transition(
          currentStatus: _users[i].status,
          event: WakeUpEvent.triggerEmergencyStop,
          currentRetries: _users[i].retryCount,
          maxRetries: config.maxRetries,
          currentSnoozes: _users[i].snoozeCount,
          maxSnoozes: config.maxSnoozeCount,
          isOptedIn: _users[i].isOptedIn,
        );
        _users[i] = _users[i].copyWith(status: res.newStatus);
      }
    }

    addLog(
      eventType: SessionEventType.emergencyStopped,
      message: 'تم تفعيل الإيقاف الطارئ لجميع المكالمات والعمليات.',
    );
    _usersStreamController.add(_users);
  }

  /// Starts the complete 4-stage wake-up session.
  Future<void> runFullSession({bool simulationSpeed = false}) async {
    if (isRunning) return;
    isRunning = true;
    _logs.clear();

    addLog(
      eventType: SessionEventType.sessionStarted,
      message: 'بدأت جلسة إيقاظ الفجر ومتابعة الصلاة.',
    );

    // Sort users if smart ordering is enabled (Priority 1 first)
    if (config.enableSmartOrdering) {
      _users.sort((a, b) => a.priority.compareTo(b.priority));
    }

    // ==========================================
    // PHASE 1: Initial Wake-up Call
    // ==========================================
    sessionStatus = EngineSessionStatus.phase1InitialWakeUp;
    _sessionStatusController.add(sessionStatus);
    addLog(
      eventType: SessionEventType.sessionStarted,
      message: 'بدء المرحلة الأولى: الاتصال الأولي بالمستخدمين المسجلين.',
    );

    for (int i = 0; i < _users.length; i++) {
      if (!isRunning) break;
      final user = _users[i];

      // Anti-spam & Opt-in validation
      final spamCheck = AntiSpamValidator.canMakeCall(
        user: user,
        now: DateTime.now(),
        fajrTime: fajrTime,
      );

      if (!spamCheck.isAllowed) {
        addLog(
          userId: user.id,
          userName: user.name,
          eventType: SessionEventType.callFailed,
          message: 'تخطي المستخدم: ${spamCheck.rejectionReason}',
        );
        continue;
      }

      await _executeCallForUser(
        userIndex: i,
        prompt: AudioPrompt.fromType(AudioPromptType.firstWakeUp),
        isFollowUp: false,
      );

      if (!simulationSpeed) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    // ==========================================
    // PHASE 2: Retry Wake-up (Only for unanswering users)
    // ==========================================
    if (isRunning) {
      sessionStatus = EngineSessionStatus.phase2Retrying;
      _sessionStatusController.add(sessionStatus);

      bool hasPendingRetries = true;
      int retryPass = 0;

      while (hasPendingRetries && isRunning && retryPass < config.maxRetries) {
        retryPass++;
        final retryCandidates = <int>[];

        for (int i = 0; i < _users.length; i++) {
          if (_users[i].status == UserStatus.needsRetry &&
              _users[i].retryCount < config.maxRetries) {
            retryCandidates.add(i);
          }
        }

        if (retryCandidates.isEmpty) {
          hasPendingRetries = false;
          break;
        }

        addLog(
          eventType: SessionEventType.callInitiated,
          message:
              'بدء دورة إعادة المحاولة رقم ($retryPass) لعدد ${retryCandidates.length} مستخدمين.',
        );

        for (final index in retryCandidates) {
          if (!isRunning) break;
          await _executeCallForUser(
            userIndex: index,
            prompt: AudioPrompt.fromType(AudioPromptType.firstWakeUp),
            isFollowUp: false,
          );
        }
      }
    }

    // ==========================================
    // PHASE 3: Follow-up After Waking ("هل صليت الفجر؟")
    // ==========================================
    if (isRunning) {
      sessionStatus = EngineSessionStatus.phase3PrayerFollowUp;
      _sessionStatusController.add(sessionStatus);
      addLog(
        eventType: SessionEventType.followUpTriggered,
        message: 'بدء المرحلة الثالثة: متابعة أداء صلاة الفجر (Follow-up).',
      );

      for (int i = 0; i < _users.length; i++) {
        if (!isRunning) break;
        if (_users[i].status == UserStatus.awake ||
            _users[i].status == UserStatus.snoozed) {
          // Transition to needsFollowUp
          final trans = WakeUpStateMachine.transition(
            currentStatus: _users[i].status,
            event: WakeUpEvent.triggerFollowUp,
            currentRetries: _users[i].retryCount,
            maxRetries: config.maxRetries,
            currentSnoozes: _users[i].snoozeCount,
            maxSnoozes: config.maxSnoozeCount,
            isOptedIn: _users[i].isOptedIn,
          );

          if (trans.isSuccess) {
            _users[i] = _users[i].copyWith(status: trans.newStatus);
            _usersStreamController.add(_users);

            await _executeCallForUser(
              userIndex: i,
              prompt: AudioPrompt.fromType(AudioPromptType.prayerQuestion),
              isFollowUp: true,
            );
          }
        }
      }
    }

    // ==========================================
    // PHASE 4: Final Prayer Confirmation
    // ==========================================
    if (isRunning) {
      sessionStatus = EngineSessionStatus.phase4FinalConfirmation;
      _sessionStatusController.add(sessionStatus);
      addLog(
        eventType: SessionEventType.followUpTriggered,
        message: 'بدء المرحلة الرابعة: التأكيد النهائي لمن لم يصلِّ.',
      );

      for (int i = 0; i < _users.length; i++) {
        if (!isRunning) break;
        if (_users[i].status == UserStatus.secondFollowUp ||
            _users[i].status == UserStatus.needsFollowUp) {
          await _executeCallForUser(
            userIndex: i,
            prompt:
                AudioPrompt.fromType(AudioPromptType.finalFollowUpQuestion),
            isFollowUp: true,
          );
        }
      }
    }

    if (isRunning) {
      sessionStatus = EngineSessionStatus.completed;
      isRunning = false;
      _sessionStatusController.add(sessionStatus);
      addLog(
        eventType: SessionEventType.sessionFinished,
        message: 'اكتملت جميع مراحل جلسة الفجر بنجاح.',
      );
    }
  }

  /// Executes an individual call cycle with state transitions and Arabic voice intent parsing.
  Future<void> _executeCallForUser({
    required int userIndex,
    required AudioPrompt prompt,
    required bool isFollowUp,
  }) async {
    final user = _users[userIndex];
    final oldStatus = user.status;

    // Transition to Calling
    final startRes = WakeUpStateMachine.transition(
      currentStatus: user.status,
      event: WakeUpEvent.startCall,
      currentRetries: user.retryCount,
      maxRetries: config.maxRetries,
      currentSnoozes: user.snoozeCount,
      maxSnoozes: config.maxSnoozeCount,
      isOptedIn: user.isOptedIn,
    );

    if (!startRes.isSuccess) return;

    _users[userIndex] = user.copyWith(
      status: startRes.newStatus,
      lastCalledAt: DateTime.now(),
      totalCallsMadeToday: user.totalCallsMadeToday + 1,
    );
    _usersStreamController.add(_users);

    addLog(
      userId: user.id,
      userName: user.name,
      eventType: SessionEventType.callInitiated,
      message: 'جارٍ الاتصال بـ ${user.name} (${user.phone})...',
      oldStatus: oldStatus,
      newStatus: UserStatus.calling,
    );

    // Call Provider Execution
    final callResult = await callService.makeCall(
      callId: 'call_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
      toPhone: user.phone,
      prompt: prompt,
      timeoutSeconds: config.callTimeoutSeconds,
    );

    if (!isRunning) return;

    if (callResult.isAnswered) {
      final spoken = callResult.spokenResponseText ?? '';
      final intent = ArabicIntentClassifier.classify(spoken);

      _handleAnsweredCall(
        userIndex: userIndex,
        spokenText: spoken,
        intent: intent,
        isFollowUp: isFollowUp,
      );
    } else {
      _handleNoAnswerCall(userIndex: userIndex);
    }
  }

  void _handleAnsweredCall({
    required int userIndex,
    required String spokenText,
    required ArabicVoiceIntent intent,
    required bool isFollowUp,
  }) {
    final user = _users[userIndex];
    final now = DateTime.now();

    // 1. Opt-out Intent
    if (intent == ArabicVoiceIntent.optOutRequest) {
      final trans = WakeUpStateMachine.transition(
        currentStatus: user.status,
        event: WakeUpEvent.requestOptOut,
        currentRetries: user.retryCount,
        maxRetries: config.maxRetries,
        currentSnoozes: user.snoozeCount,
        maxSnoozes: config.maxSnoozeCount,
        isOptedIn: user.isOptedIn,
      );
      _users[userIndex] = user.copyWith(
        status: trans.newStatus,
        isOptedIn: false,
        optedOutAt: now,
      );
      addLog(
        userId: user.id,
        userName: user.name,
        eventType: SessionEventType.optedOut,
        message: '${user.name}: تم إلغاء الاشتراك بناءً على طلب المستخدم.',
        oldStatus: user.status,
        newStatus: UserStatus.optedOut,
      );
      _usersStreamController.add(_users);
      return;
    }

    // 2. Snooze Intent
    if (intent == ArabicVoiceIntent.snoozeRequest) {
      final trans = WakeUpStateMachine.transition(
        currentStatus: user.status,
        event: WakeUpEvent.requestSnooze,
        currentRetries: user.retryCount,
        maxRetries: config.maxRetries,
        currentSnoozes: user.snoozeCount,
        maxSnoozes: config.maxSnoozeCount,
        isOptedIn: user.isOptedIn,
      );

      if (trans.isSuccess) {
        _users[userIndex] = user.copyWith(
          status: trans.newStatus,
          snoozeCount: user.snoozeCount + 1,
        );
        addLog(
          userId: user.id,
          userName: user.name,
          eventType: SessionEventType.snoozed,
          message:
              '${user.name}: طلب غفوة 5 دقائق (غفوة ${user.snoozeCount + 1} من ${config.maxSnoozeCount}).',
          oldStatus: user.status,
          newStatus: trans.newStatus,
        );
      } else {
        // Snooze exhausted
        _users[userIndex] = user.copyWith(status: UserStatus.awake);
        addLog(
          userId: user.id,
          userName: user.name,
          eventType: SessionEventType.userAwake,
          message: '${user.name}: استنفد الغفوات وأصبح في حالة مستيقظ.',
          oldStatus: user.status,
          newStatus: UserStatus.awake,
        );
      }
      _usersStreamController.add(_users);
      return;
    }

    // 3. Follow-up answers
    if (isFollowUp) {
      if (intent == ArabicVoiceIntent.positivePrayer) {
        final trans = WakeUpStateMachine.transition(
          currentStatus: user.status,
          event: WakeUpEvent.prayerAnswerPositive,
          currentRetries: user.retryCount,
          maxRetries: config.maxRetries,
          currentSnoozes: user.snoozeCount,
          maxSnoozes: config.maxSnoozeCount,
          isOptedIn: user.isOptedIn,
        );
        _users[userIndex] = user.copyWith(
          status: trans.newStatus,
          prayedAt: now,
        );
        addLog(
          userId: user.id,
          userName: user.name,
          eventType: SessionEventType.prayerConfirmed,
          message: '${user.name}: أكد أداء صلاة الفجر بنجاح ("$spokenText").',
          oldStatus: user.status,
          newStatus: UserStatus.prayed,
        );
      } else {
        final trans = WakeUpStateMachine.transition(
          currentStatus: user.status,
          event: WakeUpEvent.prayerAnswerNegative,
          currentRetries: user.retryCount,
          maxRetries: config.maxRetries,
          currentSnoozes: user.snoozeCount,
          maxSnoozes: config.maxSnoozeCount,
          isOptedIn: user.isOptedIn,
        );
        _users[userIndex] = user.copyWith(status: trans.newStatus);
        addLog(
          userId: user.id,
          userName: user.name,
          eventType: SessionEventType.prayerNotDone,
          message: '${user.name}: لم يصلِّ بعد ("$spokenText"). تم تشغيل التذكير: إذن قم فصلِّ، هيا هيا.',
          oldStatus: user.status,
          newStatus: trans.newStatus,
        );
      }
    } else {
      // First wake-up answered
      final trans = WakeUpStateMachine.transition(
        currentStatus: user.status,
        event: WakeUpEvent.callAnswered,
        currentRetries: user.retryCount,
        maxRetries: config.maxRetries,
        currentSnoozes: user.snoozeCount,
        maxSnoozes: config.maxSnoozeCount,
        isOptedIn: user.isOptedIn,
      );
      _users[userIndex] = user.copyWith(
        status: trans.newStatus,
        answeredAt: now,
      );
      addLog(
        userId: user.id,
        userName: user.name,
        eventType: SessionEventType.callAnswered,
        message: '${user.name}: رد على مكالمة الإيقاظ واستمع للتنبيه واستيقظ.',
        oldStatus: user.status,
        newStatus: UserStatus.awake,
      );
    }

    _usersStreamController.add(_users);
  }

  void _handleNoAnswerCall({required int userIndex}) {
    final user = _users[userIndex];
    final currentRetries = user.retryCount + 1;

    final trans = WakeUpStateMachine.transition(
      currentStatus: user.status,
      event: WakeUpEvent.callNoAnswer,
      currentRetries: currentRetries,
      maxRetries: config.maxRetries,
      currentSnoozes: user.snoozeCount,
      maxSnoozes: config.maxSnoozeCount,
      isOptedIn: user.isOptedIn,
    );

    _users[userIndex] = user.copyWith(
      status: trans.newStatus,
      retryCount: currentRetries,
    );

    addLog(
      userId: user.id,
      userName: user.name,
      eventType: SessionEventType.callNoAnswer,
      message:
          '${user.name}: لم يتم الرد على المكالمة. المحاولة ($currentRetries من ${config.maxRetries}).',
      oldStatus: user.status,
      newStatus: trans.newStatus,
    );

    _usersStreamController.add(_users);
  }

  void dispose() {
    isRunning = false;
    _usersStreamController.close();
    _logsStreamController.close();
    _sessionStatusController.close();
  }
}

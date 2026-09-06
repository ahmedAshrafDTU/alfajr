import 'dart:async';
import '../../../../core/audio/audio_prompts.dart';
import 'call_service.dart';

/// Simulated Call mode for testing & demonstration.
enum MockCallBehavior {
  alwaysAnswerAndPrayed,
  alwaysAnswerAndNotPrayed,
  alwaysAnswerAndSnooze,
  alwaysAnswerAndOptOut,
  alwaysNoAnswer,
  interactive, // lets UI decide / user talk
}

/// Robust Mock Call Service with simulation capabilities for development and testing.
class MockCallService implements CallService {
  MockCallBehavior defaultBehavior;
  Duration simulatedRingingDelay;

  MockCallService({
    this.defaultBehavior = MockCallBehavior.alwaysAnswerAndPrayed,
    this.simulatedRingingDelay = const Duration(milliseconds: 300),
  });

  final Map<String, CallStatus> _activeCalls = {};

  @override
  String get providerName => 'Mock Simulator (محاكي المكالمات المحلي)';

  @override
  Future<CallResult> makeCall({
    required String callId,
    required String toPhone,
    required AudioPrompt prompt,
    int timeoutSeconds = 45,
  }) async {
    _activeCalls[callId] = CallStatus.ringing;

    await Future.delayed(simulatedRingingDelay);

    if (_activeCalls[callId] == CallStatus.completed || !_activeCalls.containsKey(callId)) {
      return CallResult(
        callId: callId,
        status: CallStatus.failed,
        duration: Duration.zero,
        errorMessage: 'تم إنهاء المكالمة قبل الرد',
      );
    }

    switch (defaultBehavior) {
      case MockCallBehavior.alwaysAnswerAndPrayed:
        _activeCalls[callId] = CallStatus.completed;
        return CallResult(
          callId: callId,
          status: CallStatus.completed,
          duration: const Duration(seconds: 12),
          spokenResponseText: 'نعم الحمد لله صليت',
        );

      case MockCallBehavior.alwaysAnswerAndNotPrayed:
        _activeCalls[callId] = CallStatus.completed;
        return CallResult(
          callId: callId,
          status: CallStatus.completed,
          duration: const Duration(seconds: 10),
          spokenResponseText: 'لسه ما صليتش قايم اتوضا',
        );

      case MockCallBehavior.alwaysAnswerAndSnooze:
        _activeCalls[callId] = CallStatus.completed;
        return CallResult(
          callId: callId,
          status: CallStatus.completed,
          duration: const Duration(seconds: 8),
          spokenResponseText: 'خمس دقائق لو سمحت',
        );

      case MockCallBehavior.alwaysAnswerAndOptOut:
        _activeCalls[callId] = CallStatus.completed;
        return CallResult(
          callId: callId,
          status: CallStatus.completed,
          duration: const Duration(seconds: 6),
          spokenResponseText: 'الغاء الاشتراك احذفني',
        );

      case MockCallBehavior.alwaysNoAnswer:
        _activeCalls[callId] = CallStatus.noAnswer;
        return CallResult(
          callId: callId,
          status: CallStatus.noAnswer,
          duration: Duration(seconds: timeoutSeconds),
          errorMessage: 'لم يتم الرد على المكالمة',
        );

      case MockCallBehavior.interactive:
        _activeCalls[callId] = CallStatus.completed;
        return CallResult(
          callId: callId,
          status: CallStatus.completed,
          duration: const Duration(seconds: 15),
          spokenResponseText: 'صليت والحمد لله',
        );
    }
  }

  @override
  Future<void> endCall(String callId) async {
    _activeCalls[callId] = CallStatus.completed;
    _activeCalls.remove(callId);
  }

  @override
  Future<CallStatus> getCallStatus(String callId) async {
    return _activeCalls[callId] ?? CallStatus.completed;
  }
}

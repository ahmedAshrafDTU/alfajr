import '../../../../core/audio/audio_prompts.dart';

/// Status of an active or completed voice call.
enum CallStatus {
  initiating,
  ringing,
  answered,
  noAnswer,
  busy,
  failed,
  completed,
}

/// Call outcome result.
class CallResult {
  final String callId;
  final CallStatus status;
  final Duration duration;
  final String? spokenResponseText;
  final String? errorMessage;

  const CallResult({
    required this.callId,
    required this.status,
    required this.duration,
    this.spokenResponseText,
    this.errorMessage,
  });

  bool get isAnswered => status == CallStatus.answered || status == CallStatus.completed;
}

/// Call Provider Abstraction Interface (clean architecture decoupling from Twilio/Vonage).
abstract class CallService {
  /// Initiates an automated voice call to [toPhone] playing [prompt].
  Future<CallResult> makeCall({
    required String callId,
    required String toPhone,
    required AudioPrompt prompt,
    int timeoutSeconds = 45,
  });

  /// Terminates any active call.
  Future<void> endCall(String callId);

  /// Checks the current status of an ongoing call.
  Future<CallStatus> getCallStatus(String callId);

  /// Name of the provider (Twilio / Vonage / Mock).
  String get providerName;
}

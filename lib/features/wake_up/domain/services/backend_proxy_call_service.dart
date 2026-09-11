import 'dart:async';
import '../../../../core/audio/audio_prompts.dart';
import 'call_service.dart';

class BackendProxyCallService implements CallService {
  BackendProxyCallService({
    required String baseUrl,
    required String apiKey,
  });

  @override
  String get providerName => 'Backend Proxy (Stubbed for Web)';

  @override
  Future<CallResult> makeCall({
    required String callId,
    required String toPhone,
    required AudioPrompt prompt,
    int timeoutSeconds = 45,
  }) async {
    return CallResult(callId: callId, status: CallStatus.failed, duration: Duration.zero, errorMessage: 'Stub');
  }

  @override
  Future<void> endCall(String callId) async {}

  @override
  Future<CallStatus> getCallStatus(String callId) async {
    return CallStatus.completed;
  }
}

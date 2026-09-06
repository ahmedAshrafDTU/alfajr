import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../../../core/audio/audio_prompts.dart';
import '../../../../core/config/app_config.dart';
import 'call_service.dart';

/// Secure Backend Proxy Call Service.
/// Dispatches outgoing phone calls through your secure backend API server
/// so that mobile clients never hold third-party provider keys or master secrets.
class BackendProxyCallService implements CallService {
  final String baseUrl;
  final String apiKey;
  final HttpClient _httpClient;

  BackendProxyCallService({
    String? baseUrl,
    String? apiKey,
    HttpClient? httpClient,
  })  : baseUrl = baseUrl ?? AppConfig.backendBaseUrl,
        apiKey = apiKey ?? AppConfig.backendApiKey,
        _httpClient = httpClient ?? HttpClient();

  @override
  String get providerName => 'Al-Fajr Secure Backend Proxy';

  @override
  Future<CallResult> makeCall({
    required String callId,
    required String toPhone,
    required AudioPrompt prompt,
    int timeoutSeconds = 45,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/calls/initiate');
      final request = await _httpClient.postUrl(uri);

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      if (apiKey.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      }

      final payload = {
        'call_id': callId,
        'to_phone': toPhone,
        'prompt_type': prompt.type.name,
        'prompt_text': prompt.arabicText,
        'timeout_seconds': timeoutSeconds,
        'timestamp': DateTime.now().toIso8601String(),
      };

      request.write(jsonEncode(payload));

      final response = await request.close().timeout(
        Duration(seconds: timeoutSeconds + 5),
        onTimeout: () => throw TimeoutException('انتهت مهلة استجابة خادم Al-Fajr Backend'),
      );

      final responseBody = await response.transform(utf8.decoder).join();
      final json = jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final serverCallId = json['call_id'] as String? ?? callId;
        final statusStr = json['status'] as String? ?? 'completed';
        final durationSec = json['duration_seconds'] as int? ?? 15;
        final spokenText = json['spoken_text'] as String?;

        return CallResult(
          callId: serverCallId,
          status: _mapStatus(statusStr),
          duration: Duration(seconds: durationSec),
          spokenResponseText: spokenText,
        );
      } else {
        final errorMsg = json['message'] as String? ?? 'فشل الاتصال من الخادم';
        return CallResult(
          callId: callId,
          status: CallStatus.failed,
          duration: Duration.zero,
          errorMessage: errorMsg,
        );
      }
    } on SocketException catch (_) {
      return CallResult(
        callId: callId,
        status: CallStatus.failed,
        duration: Duration.zero,
        errorMessage: 'تعذر الاتصال بخادم Al-Fajr Backend. تحقق من اتصال الإنترنت.',
      );
    } on TimeoutException {
      return CallResult(
        callId: callId,
        status: CallStatus.noAnswer,
        duration: Duration.zero,
        errorMessage: 'انتهت مهلة رنين المكالمة دون استجابة.',
      );
    } catch (e) {
      return CallResult(
        callId: callId,
        status: CallStatus.failed,
        duration: Duration.zero,
        errorMessage: 'خطأ في استدعاء خادم المكالمات: $e',
      );
    }
  }

  @override
  Future<void> endCall(String callId) async {
    try {
      final uri = Uri.parse('$baseUrl/calls/$callId/terminate');
      final request = await _httpClient.postUrl(uri);
      if (apiKey.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      }
      await request.close();
    } catch (_) {}
  }

  @override
  Future<CallStatus> getCallStatus(String callId) async {
    try {
      final uri = Uri.parse('$baseUrl/calls/$callId/status');
      final request = await _httpClient.getUrl(uri);
      if (apiKey.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      }
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        return _mapStatus(json['status'] as String? ?? 'completed');
      }
    } catch (_) {}
    return CallStatus.completed;
  }

  CallStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'initiating':
      case 'queued':
        return CallStatus.initiating;
      case 'calling':
      case 'ringing':
        return CallStatus.ringing;
      case 'in_progress':
      case 'inprogress':
      case 'answered':
        return CallStatus.answered;
      case 'completed':
        return CallStatus.completed;
      case 'busy':
        return CallStatus.busy;
      case 'no_answer':
      case 'noanswer':
      case 'cancelled':
      case 'canceled':
        return CallStatus.noAnswer;
      default:
        return CallStatus.failed;
    }
  }
}

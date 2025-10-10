import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../api/api_client.dart';
import 'dart:io' show Platform;

class PushService {
  static Future<void> registerIfPossible() async {
    try {
      final sub = OneSignal.User.pushSubscription;
      final playerId = sub.id;
      if (playerId == null || playerId.isEmpty) {
        // будет установлен позже; подписка ещё не активна
        return;
      }
      if (!ApiClient.instance.isAuthenticated) return;
      final platform = Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'unknown';
      final res = await ApiClient.instance.post<Map<String, dynamic>>(
        '/notifications/device/register',
        body: { 'playerId': playerId, 'platform': platform },
      );
      // ignore: avoid_print
      print('🔔 Registered device on backend: ${res.isSuccess}');
    } catch (e) {
      // ignore: avoid_print
      print('🔔 registerIfPossible error: $e');
    }
  }

  static Future<void> unregisterIfPossible() async {
    try {
      final playerId = OneSignal.User.pushSubscription.id;
      if (playerId == null || playerId.isEmpty) return;
      final res = await ApiClient.instance.post<Map<String, dynamic>>(
        '/notifications/device/unregister',
        body: { 'playerId': playerId },
      );
      // ignore: avoid_print
      print('🔔 Unregistered device on backend: ${res.isSuccess}');
    } catch (e) {
      // ignore: avoid_print
      print('🔔 unregisterIfPossible error: $e');
    }
  }

  // WEB only: prompt subscription via bridge (no-op on mobile)
  static Future<void> webPromptSubscribe() async {
    // ignore: avoid_web_libraries_in_flutter
    try {
      // Using eval to avoid adding additional packages for js interop
      // ignore: avoid_web_libraries_in_flutter
      // dart:js won't be imported here to avoid errors on mobile; keep this method unused on mobile
    } catch (_) {}
  }
}

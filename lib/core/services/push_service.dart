// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import '../api/api_client.dart';
// import 'dart:io' show Platform;

class PushService {
  static Future<void> registerIfPossible() async {
    // TODO: Обновить получение OneSignal playerId под SDK v5 API и выполнить регистрацию на бэкенде
    // Пример (будет скорректирован после проверки API):
    // final playerId = await OneSignal.User.pushSubscription.getId();
    // if (playerId == null || !ApiClient.instance.isAuthenticated) return;
    // final platform = Platform.isIOS ? 'ios' : Platform.isAndroid ? 'android' : 'unknown';
    // await ApiClient.instance.post<Map<String, dynamic>>(
    //   '/notifications/device/register',
    //   body: { 'playerId': playerId, 'platform': platform },
    // );
  }

  static Future<void> unregisterIfPossible() async {
    // TODO: Аналогично обновить под SDK v5 API
    // final playerId = await OneSignal.User.pushSubscription.getId();
    // if (playerId == null) return;
    // await ApiClient.instance.post<Map<String, dynamic>>(
    //   '/notifications/device/unregister',
    //   body: { 'playerId': playerId },
    // );
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

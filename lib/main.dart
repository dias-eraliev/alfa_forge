import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'app/app.dart';
import 'core/providers/auth_provider.dart';
import 'core/api/api_client.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void main() async {
  print('🚀🚀🚀 APP MAIN START 🚀🚀🚀');
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем ApiClient для загрузки токенов
  print('🚀 Initializing ApiClient...');
  await ApiClient.instance.initialize();
  print('🚀 ApiClient initialized');

  // Инициализация OneSignal (опционально: установите ONESIGNAL_APP_ID в константе или .env)
  const oneSignalAppId = String.fromEnvironment('ONESIGNAL_APP_ID', defaultValue: '');
  print('🔔 OneSignal init path...');
  if (kIsWeb) {
    try {
      js.context.callMethod('eval', [
        'if (window.OneSignalBridge && window.OneSignalBridge.init) { window.OneSignalBridge.init(); }'
      ]);
      js.context.callMethod('eval', [
        'if (window.OneSignalBridge && window.OneSignalBridge.requestPermission) { window.OneSignalBridge.requestPermission(); }'
      ]);
    } catch (e) {
      print('OneSignal Web init error: $e');
    }
  } else if (oneSignalAppId.isNotEmpty) {
    // Мобильные/iOS/Android через Flutter SDK
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(oneSignalAppId);
    OneSignal.Notifications.requestPermission(true);
  } else {
    print('🔔 OneSignal APP ID not set for mobile. Skipping mobile init.');
  }
  
  print('🚀 Starting app with providers...');
  runApp(
    // Комбинируем Provider и Riverpod
    provider.MultiProvider(
      providers: [
        // AuthProvider для авторизации
        provider.ChangeNotifierProvider(
          create: (_) {
            print('🚀 Creating AuthProvider...');
            return AuthProvider()..initialize();
          },
        ),
      ],
      child: const ProviderScope(
        child: PRIMEApp(),
      ),
    ),
  );
  print('🚀🚀🚀 APP MAIN END 🚀🚀🚀');
}

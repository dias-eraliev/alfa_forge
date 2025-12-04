import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'app/app.dart';
import 'app/router.dart';
import 'core/providers/auth_provider.dart';
import 'core/api/api_client.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/web/onesignal_bridge.dart';
import 'core/services/push_service.dart';

void main() async {
  print('🚀🚀🚀 APP MAIN START 🚀🚀🚀');
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем ApiClient для загрузки токенов
  print('🚀 Initializing ApiClient...');
  await ApiClient.instance.initialize();
  print('🚀 ApiClient initialized');

  // Инициализация OneSignal (опционально: установите ONESIGNAL_APP_ID в константе или .env)
  const oneSignalAppId = String.fromEnvironment('90de8ffd-3f5d-45f5-89c4-ebb8e08c3c48', defaultValue: '');
  print('🔔 OneSignal init path...');
  if (kIsWeb) {
    try {
      OneSignalWebBridge.init();
      OneSignalWebBridge.requestPermission();
    } catch (e) {
      print('OneSignal Web init error: $e');
    }
  } else if (oneSignalAppId.isNotEmpty) {
    // Мобильные/iOS/Android через Flutter SDK
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(oneSignalAppId);
    OneSignal.Notifications.requestPermission(true);
    // Открытие экрана по клику на уведомление
    OneSignal.Notifications.addClickListener((event) {
      try {
        final data = Map<String, dynamic>.from(event.notification.additionalData ?? {});
        final url = event.notification.launchUrl;
        // Примеры data: { type: 'brotherhood_reply', postId: '...' } | { type: 'habit', habitId: '...' } | { type: 'task', taskId: '...' }
        final type = data['type']?.toString();
        switch (type) {
          case 'brotherhood_reply':
          case 'brotherhood_reaction':
            // Открываем экран братства
            router.go('/brotherhood');
            return;
          case 'habit':
            router.go('/habits');
            return;
          case 'task':
            router.go('/tasks');
            return;
        }
              if (url != null && url.toString().startsWith('app://')) {
          final path = url.toString().replaceFirst('app://', '/');
          router.go(path);
        }
      } catch (e) {
        print('🔔 Notification click handler error: $e');
      }
    });
    try {
      // Подпишемся на изменения статуса подписки, чтобы видеть, когда появляется id
      OneSignal.User.pushSubscription.addObserver((state) {
        try {
          final cur = state.current;
          print('🔔 OneSignal subscription changed: optedIn=${cur.optedIn}, id=${cur.id ?? 'null'}');
          if (ApiClient.instance.isAuthenticated && cur.id != null) {
            // как только появляется id, регистрируем устройство на бэкенде
            PushService.registerIfPossible();
          }
        } catch (e) {
          print('🔔 OneSignal observer error: $e');
        }
      });
      final sub = OneSignal.User.pushSubscription;
      print('🔔 OneSignal initial: optedIn=${sub.optedIn}, id=${sub.id ?? 'null'}');
      if (ApiClient.instance.isAuthenticated && sub.id != null) {
        await PushService.registerIfPossible();
      }
    } catch (e) {
      print('🔔 OneSignal debug read error: $e');
    }
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

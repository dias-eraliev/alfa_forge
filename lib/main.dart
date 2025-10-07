import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'app/app.dart';
import 'core/providers/auth_provider.dart';
import 'core/api/api_client.dart';

void main() async {
  print('🚀🚀🚀 APP MAIN START 🚀🚀🚀');
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем ApiClient для загрузки токенов
  print('🚀 Initializing ApiClient...');
  await ApiClient.instance.initialize();
  print('🚀 ApiClient initialized');
  
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

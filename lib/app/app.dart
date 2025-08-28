import 'package:flutter/material.dart';
import 'theme.dart';
import 'router.dart';

class PRIMEApp extends StatelessWidget {
  const PRIMEApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: PRIMETheme.dark(),
      routerConfig: router,
    );
  }
}

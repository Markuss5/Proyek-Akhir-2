import 'package:flutter/material.dart';
import 'package:giliranku/pages/splash/splash_page.dart';
import 'package:giliranku/services/notifikasiService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service for native phone notifications
  await NotifikasiService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2F9E8F),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F9E8F)),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
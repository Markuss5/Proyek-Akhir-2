import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:giliranku/pages/splash/splash_page.dart';
import 'package:giliranku/services/notifikasiService.dart';
=======
import 'package:giliranku/core/theme/theme.dart';
import 'package:giliranku/feature/splash/splashView.dart';
import 'package:giliranku/feature/patient/home/homeView.dart';
import 'package:giliranku/feature/admin/dashboard/adminDashboardView.dart';
import 'package:giliranku/core/services/sessionService.dart';
import 'package:giliranku/core/services/notificationService.dart';
import 'package:giliranku/feature/patient/profil/informasiPoliklinikView.dart';
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
      theme: ThemeData(
        primaryColor: const Color(0xFF2F9E8F),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F9E8F)),
        useMaterial3: true,
      ),
      home: const SplashPage(),
=======
      theme: AppTheme.light,
      home: const InformasiPoliklinikView(),
>>>>>>> Stashed changes
    );
  }
}
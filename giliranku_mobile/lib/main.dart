import 'package:flutter/material.dart';
import 'package:giliranku/feature/splash/splashView.dart';
import 'package:giliranku/feature/patient/home/homeView.dart';
import 'package:giliranku/feature/admin/dashboard/adminDashboardView.dart';
import 'package:giliranku/core/services/sessionService.dart';
import 'package:giliranku/core/services/notificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().initialize();

  final sessionType = await SessionService().getSessionType();
  Widget homeWidget = const SplashView();

  if (sessionType == SessionType.admin) {
    homeWidget = const AdminDashboardView();
  } else if (sessionType == SessionType.patient) {
    final patientData = await SessionService().getPatientMap();
    homeWidget = HomeView(patientData: patientData);
  } else if (sessionType == SessionType.guest) {
    homeWidget = const HomeView();
  }

  runApp(MyApp(home: homeWidget));
}

class MyApp extends StatelessWidget {
  final Widget? home;
  const MyApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2F9E8F),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F9E8F)),
        useMaterial3: true,
      ),
      home: home ?? const SplashView(),
    );
  }
}

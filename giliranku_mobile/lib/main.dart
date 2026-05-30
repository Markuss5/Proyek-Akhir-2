import 'package:flutter/material.dart';
import 'package:giliranku/core/theme/theme.dart';
import 'package:giliranku/feature/splash/splashView.dart';
import 'package:giliranku/feature/patient/home/homeView.dart';
import 'package:giliranku/feature/admin/beranda/adminBerandaView.dart';
import 'package:giliranku/core/services/sessionService.dart';
import 'package:giliranku/core/services/notificationService.dart';
import 'package:giliranku/core/services/fcmService.dart';
import 'package:giliranku/core/repositories/kontrolRutinRepository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:giliranku/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().initialize();
  await FcmService().initialize();

  final sessionType = await SessionService().getSessionType();
  Widget homeWidget = const SplashView();

  if (sessionType == SessionType.admin) {
    homeWidget = const AdminBerandaView();
  } else if (sessionType == SessionType.patient) {
    final patientData = await SessionService().getPatientMap();
    if (patientData != null && patientData['nik'] != null) {
      KontrolRutinRepository().resyncNotifications(patientData['nik']);
    }
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
      theme: AppTheme.light,
      home: home ?? const SplashView(),
    );
  }
}
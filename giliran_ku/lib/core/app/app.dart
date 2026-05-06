import 'package:flutter/material.dart';

import 'package:giliran_ku/core/theme/theme.dart';
import 'package:giliran_ku/feature/kiosk/dashboardView.dart';

class GiliranKuApp extends StatelessWidget {
  const GiliranKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giliran Ku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const DashboardView(),
    );
  }
}
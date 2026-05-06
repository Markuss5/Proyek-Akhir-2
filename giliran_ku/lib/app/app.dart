import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../views/dashboard_view.dart';

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

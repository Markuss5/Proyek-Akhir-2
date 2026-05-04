import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/doctor_selection_screen.dart';
import 'screens/registration_success_screen.dart';
import 'screens/queue_code_input_screen.dart';
import 'screens/queue_verification_success_screen.dart';
import 'screens/pharmacy_queue_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Antrian RSUD Porsea',
      theme: AppTheme.lightTheme(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/doctor_selection':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => DoctorSelectionScreen(
                policlinic: args?['policlinic'] ?? 'Poli Umum',
              ),
            );
          case '/registration_success':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => RegistrationSuccessScreen(
                policlinic: args?['policlinic'] ?? 'RSUD Porsea',
                doctor: args?['doctor'] ?? 'dr. Umum',
              ),
            );
          case '/queue_code_input':
            return MaterialPageRoute(
              builder: (context) => const QueueCodeInputScreen(),
            );
          case '/queue_verification_success':
            final args = settings.arguments as Map<String, dynamic>?;
            final createdAtRaw = args?['createdAt'];
            DateTime? createdAt;
            if (createdAtRaw is String && createdAtRaw.isNotEmpty) {
              createdAt = DateTime.tryParse(createdAtRaw);
            }
            return MaterialPageRoute(
              builder: (context) => QueueVerificationSuccessScreen(
                queueCode: args?['queueCode'] ?? '',
                queueNumber: args?['queueNumber'],
                patientName: args?['patientName'],
                clinicName: args?['clinicName'],
                doctorName: args?['doctorName'],
                scheduleInfo: args?['scheduleInfo'],
                createdAt: createdAt,
              ),
            );
          case '/pharmacy_queue':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => PharmacyQueueScreen(
                patientID: args?['patientID'] ?? '',
                patientName: args?['patientName'] ?? '',
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/service_button_widget.dart';
import '../widgets/footer_widget.dart';
import '../models/service_model.dart';
import 'queue_type_selection_screen.dart';
import 'queue_confirmation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToService(BuildContext context, String serviceId) {
    // Navigate based on service ID
    switch (serviceId) {
      case 'consultation':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QueueTypeSelectionScreen(
              serviceCategory: 'consultation',
            ),
          ),
        );
        break;
      case 'pharmacy':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QueueConfirmationScreen(
              queueNumber: 'F006',
              serviceType: 'umum',
              serviceCategory: 'pharmacy',
            ),
          ),
        );
        break;
      case 'qrcode':
        Navigator.of(context).pushNamed('/queue_code_input');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigasi ke $serviceId'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if device is in portrait or landscape
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Column(
        children: [
          // Header
          const HeaderWidget(),

          // Main content - scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Service buttons grid
                  if (isPortrait)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.0,
                      children: [
                        ServiceButtonWidget(
                          service: Service.consultation(),
                          onPressed: () =>
                              _navigateToService(context, 'consultation'),
                        ),
                        ServiceButtonWidget(
                          service: Service.pharmacy(),
                          onPressed: () =>
                              _navigateToService(context, 'pharmacy'),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ServiceButtonWidget(
                            service: Service.consultation(),
                            onPressed: () => _navigateToService(
                                context, 'consultation'),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ServiceButtonWidget(
                            service: Service.pharmacy(),
                            onPressed: () =>
                                _navigateToService(context, 'pharmacy'),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // QR Code button - Full width
                  SizedBox(
                    width: double.infinity,
                    child: ServiceButtonWidget(
                      isWide: true,
                      service: Service.qrCode(),
                      onPressed: () =>
                          _navigateToService(context, 'qrcode'),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Footer
          const FooterWidget(),
        ],
      ),
    );
  }
}

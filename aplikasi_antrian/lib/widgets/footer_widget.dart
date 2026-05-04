import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.footer,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: Text(
          HospitalInfo.copyright,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: AppFontSizes.footerText,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}

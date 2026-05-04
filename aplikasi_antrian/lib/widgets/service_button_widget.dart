import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../models/service_model.dart';

class ServiceButtonWidget extends StatefulWidget {
  final Service service;
  final VoidCallback onPressed;
  final bool isWide;

  const ServiceButtonWidget({
    super.key,
    required this.service,
    required this.onPressed,
    this.isWide = false,
  });

  @override
  State<ServiceButtonWidget> createState() => _ServiceButtonWidgetState();
}

class _ServiceButtonWidgetState extends State<ServiceButtonWidget> {
  bool _isHovered = false;

  Color _getServiceColor() {
    if (widget.service.id == 'consultation') {
      return AppColors.primary;
    } else if (widget.service.id == 'pharmacy') {
      return AppColors.secondary;
    } else {
      return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color serviceColor = _getServiceColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        onHover: (value) {
          setState(() {
            _isHovered = value;
          });
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(
              color: serviceColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            color: _isHovered
                ? serviceColor.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon in circle
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: serviceColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: serviceColor,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getIconData(),
                          size: 28,
                          color: serviceColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Title
                    Text(
                      widget.service.name,
                      textAlign: TextAlign.center,
                      style: AppTheme.serviceTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Description
                    Text(
                      widget.service.description,
                      textAlign: TextAlign.center,
                      style: AppTheme.serviceDescription.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  IconData _getIconData() {
    switch (widget.service.id) {
      case 'consultation':
        return Icons.local_hospital;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'qrcode':
        return Icons.qr_code_2;
      default:
        return Icons.help;
    }
  }
}

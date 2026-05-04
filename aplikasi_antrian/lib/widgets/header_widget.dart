import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  late DateTime _currentDateTime;

  @override
  void initState() {
    super.initState();
    _currentDateTime = DateTime.now();
    // Update time every second
    _updateTime();
  }

  void _updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentDateTime = DateTime.now();
        });
        _updateTime();
      }
    });
  }

  String _formatDate() {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    final dayName = days[_currentDateTime.weekday - 1];
    final day = _currentDateTime.day.toString().padLeft(2, '0');
    final month = months[_currentDateTime.month - 1];
    final year = _currentDateTime.year;
    
    return '$dayName, $day $month $year';
  }

  String _formatTime() {
    final hour = _currentDateTime.hour.toString().padLeft(2, '0');
    final minute = _currentDateTime.minute.toString().padLeft(2, '0');
    final second = _currentDateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row with Logo and Texts
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Kabupaten Toba - Left Side
                Image.asset(
                  'Logo Kab.Toba.png',
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                
                // Text Content - Right Side
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        HospitalInfo.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      
                      // Subtitle
                      Text(
                        HospitalInfo.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Date and time - Horizontal
            Row(
              children: [
                // Date
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // Time
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

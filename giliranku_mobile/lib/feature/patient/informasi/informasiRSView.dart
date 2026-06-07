import 'package:flutter/material.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/theme/theme.dart';
import 'package:giliranku/core/widgets/header.dart';
import 'package:giliranku/feature/patient/informasi/lokasiRSView.dart';

class HospitalData {
  final String name;
  final String description;
  final String vision;
  final List<String> mission;
  final Map<String, String> opHours;
  final List<String> facilities;
  final String address;
  final String phone;
  final String email;

  HospitalData({
    required this.name,
    required this.description,
    required this.vision,
    required this.mission,
    required this.opHours,
    required this.facilities,
    required this.address,
    required this.phone,
    required this.email,
  });

  factory HospitalData.fromJson(Map<String, dynamic> json) {
    return HospitalData(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      vision: json['vision'] ?? '',
      mission: List<String>.from(json['mission'] ?? []),
      opHours: Map<String, String>.from(json['op_hours'] ?? {}),
      facilities: List<String>.from(json['facilities'] ?? []),
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class _C {
  static const teal      = Color(0xFF0B7A6E);
  static const tealLight = Color(0xFFE0F5F1);
  static const tealMid   = Color(0xFF1D9E8F);
  static const navy      = Color(0xFF0D3B5E);
  static const navyLight = Color(0xFFE6EFF6);
  static const amber     = Color(0xFFF59E0B);
  static const amberBg   = Color(0xFFFEF3C7);
  static const bg        = Color(0xFFF4F7F9);
  static const white     = Colors.white;
  static const textPri   = Color(0xFF0D1F2D);
  static const textSec   = Color(0xFF5B7189);
}

class InformasiView extends StatefulWidget {
  const InformasiView({super.key});

  @override
  State<InformasiView> createState() => _InformasiViewState();
}

class _InformasiViewState extends State<InformasiView>
    with TickerProviderStateMixin {
  HospitalData? profile;
  bool _isLoading = true;

  late AnimationController _heroCtrl;
  late AnimationController _staggerCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fetchData();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await ApiDataSource().getInformasi();
    if (mounted) {
      setState(() {
        profile = data != null ? HospitalData.fromJson(data) : null;
        _isLoading = false;
      });
      await Future.delayed(const Duration(milliseconds: 200));
      _staggerCtrl.forward(from: 0);
    }
  }

  void _openMaps() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LokasiRSView(
          hospitalName: profile!.name,
          hospitalAddress: profile!.address,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (profile == null) return _buildError();

    return Scaffold(
      backgroundColor: _C.bg,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: _C.teal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              AppHeader(
                mode: HeaderMode.page,
                title: 'Informasi RSUD Porsea',
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                child: Column(
                  children: [
                    _AnimatedSection(controller: _staggerCtrl, delay: 0.0, child: _buildAboutCard()),
                    const SizedBox(height: 16),
                    _AnimatedSection(controller: _staggerCtrl, delay: 0.1, child: _buildVisiMisiCard()),
                    const SizedBox(height: 16),
                    _AnimatedSection(controller: _staggerCtrl, delay: 0.2, child: _buildOpHoursCard()),
                    const SizedBox(height: 16),
                    _AnimatedSection(controller: _staggerCtrl, delay: 0.3, child: _buildFacilitiesCard()),
                    const SizedBox(height: 16),
                    _AnimatedSection(controller: _staggerCtrl, delay: 0.4, child: _buildContactCard()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
              icon: Icons.info_outline_rounded,
              label: 'Tentang ${profile!.name}',
              color: _C.navy),
          const SizedBox(height: 10),
          Text(
            profile!.description,
            style: const TextStyle(
                color: _C.textSec, height: 1.65, fontSize: 13.5),
          ),
        ],
      ),
    );
  }

  Widget _buildVisiMisiCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECF2), width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SizedBox(width: 8),
              Text('Visi',
                  style: TextStyle(
                      color: _C.teal,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              profile!.vision,
              style: const TextStyle(
                  color: Color(0xFF0D7A6E),
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5, 
                  height: 1.55),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              SizedBox(width: 8),
              Text('Misi',
                  style: TextStyle(
                      color: _C.teal,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          ...profile!.mission.asMap().entries.map((e) => _MisiItem(
                number: e.key + 1,
                text: e.value,
              )),
        ],
      ),
    );
  }

  Widget _buildOpHoursCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
              icon: Icons.schedule_rounded,
              label: 'Jam Operasional',
              color: _C.teal),
          const SizedBox(height: 14),
          ...profile!.opHours.entries.map((e) {
            final isIGD = e.key.toUpperCase() == 'IGD';
            return _OpHourRow(
              label: e.key,
              value: e.value,
              isHighlight: isIGD,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFacilitiesCard() {
    final list = profile!.facilities;
    List<Widget> rows = [];

    for (int i = 0; i < list.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(child: _buildFacilityGridItem(list[i])),
            const SizedBox(width: 12),
            Expanded(
              child: (i + 1 < list.length)
                  ? _buildFacilityGridItem(list[i + 1])
                  : const SizedBox(),
            ),
          ],
        ),
      );
      if (i + 2 < list.length) {
        rows.add(const SizedBox(height: 12));
      }
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
              icon: Icons.local_hospital_rounded,
              label: 'Fasilitas Utama',
              color: _C.navy),
          const SizedBox(height: 16),
          Column(children: rows),
        ],
      ),
    );
  }

  Widget _buildFacilityGridItem(String text) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.business_center_rounded,
            size: 16,
            color: Color(0xFF0D7A6E),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF0D7A6E),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
              icon: Icons.contact_phone_rounded,
              label: 'Kontak & Lokasi',
              color: _C.teal),
          const SizedBox(height: 14),
          _ContactRow(
              icon: Icons.location_on_rounded,
              text: profile!.address,
              color: _C.navy),
          _ContactRow(
              icon: Icons.phone_rounded, text: profile!.phone, color: _C.teal),
          _ContactRow(
              icon: Icons.email_rounded, text: profile!.email, color: _C.teal),
          const SizedBox(height: 16),
          _MapTile(onTap: _openMaps),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: _C.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _C.teal),
            SizedBox(height: 16),
            Text('Memuat informasi...',
                style: TextStyle(color: _C.textSec, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: _C.textSec, size: 48),
            const SizedBox(height: 12),
            const Text('Gagal memuat data.',
                style: TextStyle(color: _C.textSec, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECF2), width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color)),
      ],
    );
  }
}

class _MisiItem extends StatelessWidget {
  final int number;
  final String text;
  const _MisiItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: Color(0xFFE6F4F2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                    color: Color(0xFF0D7A6E),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  color: _C.textPri,
                  fontSize: 13.5, 
                  height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpHourRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  const _OpHourRow(
      {required this.label,
      required this.value,
      this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFFE0F5F1)
            : const Color(0xFFF4F7F9),
        borderRadius: BorderRadius.circular(12),
        border: isHighlight
            ? Border.all(color: _C.tealMid.withValues(alpha: 0.4), width: 1)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isHighlight)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: _C.teal,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(label,
                  style: TextStyle(
                      color: isHighlight ? _C.teal : _C.textSec,
                      fontSize: 13.5,
                      fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
          Text(value,
              style: TextStyle(
                  color: isHighlight ? _C.teal : _C.textPri,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FacilityChip extends StatelessWidget {
  final String label;
  const _FacilityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _C.navyLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: _C.navy.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.medical_services_rounded,
              size: 14, color: _C.navy),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: _C.navy,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _ContactRow(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: _C.textPri, fontSize: 13.5, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _MapTile extends StatefulWidget {
  final VoidCallback onTap;
  const _MapTile({required this.onTap});

  @override
  State<_MapTile> createState() => _MapTileState();
}

class _MapTileState extends State<_MapTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 130,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_C.teal, _C.tealMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -10,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _pulse,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5),
                      ),
                      child: const Icon(Icons.map_rounded,
                          color: Colors.white, size: 26),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Lihat Lokasi di Peta',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('Ketuk untuk membuka peta',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _AnimatedSection({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = delay;
    final end = (delay + 0.5).clamp(0.0, 1.0);

    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOut)),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeOutCubic)),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
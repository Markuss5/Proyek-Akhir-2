import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/widgets/header.dart';
import 'package:iconsax/iconsax.dart';
// ============================================================
// MODEL LOKAL
// ============================================================

class JenisLayanan {
  final int id;
  final String nama;
  const JenisLayanan({required this.id, required this.nama});

  factory JenisLayanan.fromJson(Map<String, dynamic> j) => JenisLayanan(
        id: (j['id'] ?? j['poly_id'] ?? 0) is int
            ? (j['id'] ?? j['poly_id'] ?? 0)
            : int.tryParse('${j['id'] ?? j['poly_id'] ?? 0}') ?? 0,
        nama: j['nama'] ?? j['poly_name'] ?? '',
      );
}

class AntrianResult {
  final String noAntrian;
  final String kodeBooking;
  final String poliklinik;
  final String dokter;
  final String tanggal;
  final String waktu;
  final String pembayaran;
  const AntrianResult({
    required this.noAntrian,
    required this.kodeBooking,
    required this.poliklinik,
    required this.dokter,
    required this.tanggal,
    required this.waktu,
    required this.pembayaran,
  });
  factory AntrianResult.fromJson(Map<String, dynamic> j) => AntrianResult(
        noAntrian: j['no_antrian'] ?? 'A-001',
        kodeBooking: j['kode_booking'] ?? '',
        poliklinik: j['poliklinik'] ?? '-',
        dokter: j['dokter'] ?? 'dr. -',
        tanggal: j['tanggal'] ?? '-',
        waktu: j['waktu'] ?? '-',
        pembayaran: j['pembayaran'] ?? 'Umum',
      );
}

// ============================================================
// ANTRIAN VIEW
// ============================================================

class AntrianView extends StatefulWidget {
  const AntrianView({super.key});

  @override
  State<AntrianView> createState() => _AntrianViewState();
}

class _AntrianViewState extends State<AntrianView>
    with TickerProviderStateMixin {
  final _api = ApiDataSource();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  bool _isPasienLama = true;
  bool _isLoading = false;
  bool _isLoadingLayanan = true;

  List<JenisLayanan> _layananList = [];
  int? _selectedPoliID;
  String _selectedPoliNama = '';

  final _nikCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController(text: '+62');

  String? _nikError;
  String? _namaError;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadLayanan();
  }

  // 1.1 GET /api/v1/antrian/layanan
  Future<void> _loadLayanan() async {
    try {
      // getJenisLayanan() return List<Map<String,dynamic>> langsung
      final list = await _api.getJenisLayanan();
      if (!mounted) return;
      setState(() {
        _layananList = list
            .map((e) => JenisLayanan.fromJson(e))
            .toList();
        _isLoadingLayanan = false;
      });
      _fadeCtrl.forward();
    } catch (e) {
      setState(() => _isLoadingLayanan = false);
      _showSnack('Gagal memuat layanan: $e');
    }
  }

  void _togglePasien(bool isLama) {
    setState(() {
      _isPasienLama = isLama;
      _nikError = null;
      _namaError = null;
    });
    HapticFeedback.lightImpact();
  }

  // 2A.1 POST /api/v1/antrian/cek-nik (jika pasien lama)
  Future<bool> _verifyNIK() async {
    if (!_isPasienLama) return true;
    try {
      final res = await _api.cekNIK(_nikCtrl.text.trim());
      final data = res['data'] as Map<String, dynamic>? ?? {};
      if (data['is_valid'] == true) {
        final nama = data['nama_pasien'] as String?;
        if (nama != null && nama.isNotEmpty && _namaCtrl.text.isEmpty) {
          _namaCtrl.text = nama;
        }
        return true;
      }
      setState(() =>
          _nikError = data['message'] as String? ?? 'NIK tidak terdaftar');
      return false;
    } catch (_) {
      return true; // skip jika API error
    }
  }

  // 4.1 POST /api/v1/antrian
  Future<void> _daftarAntrian() async {
    setState(() {
      _nikError = null;
      _namaError = null;
    });

    bool valid = true;
    if (_nikCtrl.text.trim().length != 16) {
      setState(() => _nikError = 'NIK harus 16 digit');
      valid = false;
    }
    if (_namaCtrl.text.trim().isEmpty) {
      setState(() => _namaError = 'Nama tidak boleh kosong');
      valid = false;
    }
    if (_selectedPoliID == null) {
      _showSnack('Pilih poliklinik terlebih dahulu');
      return;
    }
    if (!valid) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      // 2A - Verifikasi NIK untuk pasien lama
      final nikValid = await _verifyNIK();
      if (!nikValid) {
        setState(() => _isLoading = false);
        return;
      }

      // 4.1 - POST /api/v1/antrian
      final res = await _api.createAntrian({
        'nik': _nikCtrl.text.trim(),
        'nama_pasien': _namaCtrl.text.trim(),
        'telepon': _teleponCtrl.text.trim(),
        'poli_id': _selectedPoliID,
        'is_pasien_lama': _isPasienLama,
        'poliklinik_nama': _selectedPoliNama, // untuk fallback dummy
      });

      final data = res['data'] as Map<String, dynamic>? ?? {};
      final result = AntrianResult.fromJson(data);

      if (mounted) {
        setState(() => _isLoading = false);
        _goToKarcis(result);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Gagal mendaftar: $e');
    }
  }

  void _goToKarcis(AntrianResult result) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, a, __) => KarcisView(result: result),
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF0D9B86),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nikCtrl.dispose();
    _namaCtrl.dispose();
    _teleponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
      top: false,
      child: Column(
        children: [
          AppHeader(
            mode: HeaderMode.page,
            title: 'Ambil Antrian',
            subtitle: 'RSUD Porsea',
            pageIcon: Iconsax.ticket,
          ),

          Expanded(
            child: _isLoadingLayanan
                ? _buildShimmer()
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildToggle(),
                            const SizedBox(height: 24),
                            _buildFormCard(),
                            const SizedBox(height: 28),
                            _buildDaftarButton(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ),
        );
      }

  

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(children: [
        _toggleBtn('Pasien Lama', true),
        _toggleBtn('Pasien Baru', false),
      ]),
    );
  }

  Widget _toggleBtn(String label, bool isLama) {
    final active = _isPasienLama == isLama;
    return Expanded(
      child: GestureDetector(
        onTap: () => _togglePasien(isLama),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color:
                active ? const Color(0xFF0D9B86) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: const Color(0xFF0D9B86)
                            .withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color:
                        active ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: active
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 14)),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(24),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label('Data Pasien'),
        const SizedBox(height: 16),
        _field(
          ctrl: _nikCtrl,
          label: 'NIK (Nomor Induk Kependudukan)',
          hint: 'Masukkan 16 digit NIK',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          maxLength: 16,
          errorText: _nikError,
          formatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        _field(
          ctrl: _namaCtrl,
          label: 'Nama Lengkap',
          hint: 'Masukkan nama lengkap',
          icon: Icons.person_outline_rounded,
          errorText: _namaError,
        ),
        const SizedBox(height: 16),
        _field(
          ctrl: _teleponCtrl,
          label: 'Nomor Telepon',
          hint: '+62',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _label('Pilihan Poliklinik'),
        const SizedBox(height: 12),
        _buildDropdown(),
      ]),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF374151),
          letterSpacing: 0.3));

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? errorText,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280))),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            maxLength: maxLength,
            inputFormatters: formatters,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Color(0xFFBFC5CF), fontSize: 14),
              prefixIcon:
                  Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
              counterText: '',
              errorText: errorText,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB), width: 1.5)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF0D9B86), width: 2)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFFEF4444), width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ]);
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedPoliID == null
              ? const Color(0xFFE5E7EB)
              : const Color(0xFF0D9B86),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedPoliID,
          isExpanded: true,
          hint: const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text('Pilih poliklinik',
                style: TextStyle(
                    color: Color(0xFFBFC5CF), fontSize: 14)),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF9CA3AF)),
          ),
          borderRadius: BorderRadius.circular(12),
          items: _layananList
              .map((l) => DropdownMenuItem<int>(
                    value: l.id,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(l.nama,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF111827))),
                    ),
                  ))
              .toList(),
          onChanged: (v) {
            setState(() {
              _selectedPoliID = v;
              _selectedPoliNama = _layananList
                  .firstWhere((l) => l.id == v,
                      orElse: () =>
                          const JenisLayanan(id: 0, nama: 'Poli Umum'))
                  .nama;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDaftarButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _daftarAntrian,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D9B86),
          disabledBackgroundColor:
              const Color(0xFF0D9B86).withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text('Daftar Sekarang',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ],
              ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(
          4,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 60,
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// KARCIS VIEW
// ============================================================

class KarcisView extends StatefulWidget {
  final AntrianResult result;
  const KarcisView({super.key, required this.result});

  @override
  State<KarcisView> createState() => _KarcisViewState();
}

class _KarcisViewState extends State<KarcisView>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _checkScale =
        CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
    Future.delayed(const Duration(milliseconds: 200), () {
      _checkCtrl.forward();
      HapticFeedback.heavyImpact();
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D9B86),
        elevation: 0,
        title: const Text('Karcis Antrian',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 8),
          _buildBanner(),
          const SizedBox(height: 20),
          _buildKarcisCard(),
          const SizedBox(height: 20),
          _buildTip(),
          const SizedBox(height: 28),
          _buildActions(),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF0D9B86), Color(0xFF0A7A6A)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF0D9B86).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(children: [
        ScaleTransition(
          scale: _checkScale,
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded,
                color: Color(0xFF0D9B86), size: 28),
          ),
        ),
        const SizedBox(width: 16),
        const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pendaftaran Berhasil!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 3),
              Text('Nomor antrian Anda telah dibuat',
                  style:
                      TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
      ]),
    );
  }

  Widget _buildKarcisCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 24,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(children: [
        // Nomor antrian header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFFE6F7F5), Color(0xFFF0FAF9)]),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            const Text('NOMOR ANTRIAN ANDA',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                    letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Text(widget.result.noAntrian,
                style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D9B86),
                    letterSpacing: -2,
                    height: 1)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: const Color(0xFF0D9B86).withValues(alpha: 0.3),
                    width: 1.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Kode Booking  ',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
                Text(widget.result.kodeBooking,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0D9B86),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1)),
              ]),
            ),
          ]),
        ),

        _dashedDivider(),

        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            _infoRow(Icons.local_hospital_outlined, 'Poliklinik',
                widget.result.poliklinik),
            const SizedBox(height: 14),
            _infoRow(Icons.person_outline_rounded, 'Dokter',
                widget.result.dokter),
            const SizedBox(height: 14),
            _infoRow(Icons.calendar_today_outlined, 'Tanggal',
                widget.result.tanggal),
            const SizedBox(height: 14),
            _infoRow(Icons.access_time_outlined, 'Waktu',
                widget.result.waktu),
            const SizedBox(height: 14),
            _infoRow(Icons.payment_outlined, 'Pembayaran',
                widget.result.pembayaran),
          ]),
        ),

        Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          ),
          child: Column(children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              padding: const EdgeInsets.all(10),
              child: CustomPaint(painter: _QRPainter()),
            ),
            const SizedBox(height: 10),
            const Text('Tunjukkan QR Code ini ke petugas',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      ]),
    );
  }

  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        _halfCircle(left: true),
        Expanded(
            child: CustomPaint(
                painter: _DashPainter(),
                child: const SizedBox(height: 1))),
        _halfCircle(left: false),
      ]),
    );
  }

  Widget _halfCircle({required bool left}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.horizontal(
          left: left ? Radius.zero : const Radius.circular(20),
          right: left ? const Radius.circular(20) : Radius.zero,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: const Color(0xFFE6F7F5),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF0D9B86), size: 18),
      ),
      const SizedBox(width: 12),
      Text(label,
          style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400)),
      const Spacer(),
      Text(value,
          style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: Color(0xFFF59E0B), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Harap datang 15 menit sebelum waktu pemeriksaan dimulai.',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF92400E),
                  fontWeight: FontWeight.w500,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () => HapticFeedback.lightImpact(),
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
          label: const Text('Simpan Tiket (PDF)',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D9B86),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton.icon(
          onPressed: () =>
              Navigator.of(context).popUntil((r) => r.isFirst),
          icon: const Icon(Icons.home_outlined, size: 20),
          label: const Text('Kembali ke Beranda',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0D9B86),
            side: const BorderSide(
                color: Color(0xFF0D9B86), width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    ]);
  }
}

// ============================================================
// PAINTERS
// ============================================================

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.5;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 6, 0), paint);
      x += 12;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _QRPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF111827);
    final cell = size.width / 7;
    const pattern = [
      [1, 1, 1, 0, 1, 0, 1],
      [1, 0, 1, 0, 0, 0, 1],
      [1, 1, 1, 0, 1, 1, 0],
      [0, 0, 1, 0, 0, 1, 0],
      [1, 0, 1, 1, 1, 0, 1],
      [0, 1, 0, 0, 1, 0, 1],
      [1, 0, 1, 0, 1, 1, 1],
    ];
    for (int r = 0; r < 7; r++) {
      for (int c = 0; c < 7; c++) {
        if (pattern[r][c] == 1) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                  c * cell + 1, r * cell + 1, cell - 2, cell - 2),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
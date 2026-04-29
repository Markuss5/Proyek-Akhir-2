import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/widgets/header.dart';
import 'package:giliranku/feature/patient/antrian/karcis_view.dart'; // import file kedua
import 'package:iconsax/iconsax.dart';


//                      MODEL LOKAL                          
/// Model untuk data jenis layanan / poliklinik dari API.
/// Mendukung dua format key: 'id'/'poly_id' dan 'nama'/'poly_name'.
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

/// Model hasil pendaftaran antrian yang ditampilkan di halaman karcis.
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

// ║                       ANTRIAN VIEW                          ║

class AntrianView extends StatefulWidget {
  const AntrianView({super.key});

  @override
  State<AntrianView> createState() => _AntrianViewState();
}

class _AntrianViewState extends State<AntrianView>
    with TickerProviderStateMixin {
  final _api = ApiDataSource();

  // ── Animasi ─────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // ── State UI ─────────────────────────────────────────────────
  bool _isPasienLama = true;
  bool _isLoading = false;
  bool _isLoadingLayanan = true;

  // ── Data Poliklinik ──────────────────────────────────────────
  List<JenisLayanan> _layananList = [];
  int? _selectedPoliID;
  String _selectedPoliNama = '';

  // ── Controller Input ─────────────────────────────────────────
  final _nikCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController(text: '+62');

  // ── Pesan Error Validasi ─────────────────────────────────────
  String? _nikError;
  String? _namaError;

  // ════════════════════════════════════════════════════════════
  //  LIFECYCLE
  // ════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadLayanan();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nikCtrl.dispose();
    _namaCtrl.dispose();
    _teleponCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════
  //  DATA / API
  // ════════════════════════════════════════════════════════════

  /// Memuat daftar poliklinik dari API [GET /api/v1/antrian/layanan].
  /// Setelah berhasil, menjalankan animasi fade-in pada form.
  Future<void> _loadLayanan() async {
    try {
      final list = await _api.getJenisLayanan();
      if (!mounted) return;
      setState(() {
        _layananList = list.map((e) => JenisLayanan.fromJson(e)).toList();
        _isLoadingLayanan = false;
      });
      _fadeCtrl.forward();
    } catch (e) {
      setState(() => _isLoadingLayanan = false);
      _showSnack('Gagal memuat layanan: $e');
    }
  }

  /// Memverifikasi NIK ke API [POST /api/v1/antrian/cek-nik].
  /// Hanya dipanggil jika mode pasien lama.
  /// Jika valid, mengisi otomatis field nama pasien dari respons API.
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
      return true; // Lewati jika API error agar tidak memblokir pendaftaran
    }
  }

  /// Memproses pendaftaran antrian [POST /api/v1/antrian].
  /// Urutan: validasi form → verifikasi NIK → kirim data → tampilkan karcis.
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
      final nikValid = await _verifyNIK();
      if (!nikValid) {
        setState(() => _isLoading = false);
        return;
      }

      final res = await _api.createAntrian({
        'nik': _nikCtrl.text.trim(),
        'nama_pasien': _namaCtrl.text.trim(),
        'telepon': _teleponCtrl.text.trim(),
        'poli_id': _selectedPoliID,
        'is_pasien_lama': _isPasienLama,
        'poliklinik_nama': _selectedPoliNama,
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

  // ════════════════════════════════════════════════════════════
  //  NAVIGASI & HELPER
  // ════════════════════════════════════════════════════════════

  /// Navigasi ke halaman karcis dengan transisi fade + slide ke atas.
  void _goToKarcis(AntrianResult result) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, a, __) => KarcisView(result: result),
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ════════════════════════════════════════════════════════════
  //  BUILD UTAMA
  // ════════════════════════════════════════════════════════════

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

  // ════════════════════════════════════════════════════════════
  //  WIDGET BUILDER
  // ════════════════════════════════════════════════════════════

  /// Toggle untuk memilih antara Pasien Lama / Pasien Baru.
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

  /// Tombol individual dalam toggle, aktif/nonaktif berdasarkan [isLama].
  Widget _toggleBtn(String label, bool isLama) {
    final active = _isPasienLama == isLama;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isPasienLama = isLama;
            _nikError = null;
            _namaError = null;
          });
          HapticFeedback.lightImpact();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF0D9B86) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: const Color(0xFF0D9B86).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14)),
          ),
        ),
      ),
    );
  }

  /// Card utama berisi seluruh input form (NIK, nama, telepon, dropdown poli).
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

  /// Input field generik dengan prefix icon, validasi error, dan styling konsisten.
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          hintStyle: const TextStyle(color: Color(0xFFBFC5CF), fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
          counterText: '',
          errorText: errorText,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFE5E7EB), width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF0D9B86), width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ]);
  }

  /// Dropdown untuk memilih poliklinik.
  /// Border berubah hijau saat pilihan sudah dibuat.
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
                style: TextStyle(color: Color(0xFFBFC5CF), fontSize: 14)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(l.nama,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF111827))),
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

  /// Tombol submit pendaftaran. Menampilkan spinner saat proses loading.
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  /// Placeholder shimmer saat data layanan masih dimuat dari API.
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
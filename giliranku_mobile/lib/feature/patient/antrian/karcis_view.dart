import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giliranku/feature/patient/antrian/antrian_view.dart';

// ╔══════════════════════════════════════════════════════════════╗
// ║                        KARCIS VIEW                          ║
// ╚══════════════════════════════════════════════════════════════╝

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

  // ════════════════════════════════════════════════════════════
  //  LIFECYCLE
  // ════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    // Animasi elastik pada ikon centang saat halaman pertama dibuka
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

  // ════════════════════════════════════════════════════════════
  //  BUILD UTAMA
  // ════════════════════════════════════════════════════════════

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

  // ════════════════════════════════════════════════════════════
  //  WIDGET BUILDER
  // ════════════════════════════════════════════════════════════

  /// Banner konfirmasi di atas halaman dengan ikon centang animasi elastik.
  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
      ]),
    );
  }

  /// Kartu karcis utama: nomor antrian, kode booking,
  /// detail info (poli, dokter, tanggal, waktu, pembayaran), dan QR code.
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
        // -- Header: Nomor Antrian --
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFFE6F7F5), Color(0xFFF0FAF9)]),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            // Kode booking dalam pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: const Color(0xFF0D9B86).withValues(alpha: 0.3),
                    width: 1.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Kode Booking  ',
                    style:
                        TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
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

        // -- Body: Detail Info --
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
            _infoRow(
                Icons.access_time_outlined, 'Waktu', widget.result.waktu),
            const SizedBox(height: 14),
            _infoRow(Icons.payment_outlined, 'Pembayaran',
                widget.result.pembayaran),
          ]),
        ),

        // -- Footer: QR Code --
        Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
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

  /// Divider garis putus-putus dengan setengah lingkaran di kiri-kanan
  /// untuk efek visual seperti tiket fisik.
  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        _halfCircle(left: true),
        Expanded(
            child: CustomPaint(
                painter: _DashPainter(), child: const SizedBox(height: 1))),
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

  /// Baris info dengan icon, label di kiri, dan nilai di kanan.
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

  /// Box tips kuning — mengingatkan pasien datang 15 menit lebih awal.
  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
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

  /// Tombol aksi: Simpan PDF dan Kembali ke Beranda.
  Widget _buildActions() {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () => HapticFeedback.lightImpact(),
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
          label: const Text('Simpan Tiket (PDF)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0D9B86),
            side: const BorderSide(color: Color(0xFF0D9B86), width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    ]);
  }
}

// ╔══════════════════════════════════════════════════════════════╗
// ║                         PAINTERS                            ║
// ╚══════════════════════════════════════════════════════════════╝

/// Painter untuk garis putus-putus horizontal pada divider tiket.
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

/// Painter untuk simulasi QR code statis menggunakan grid 7×7.
/// Hanya untuk keperluan tampilan/placeholder — bukan QR code fungsional.
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
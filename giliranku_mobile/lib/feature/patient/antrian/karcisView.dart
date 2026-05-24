import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:giliranku/feature/patient/antrian/antrianUmumView.dart';

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
  bool _isSaving = false;

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

  Widget _buildKarcisCard() {
    if (widget.result.pembayaran.toUpperCase() == 'BPJS') {
      return _buildBpjsCard();
    }
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFFE6F7F5), Color(0xFFF0FAF9)]),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            const Text('Nomor Antrian Admisi :',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Text(widget.result.noAntrian,
                style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    height: 1)),
            const SizedBox(height: 12),
            const Text('Mohon menuju ruang tunggu\nadmisi/pendaftaran',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.4)),
            const SizedBox(height: 24),
            Container(height: 1, color: const Color(0xFFD1D5DB)),
            const SizedBox(height: 16),
            const Text('Nomor Antrian Poli :',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Text(widget.result.noAntrianPoli,
                style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D9B86),
                    height: 1)),
            const SizedBox(height: 8),
            Text(widget.result.poliklinik.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563))),
            Text('(${widget.result.dokter})',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280))),
            const SizedBox(height: 16),
            const Text('semoga lekas sembuh',
                style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            Text(widget.result.tanggal,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
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
            _infoRow(
                Icons.access_time_outlined, 'Waktu', widget.result.waktu),
            const SizedBox(height: 14),
            _infoRow(Icons.payment_outlined, 'Pembayaran',
                widget.result.pembayaran),
          ]),
        ),
      ]),
    );
  }

  Widget _buildBpjsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Text('RSUD Porsea',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.black87),
          const SizedBox(height: 16),
          const Text('Nomor Antrian Admisi :',
              style: TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(widget.result.noAntrian,
              style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1)),
          const SizedBox(height: 8),
          const Text('Mohon menuju ruang tunggu\nadmisi/pendaftaran',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.black87),
          const SizedBox(height: 16),
          const Text('Nomor Antrian Anda :',
              style: TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(widget.result.noAntrianPoli,
              style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1)),
          const SizedBox(height: 8),
          Text(widget.result.kodeBooking,
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(widget.result.poliklinik.toUpperCase(),
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 4),
          Text('Tanggal cetak : ${widget.result.tanggal}',
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 4),
          Text('Asal : ${widget.result.source.toUpperCase()}',
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 4),
          Text('No RM : ${widget.result.noRm}',
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 4),
          Text('Nama : ${widget.result.namaPasien}',
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 24),
          CustomPaint(
            size: const Size(100, 100),
            painter: _QRPainter(),
          ),
          const SizedBox(height: 24),
          const Text('semoga lekas sembuh',
              style: TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

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

  Widget _buildActions() {
    return Column(children: [
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _generateAndSavePdf,
          icon: _isSaving 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.picture_as_pdf_outlined, size: 20),
          label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Tiket (PDF)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
  Future<void> _generateAndSavePdf() async {
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            await Permission.manageExternalStorage.request();
          }
        }
      }

      final pdf = pw.Document();

      final isBpjs = widget.result.pembayaran.toUpperCase() == 'BPJS';

      pdf.addPage(
        pw.Page(
          pageFormat: isBpjs ? const PdfPageFormat(80 * PdfPageFormat.mm, 200 * PdfPageFormat.mm) : PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(16),
          build: (pw.Context context) {
            if (isBpjs) {
              return pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('RSUD Porsea', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 10),
                    pw.Text('Nomor Antrian Admisi :', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 5),
                    pw.Text(widget.result.noAntrian, style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text('Mohon menuju ruang tunggu\nadmisi/pendaftaran', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 10),
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 10),
                    pw.Text('Nomor Antrian Anda :', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 5),
                    pw.Text(widget.result.noAntrianPoli, style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text(widget.result.kodeBooking, style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 2),
                    pw.Text(widget.result.poliklinik.toUpperCase(), style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 2),
                    pw.Text('Tanggal cetak : ${widget.result.tanggal}', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 2),
                    pw.Text('Asal : ${widget.result.source.toUpperCase()}', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 2),
                    pw.Text('No RM : ${widget.result.noRm}', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 2),
                    pw.Text('Nama : ${widget.result.namaPasien}', style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 16),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: widget.result.kodeBooking,
                      width: 60,
                      height: 60,
                    ),
                    pw.SizedBox(height: 16),
                    pw.Text('semoga lekas sembuh', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              );
            }
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('Nomor Antrian Admisi :', style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 10),
                  pw.Text(widget.result.noAntrian, style: pw.TextStyle(fontSize: 48, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text('Mohon menuju ruang tunggu admisi/pendaftaran', style: const pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.SizedBox(height: 20),
                  pw.Text('Nomor Antrian Poli :', style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 10),
                  pw.Text(widget.result.noAntrianPoli, style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text(widget.result.poliklinik.toUpperCase(), style: const pw.TextStyle(fontSize: 16)),
                  pw.Text('(${widget.result.dokter})', style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 20),
                  pw.Text('Semoga lekas sembuh', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text(widget.result.tanggal, style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            );
          },
        ),
      );

      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      if (dir == null) throw Exception("Tidak dapat menemukan direktori penyimpanan");
      
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final fileName = 'Tiket_Antrian_${widget.result.noAntrianPoli}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Tiket berhasil disimpan: $fileName'),
          backgroundColor: const Color(0xFF0D9B86),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menyimpan PDF: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

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
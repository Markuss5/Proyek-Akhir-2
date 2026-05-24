import 'package:flutter/material.dart';

import 'package:giliran_ku/core/datasources/apiException.dart';
import 'package:giliran_ku/feature/kiosk/consultation/consultationController.dart';
import 'package:giliran_ku/feature/kiosk/ticketView.dart';
import 'package:giliran_ku/core/models/doctorModel.dart';
import 'package:giliran_ku/core/models/poliModel.dart';

class ConsultationGeneralView extends StatefulWidget {
  const ConsultationGeneralView({super.key});

  @override
  State<ConsultationGeneralView> createState() => _ConsultationGeneralViewState();
}

class _ConsultationGeneralViewState extends State<ConsultationGeneralView> {
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  
  final ConsultationController _controller = ConsultationController();

  bool _isPasienLama = false;
  bool _loading = false;
  bool _loadingLayanan = false;
  bool _loadingDoctors = false;
  String? _error;

  List<Poli> _polis = [];
  Poli? _selectedPoli;
  List<Doctor> _doctors = [];
  Doctor? _selectedDoctor;

  @override
  void initState() {
    super.initState();
    _loadPolis();
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  Future<void> _loadPolis() async {
    setState(() {
      _loadingLayanan = true;
      _error = null;
    });

    try {
      final polis = await _controller.fetchPoliList();
      if (!mounted) return;
      setState(() {
        _polis = polis;
        _loadingLayanan = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _readError(error);
        _loadingLayanan = false;
      });
    }
  }

  Future<void> _loadDoctors(Poli poli) async {
    setState(() {
      _loadingDoctors = true;
      _doctors = [];
      _selectedDoctor = null;
    });

    try {
      final date = DateTime.now().toIso8601String().split('T')[0];
      final doctors = await _controller.fetchDoctors(poli.id, date);
      if (!mounted) return;
      setState(() {
        _doctors = doctors;
        _loadingDoctors = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingDoctors = false);
    }
  }

  Future<void> _submit() async {
    final nik = _nikController.text.trim();
    if (nik.isEmpty) {
      setState(() => _error = 'Masukkan NIK');
      return;
    }
    
    if (!_isPasienLama) {
      if (_namaController.text.trim().isEmpty || _teleponController.text.trim().isEmpty) {
        setState(() => _error = 'Nama Lengkap dan Nomor Telepon harus diisi');
        return;
      }
    }

    if (_selectedPoli == null || _selectedDoctor == null) {
      setState(() => _error = 'Pilih poli dan dokter terlebih dahulu');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ticket = await _controller.createTicketForGeneral(
        nik: nik,
        poli: _selectedPoli!,
        doctor: _selectedDoctor!,
        isPasienLama: _isPasienLama,
        namaPasien: _namaController.text.trim(),
        telepon: _teleponController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TicketView(ticket: ticket),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _readError(error));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _readError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasien Umum'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF0FBF7),
              Color(0xFFE6F7F0),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Pasien Umum',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF0A3D2E),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Silakan lengkapi data pasien dan pilih poli tujuan.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF577A6D),
                  ),
            ),
            const SizedBox(height: 20),

            // Toggle Pasien Lama / Baru
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isPasienLama = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !_isPasienLama ? const Color(0xFFE0F2F1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: !_isPasienLama ? Border.all(color: const Color(0xFF25A699)) : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text('Pasien Baru',
                            style: TextStyle(
                              fontWeight: !_isPasienLama ? FontWeight.bold : FontWeight.normal,
                              color: !_isPasienLama ? const Color(0xFF25A699) : Colors.grey,
                            )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isPasienLama = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isPasienLama ? const Color(0xFFE0F2F1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: _isPasienLama ? Border.all(color: const Color(0xFF25A699)) : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text('Pasien Lama',
                            style: TextStyle(
                              fontWeight: _isPasienLama ? FontWeight.bold : FontWeight.normal,
                              color: _isPasienLama ? const Color(0xFF25A699) : Colors.grey,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Form Identitas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD7EFE6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F4ED),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF2FAE86),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Identitas Pasien',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  TextField(
                    controller: _nikController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _isPasienLama ? 'NIK / No. Rekam Medis' : 'NIK',
                      hintText: 'Contoh: 1203010101010001',
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                  ),
                  if (!_isPasienLama) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        hintText: 'Masukkan nama pasien',
                        prefixIcon: Icon(Icons.abc),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _teleponController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        hintText: '08',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pilihan Poli & Dokter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD7EFE6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F4ED),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.apartment_outlined,
                          color: Color(0xFF2FAE86),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pilih Layanan & Dokter',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_loadingLayanan)
                    const Center(child: CircularProgressIndicator())
                  else
                    DropdownButtonFormField<Poli>(
                      value: _selectedPoli,
                      decoration: const InputDecoration(
                        labelText: 'Poliklinik',
                        prefixIcon: Icon(Icons.apartment),
                      ),
                      items: _polis.map((p) {
                        return DropdownMenuItem<Poli>(
                          value: p,
                          child: Text(p.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedPoli = val;
                          _selectedDoctor = null;
                        });
                        if (val != null) {
                          _loadDoctors(val);
                        }
                      },
                    ),
                  const SizedBox(height: 12),
                  if (_loadingDoctors)
                    const Center(child: CircularProgressIndicator())
                  else if (_selectedPoli != null && _doctors.isEmpty)
                    const Text('Tidak ada dokter tersedia.', style: TextStyle(color: Colors.red))
                  else
                    DropdownButtonFormField<Doctor>(
                      value: _selectedDoctor,
                      decoration: const InputDecoration(
                        labelText: 'Dokter',
                        prefixIcon: Icon(Icons.medical_services_outlined),
                      ),
                      items: _doctors.map((d) {
                        return DropdownMenuItem<Doctor>(
                          value: d,
                          child: Text(d.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDoctor = val;
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: const Icon(Icons.print),
                label: Text(_loading ? 'Mencetak...' : 'Cetak Tiket Umum'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

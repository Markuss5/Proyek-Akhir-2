import 'package:flutter/material.dart';

import 'package:giliran_ku/core/datasources/apiException.dart';
import 'package:giliran_ku/feature/kiosk/consultation/consultationController.dart';
import 'package:giliran_ku/feature/kiosk/ticketView.dart';
import 'package:giliran_ku/core/models/doctorModel.dart';

class ConsultationBpjsView extends StatefulWidget {
  const ConsultationBpjsView({super.key});

  @override
  State<ConsultationBpjsView> createState() => _ConsultationBpjsViewState();
}

class _ConsultationBpjsViewState extends State<ConsultationBpjsView> {
  final _inputController = TextEditingController();
  final ConsultationController _controller = ConsultationController();

  bool _loading = false;
  bool _loadingRujukan = false;
  bool _loadingDoctors = false;
  String? _error;

  List<dynamic> _rujukanList = [];
  Map<String, dynamic>? _selectedRujukan;
  List<Doctor> _doctors = [];
  int? _selectedDokterID;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _cariRujukan() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() => _error = 'Masukkan NIK atau No BPJS');
      return;
    }

    setState(() {
      _loadingRujukan = true;
      _error = null;
      _rujukanList = [];
      _selectedRujukan = null;
      _doctors = [];
      _selectedDokterID = null;
    });

    try {
      final list = await _controller.fetchRujukanBpjs(input);
      if (!mounted) return;
      setState(() {
        _rujukanList = list;
        _loadingRujukan = false;
      });
      if (list.isEmpty) {
        setState(() => _error = 'Rujukan tidak ditemukan untuk NIK ini.');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _readError(error);
        _loadingRujukan = false;
      });
    }
  }

  Future<void> _loadDoctors(int poliId) async {
    setState(() {
      _loadingDoctors = true;
      _doctors = [];
      _selectedDokterID = null;
    });

    try {
      final date = DateTime.now().toIso8601String().split('T')[0];
      final doctors = await _controller.fetchDoctors(poliId.toString(), date);
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
    if (_selectedRujukan == null) {
      setState(() => _error = 'Pilih rujukan terlebih dahulu');
      return;
    }
    if (_selectedDokterID == null) {
      setState(() => _error = 'Pilih dokter terlebih dahulu');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ticket = await _controller.createBpjsTicketDynamic(
        nik: _inputController.text.trim(),
        noRujukan: _selectedRujukan!['no_rujukan'],
        dokterId: _selectedDokterID!,
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
        title: const Text('Pasien BPJS'),
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
              'Pasien BPJS',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF0A3D2E),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Masukkan NIK untuk mencari rujukan BPJS.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF577A6D),
                  ),
            ),
            const SizedBox(height: 20),
            
            // Pencarian Rujukan
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
                          Icons.health_and_safety_outlined,
                          color: Color(0xFF2FAE86),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pencarian Rujukan',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'NIK Pasien',
                            hintText: 'Contoh: 1203010101010001',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            errorText: _error,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ElevatedButton.icon(
                          onPressed: _loadingRujukan ? null : _cariRujukan,
                          icon: _loadingRujukan
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.search),
                          label: const Text('Cari'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_rujukanList.isNotEmpty) ...[
              Text(
                'Pilih Surat Rujukan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF0A3D2E),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ..._rujukanList.map((rujukan) {
                final isSelected = _selectedRujukan == rujukan;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRujukan = rujukan;
                    });
                    if (rujukan['poli_id'] != null) {
                      _loadDoctors(rujukan['poli_id']);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE2F4ED) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isSelected ? const Color(0xFF25A699) : Colors.grey.shade300,
                          width: isSelected ? 2 : 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rujukan['no_rujukan'] ?? '-',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Color(0xFF25A699)),
                          ],
                        ),
                        const Divider(),
                        Text('Faskes: ${rujukan['faskes_perujuk'] ?? '-'}'),
                        Text('Poli: ${rujukan['poli_nama'] ?? '-'}'),
                        Text('Diagnosa: ${rujukan['diagnosa'] ?? '-'}'),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            if (_selectedRujukan != null) ...[
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
                            Icons.person,
                            color: Color(0xFF2FAE86),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pilih Dokter Spesialis',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_loadingDoctors)
                      const Center(child: CircularProgressIndicator())
                    else if (_doctors.isEmpty)
                      const Text('Tidak ada dokter tersedia hari ini.',
                          style: TextStyle(color: Colors.red))
                    else
                      DropdownButtonFormField<int>(
                        value: _selectedDokterID,
                        decoration: const InputDecoration(
                          labelText: 'Pilih Dokter',
                          prefixIcon: Icon(Icons.medical_services_outlined),
                        ),
                        items: _doctors.map((doc) {
                          return DropdownMenuItem<int>(
                            value: int.tryParse(doc.id) ?? 0,
                            child: Text(doc.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDokterID = val;
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
                  label: Text(_loading ? 'Mencetak...' : 'Cetak Tiket BPJS'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

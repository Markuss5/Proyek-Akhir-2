import 'package:flutter/material.dart';

import '../../data/api/api_exception.dart';
import '../../data/models/doctor.dart';
import '../../data/models/patient.dart';
import '../../data/models/poli.dart';
import '../../logic/consultation/consultation_controller.dart';
import '../ticket_view.dart';

class ConsultationGeneralSelectView extends StatefulWidget {
  final Patient patient;

  const ConsultationGeneralSelectView({
    super.key,
    required this.patient,
  });

  @override
  State<ConsultationGeneralSelectView> createState() =>
      _ConsultationGeneralSelectViewState();
}

class _ConsultationGeneralSelectViewState
    extends State<ConsultationGeneralSelectView> {
  final ConsultationController _controller = ConsultationController();

  bool _loading = false;
  bool _loadingDoctors = false;
  String? _error;
  List<Poli> _polis = [];
  List<Doctor> _doctors = [];
  Poli? _selectedPoli;
  Doctor? _selectedDoctor;

  @override
  void initState() {
    super.initState();
    _loadPolis();
  }

  Future<void> _loadPolis() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final polis = await _controller.fetchPoliList();
      if (!mounted) return;
      _polis = polis;
      _selectedPoli = polis.isNotEmpty ? polis.first : null;
      setState(() {});
      if (_selectedPoli != null) {
        await _loadDoctors(_selectedPoli!);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _readError(error));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _loadDoctors(Poli poli) async {
    setState(() {
      _loadingDoctors = true;
      _error = null;
    });

    try {
      final doctors = await _controller.fetchDoctors(poli.id);
      if (!mounted) return;
      setState(() {
        _doctors = doctors;
        _selectedDoctor = doctors.isNotEmpty ? doctors.first : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _readError(error));
    } finally {
      if (!mounted) return;
      setState(() => _loadingDoctors = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedPoli == null || _selectedDoctor == null) {
      setState(() => _error = 'Pilih poli dan dokter');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ticket = await _controller.createTicketForGeneral(
        nik: widget.patient.nik,
        poli: _selectedPoli!,
        doctor: _selectedDoctor!,
      );
      if (!mounted) return;
      Navigator.push(
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
        title: const Text('Pilih Poli dan Dokter'),
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
            if (_loading) const LinearProgressIndicator(),
            if (_loading) const SizedBox(height: 12),
            Text(
              'Pilih Poli dan Dokter',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF0A3D2E),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pastikan poli dan dokter sesuai tujuan layanan pasien.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF577A6D),
                  ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD7EFE6)),
              ),
              child: Row(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patient.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NIK: ${widget.patient.nik}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: const Color(0xFF4E6E62)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD7EFE6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Poli>(
                    value: _selectedPoli,
                    items: _polis
                        .map(
                          (poli) => DropdownMenuItem(
                            value: poli,
                            child: Text(poli.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedPoli = value;
                        _selectedDoctor = null;
                        _doctors = [];
                      });
                      _loadDoctors(value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Pilih Poli',
                      prefixIcon: Icon(Icons.apartment_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<Doctor>(
                    value: _selectedDoctor,
                    items: _doctors
                        .map(
                          (doctor) => DropdownMenuItem(
                            value: doctor,
                            child: Text(doctor.name),
                          ),
                        )
                        .toList(),
                    onChanged: _loadingDoctors
                        ? null
                        : (value) {
                            setState(() => _selectedDoctor = value);
                          },
                    decoration: const InputDecoration(
                      labelText: 'Pilih Dokter',
                      prefixIcon: Icon(Icons.medical_services_outlined),
                    ),
                  ),
                  if (!_loadingDoctors &&
                      _selectedPoli != null &&
                      _doctors.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Dokter belum tersedia untuk poli ini.'),
                    ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(_loading ? 'Memproses...' : 'Buat Tiket'),
            ),
          ],
        ),
      ),
    );
  }
}

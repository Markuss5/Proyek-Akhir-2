import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:giliran_ku/core/datasources/apiException.dart';
import 'package:giliran_ku/feature/kiosk/consultation/consultationController.dart';
import 'package:giliran_ku/core/widgets/printingScreen.dart';
import 'package:giliran_ku/core/models/doctorModel.dart';

class ConsultationBpjsView extends StatefulWidget {
  const ConsultationBpjsView({super.key});

  @override
  State<ConsultationBpjsView> createState() => _ConsultationBpjsViewState();
}

class _ConsultationBpjsViewState extends State<ConsultationBpjsView> {
  static const Color _primary = Color(0xFF17A889);
  static const Color _dark = Color(0xFF0A7D67);
  static const Color _darkText = Color(0xFF063D2C);
  static const Color _mutedText = Color(0xFF2E7A60);
  static const Color _iconBg = Color(0xFFD5F0E6);
  static const Color _cardBorder = Color(0xFFC3E8D8);
  static const Color _selectedBg = Color(0xFFE6F7F1);

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
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pendaftaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah data Anda sudah sesuai?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _processSubmit();
            },
            style: ElevatedButton.styleFrom(backgroundColor: _dark, foregroundColor: Colors.white),
            child: const Text('Ya, Cetak Tiket'),
          ),
        ],
      ),
    );
  }

  Future<void> _processSubmit() async {
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
          builder: (_) => PrintingScreen(ticket: ticket),
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
    if (error is ApiException) return error.message;
    return 'Terjadi kesalahan. Coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF6),
      appBar: AppBar(
        backgroundColor: _dark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Pasien BPJS'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F5F0), Color(0xFFF0FAF6), Color(0xFFFAFFFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildSearchCard(context),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _buildErrorBanner(),
            ],
            if (_loadingRujukan) ...[
              const SizedBox(height: 24),
              const Center(
                child: CircularProgressIndicator(color: _primary),
              ),
            ],
            if (_rujukanList.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionLabel(context, 'PILIH SURAT RUJUKAN'),
              const SizedBox(height: 10),
              ..._rujukanList.map((r) => _buildRujukanCard(context, r)),
            ],
            if (_selectedRujukan != null) ...[
              const SizedBox(height: 24),
              _buildSectionLabel(context, 'PILIH DOKTER'),
              const SizedBox(height: 10),
              _buildDoctorCard(context),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pasien BPJS',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _darkText,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Masukkan NIK untuk mencari rujukan BPJS.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _mutedText,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: _primary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.health_and_safety_outlined,
                    color: _dark, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Pencarian Rujukan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _darkText,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            keyboardType: TextInputType.number,
            maxLength: 16,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              labelText: 'NIK atau No BPJS',
              hintText: 'Contoh: 1203010101010001',
              prefixIcon: const Icon(Icons.badge_outlined, color: _primary),
              filled: true,
              fillColor: const Color(0xFFF5FBF8),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
              labelStyle: const TextStyle(color: _mutedText),
              floatingLabelStyle: const TextStyle(color: _primary),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loadingRujukan ? null : _cariRujukan,
              icon: _loadingRujukan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.search, size: 20),
              label: Text(_loadingRujukan ? 'Mencari...' : 'Cari Rujukan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _dark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRujukanCard(BuildContext context, Map<String, dynamic> rujukan) {
    final isSelected = _selectedRujukan == rujukan;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedRujukan = rujukan);
        if (rujukan['poli_id'] != null) _loadDoctors(rujukan['poli_id']);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primary : _cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    rujukan['no_rujukan'] ?? '-',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _dark : _darkText,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: _primary, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: isSelected ? _cardBorder : Colors.grey.shade200),
            const SizedBox(height: 6),
            _buildRujukanRow(Icons.local_hospital_outlined,
                'Faskes', rujukan['faskes_perujuk']),
            const SizedBox(height: 4),
            _buildRujukanRow(
                Icons.medical_services_outlined, 'Poli', rujukan['poli_nama']),
            const SizedBox(height: 4),
            _buildRujukanRow(
                Icons.description_outlined, 'Diagnosa', rujukan['diagnosa']),
          ],
        ),
      ),
    );
  }

  Widget _buildRujukanRow(IconData icon, String label, dynamic value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: _mutedText),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 13, color: _mutedText, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value?.toString() ?? '-',
            style: const TextStyle(fontSize: 13, color: _darkText),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child:
                    const Icon(Icons.person_outlined, color: _dark, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Pilih Dokter Spesialis',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _darkText,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingDoctors)
            const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(color: _primary),
            ))
          else if (_doctors.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_outlined,
                      color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Text('Tidak ada dokter tersedia hari ini.',
                      style: TextStyle(color: Colors.orange, fontSize: 13)),
                ],
              ),
            )
          else
            DropdownButtonFormField<int>(
              value: _selectedDokterID,
              decoration: InputDecoration(
                labelText: 'Pilih Dokter',
                prefixIcon:
                    const Icon(Icons.medical_services_outlined, color: _primary),
                filled: true,
                fillColor: const Color(0xFFF5FBF8),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primary, width: 1.5),
                ),
                labelStyle: const TextStyle(color: _mutedText),
                floatingLabelStyle: const TextStyle(color: _primary),
              ),
              items: _doctors.map((doc) {
                return DropdownMenuItem<int>(
                  value: int.tryParse(doc.id) ?? 0,
                  child: Text(doc.name),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedDokterID = val),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _submit,
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.print_outlined, size: 20),
        label: Text(
          _loading ? 'Mencetak...' : 'Cetak Tiket BPJS',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _dark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:giliranku/services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> patientData;

  const EditProfilePage({super.key, required this.patientData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _bpjsCtrl;
  late TextEditingController _alamatCtrl;

  String? _selectedGolDarah;
  String? _selectedJenisKelamin;
  bool _isSaving = false;

  final List<String> _golDarahOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _jenisKelaminOptions = ['L', 'P'];

  @override
  void initState() {
    super.initState();
    final d = widget.patientData;
    _nameCtrl = TextEditingController(text: d['patient_name'] ?? '');
    _phoneCtrl = TextEditingController(text: d['phone'] ?? '');
    _emailCtrl = TextEditingController(text: d['email'] ?? '');
    _bpjsCtrl = TextEditingController(text: d['no_bpjs'] ?? '');
    _alamatCtrl = TextEditingController(text: d['alamat'] ?? '');
    _selectedGolDarah = d['golongan_darah'];
    _selectedJenisKelamin = d['jenis_kelamin'];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _bpjsCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack('Nama tidak boleh kosong', Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    final updated = await ApiService.updateProfile({
      'nik': widget.patientData['nik'],
      'patient_name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      'no_bpjs': _bpjsCtrl.text.trim().isEmpty ? null : _bpjsCtrl.text.trim(),
      'golongan_darah': _selectedGolDarah,
      'alamat': _alamatCtrl.text.trim().isEmpty ? null : _alamatCtrl.text.trim(),
      'jenis_kelamin': _selectedJenisKelamin,
    });

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (updated != null) {
      _showSnack('Profil berhasil diperbarui', const Color(0xFF2F9E8F));
      Navigator.pop(context, updated); // Return updated data
    } else {
      _showSnack('Gagal memperbarui profil', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F9E8F),
        foregroundColor: Colors.white,
        title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NIK (read-only)
            _buildReadOnlyField('NIK', widget.patientData['nik'] ?? '-'),
            const SizedBox(height: 16),

            // No. RM (read-only)
            _buildReadOnlyField('No. Rekam Medis', widget.patientData['no_rm'] ?? '-'),
            const SizedBox(height: 16),

            // Nama
            _buildTextField('Nama Lengkap', _nameCtrl),
            const SizedBox(height: 16),

            // Jenis Kelamin
            _buildDropdown(
              'Jenis Kelamin',
              _selectedJenisKelamin,
              _jenisKelaminOptions.map((e) => DropdownMenuItem(
                value: e,
                child: Text(e == 'L' ? 'Laki-laki' : 'Perempuan'),
              )).toList(),
              (val) => setState(() => _selectedJenisKelamin = val),
            ),
            const SizedBox(height: 16),

            // Phone
            _buildTextField('No. Telepon', _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),

            // Email
            _buildTextField('Email', _emailCtrl, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),

            // BPJS
            _buildTextField('No. BPJS (Opsional)', _bpjsCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 16),

            // Golongan Darah
            _buildDropdown(
              'Golongan Darah',
              _selectedGolDarah,
              _golDarahOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              (val) => setState(() => _selectedGolDarah = val),
            ),
            const SizedBox(height: 16),

            // Alamat
            _buildTextField('Alamat', _alamatCtrl, maxLines: 3),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F9E8F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2F9E8F), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value,
      List<DropdownMenuItem<String>> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text('Pilih $label', style: TextStyle(color: Colors.grey[400])),
              value: value,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

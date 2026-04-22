import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/theme/theme.dart';

class KelolaInformasiView extends StatefulWidget {
  const KelolaInformasiView({super.key});

  @override
  State<KelolaInformasiView> createState() => _KelolaInformasiViewState();
}

class _KelolaInformasiViewState extends State<KelolaInformasiView> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _visionController = TextEditingController();
  final _missionController = TextEditingController();
  final _opHoursController = TextEditingController();
  final _facilitiesController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await ApiDataSource().getInformasi();
    if (data != null) {
      _namaController.text = data['name'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _visionController.text = data['vision'] ?? '';
      
      final List<dynamic> mission = data['mission'] ?? [];
      _missionController.text = mission.join('\n');
      
      final Map<String, dynamic> opHours = data['op_hours'] ?? {};
      _opHoursController.text = opHours.entries.map((e) => '${e.key}: ${e.value}').join('\n');
      
      final List<dynamic> facilities = data['facilities'] ?? [];
      _facilitiesController.text = facilities.join('\n');
      
      _addressController.text = data['address'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _emailController.text = data['email'] ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    // Parse multiline strings
    final mission = _missionController.text.split('\n').where((e) => e.trim().isNotEmpty).toList();
    final facilities = _facilitiesController.text.split('\n').where((e) => e.trim().isNotEmpty).toList();
    
    final Map<String, String> opHours = {};
    for (final line in _opHoursController.text.split('\n')) {
      final parts = line.split(':');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts.sublist(1).join(':').trim();
        if (key.isNotEmpty) opHours[key] = value;
      }
    }

    final success = await ApiDataSource().updateInformasi({
      'name': _namaController.text,
      'description': _descriptionController.text,
      'vision': _visionController.text,
      'mission': mission,
      'op_hours': opHours,
      'facilities': facilities,
      'address': _addressController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
    });
    
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Informasi berhasil disimpan' : 'Gagal menyimpan'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _descriptionController.dispose();
    _visionController.dispose();
    _missionController.dispose();
    _opHoursController.dispose();
    _facilitiesController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField('Nama Rumah Sakit', _namaController),
            const SizedBox(height: 16),
            _buildTextField('Deskripsi', _descriptionController, maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField('Visi', _visionController, maxLines: 2),
            const SizedBox(height: 16),
            _buildTextField('Misi (Pisahkan dengan baris baru)', _missionController, maxLines: 4),
            const SizedBox(height: 16),
            _buildTextField('Jam Operasional (Format -> Hari: Jam)', _opHoursController, maxLines: 3, hintText: 'Senin - Sabtu: 08:00 - 16:00 WIB\nIGD: Buka 24 Jam'),
            const SizedBox(height: 16),
            _buildTextField('Fasilitas (Pisahkan dengan baris baru)', _facilitiesController, maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField('Alamat', _addressController, maxLines: 2),
            const SizedBox(height: 16),
            _buildTextField('No. Telepon', _phoneController),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (value) => value == null || value.isEmpty ? 'Field ini harus diisi' : null,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:giliranku/core/repositories/pasienRepository.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/services/sessionService.dart';
import 'package:giliranku/core/utils/riwayatHelper.dart';

class RiwayatView extends StatefulWidget {
  const RiwayatView({super.key});

  @override
  State<RiwayatView> createState() => _RiwayatViewState();
}

class _RiwayatViewState extends State<RiwayatView> {
  List<Map<String, dynamic>> _riwayatList = [];
  bool _isLoading = true;
  String? _nik;

  DateTime? _selectedDateFilter;
  String _selectedPoliFilter = 'Semua Poli';
  String _selectedStatusFilter = 'Semua Status';
  String _selectedSortCategory = 'Tanggal';
  bool _isSortAscending = true;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _availablePoli {
    return RiwayatHelper.getAvailablePoli(_riwayatList);
  }

  List<Map<String, dynamic>> get _filteredRiwayat {
    return RiwayatHelper.filterAndSortRiwayat(
      riwayatList: _riwayatList,
      selectedDateFilter: _selectedDateFilter,
      selectedPoliFilter: _selectedPoliFilter,
      selectedStatusFilter: _selectedStatusFilter,
      searchQuery: _searchQuery,
      selectedSortCategory: _selectedSortCategory,
      isSortAscending: _isSortAscending,
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final patientData = await SessionService().getPatientMap();
    _nik = patientData?['nik'];

    if (_nik != null) {
      final data = await PasienRepository().getRiwayatAntrian(_nik!);

      if (mounted) {
        setState(() {
          _riwayatList = data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final kodeBooking = item['kode_booking'] as String? ?? '';
    if (kodeBooking.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Riwayat', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Hapus riwayat antrian dengan kode berikut?\n$kodeBooking\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ApiDataSource().deleteAntrian(kodeBooking);
    if (!mounted) return;

    if (success) {
      setState(() => _riwayatList.removeWhere(
          (e) => e['kode_booking'] == kodeBooking));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Riwayat berhasil dihapus'),
          backgroundColor: Color(0xFF25A699),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus riwayat.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFilterModal() {
    RiwayatHelper.showFilterModal(
      context: context,
      availablePoli: _availablePoli,
      selectedDateFilter: _selectedDateFilter,
      selectedPoliFilter: _selectedPoliFilter,
      selectedStatusFilter: _selectedStatusFilter,
      onDateChanged: (val) => setState(() => _selectedDateFilter = val),
      onPoliChanged: (val) => setState(() => _selectedPoliFilter = val),
      onStatusChanged: (val) => setState(() => _selectedStatusFilter = val),
    );
  }

  void _showSortModal() {
    RiwayatHelper.showSortModal(
      context: context,
      selectedSortCategory: _selectedSortCategory,
      isSortAscending: _isSortAscending,
      onSortCategoryChanged: (val) => setState(() => _selectedSortCategory = val),
      onSortAscendingToggled: () => setState(() => _isSortAscending = !_isSortAscending),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RiwayatHelper.buildScaffold(
      context: context,
      isLoading: _isLoading,
      riwayatList: _riwayatList,
      filteredRiwayat: _filteredRiwayat,
      searchCtrl: _searchCtrl,
      onChangedSearch: (val) {
        setState(() {
          _searchQuery = val;
        });
      },
      onShowFilterModal: _showFilterModal,
      onShowSortModal: _showSortModal,
      onRefresh: _fetchRiwayat,
      onConfirmDelete: _confirmDelete,
    );
  }
}
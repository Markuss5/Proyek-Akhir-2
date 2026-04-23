import 'package:flutter/material.dart';

class Doctor {
  final String name;
  final String specialty;
  final String time;
  final String status;
  final Color statusColor;
  final IconData icon;

  Doctor({
    required this.name,
    required this.specialty,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.icon,
  });
}

class InformasiDokterPage extends StatelessWidget {
  final List<Doctor> doctors = [
    Doctor(
      name: "dr. Hendra Siahaan, Sp.PD",
      specialty: "Poli Umum / Penyakit Dalam",
      time: "08:00-12:00",
      status: "Tersedia",
      statusColor: Colors.green,
      icon: Icons.person,
    ),
    Doctor(
      name: "dr. Maria Napitupulu, Sp.A",
      specialty: "Poli Anak",
      time: "09:00-13:00",
      status: "Antrian Padat",
      statusColor: Colors.orange,
      icon: Icons.child_care,
    ),
    Doctor(
      name: "drg. Riani Hutabarat",
      specialty: "Poli Gigi",
      time: "10:00-14:00",
      status: "Tersedia",
      statusColor: Colors.green,
      icon: Icons.details,
    ),
    Doctor(
      name: "dr. Soraya Sinaga, Sp.OG",
      specialty: "Poli Kandungan",
      time: "08:00-11:00",
      status: "Tersedia",
      statusColor: Colors.green,
      icon: Icons.pregnant_woman,
    ),
    Doctor(
      name: "dr. Gunawan, Sp.B",
      specialty: "Poli Bedah",
      time: "11:00-15:00",
      status: "Sedang Operasi",
      statusColor: Colors.red,
      icon: Icons.person_search,
    ),
  ];

  InformasiDokterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF25A699), // Warna hijau toska
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Informasi Dokter",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Bagian Pencarian
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari Informasi Jadwal...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              ),
            ),
          ),
          
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDayFilter("Sen", true),
                _buildDayFilter("Sel", false),
                _buildDayFilter("Rab", false),
                _buildDayFilter("Kam", false),
                _buildDayFilter("Jum", false),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          // Daftar Kartu Dokter
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                return _buildDoctorCard(doctors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membangun tombol filter hari
  Widget _buildDayFilter(String day, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE0F2F1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: const Color(0xFF25A699)) : null,
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: isSelected ? const Color(0xFF25A699) : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Widget untuk membangun kartu informasi dokter
  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon Representasi Poli
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(doctor.icon, color: const Color(0xFF25A699), size: 28),
          ),
          const SizedBox(width: 15),
          
          // Detail Informasi Dokter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        doctor.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    // Indikator Status (Titik Warna)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: doctor.statusColor, shape: BoxShape.circle),
                    ),
                  ],
                ),
                Text(doctor.specialty, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Kotak Jam Praktek
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        doctor.time, 
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Label Status Ketersediaan
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: doctor.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            doctor.status == "Tersedia" ? Icons.check_circle : Icons.access_time,
                            size: 14, 
                            color: doctor.statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doctor.status, 
                            style: TextStyle(
                              color: doctor.statusColor, 
                              fontSize: 11, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
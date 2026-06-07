# GiliranKu Mobile - RSUD Porsea
Aplikasi mobile untuk pasien Rumah Sakit Umum Daerah (RSUD) Porsea. Aplikasi ini dirancang untuk memberikan kemudahan bagi pasien dalam mereservasi antrean dari rumah, memantau riwayat medis, serta mendapatkan pengingat jadwal kontrol.

## Panduan Instalasi (Production)
Aplikasi ini ditujukan untuk digunakan secara luas oleh pasien RSUD Porsea.
1. Unduh aplikasi **GiliranKu Mobile** versi rilis terbaru (`.apk` untuk Android).
2. Instal aplikasi di *smartphone* Anda (pastikan mengizinkan instalasi dari sumber tidak dikenal jika mengunduh di luar Play Store).
3. Pastikan perangkat Anda terhubung ke internet. Aplikasi akan otomatis tersinkronisasi dengan server produksi rumah sakit secara *real-time*.
4. Lakukan Pendaftaran atau Login menggunakan NIK untuk mulai menggunakan aplikasi.

## Daftar Fitur & Fungsionalitas Utama
- **Pendaftaran Antrean Online (Pasien Umum)**: Ambil nomor antrean poliklinik dari rumah tangga tanpa perlu antre fisik di lobi.
- **Manajemen Akun Terintegrasi**: Login aman menggunakan NIK yang divalidasi dengan data Rumah Sakit.
- **Pengingat Kontrol Rutin Cerdas**: Sistem notifikasi otomatis pada perangkat (H-7, H-3, H-1, dan 1 Jam sebelum jadwal) agar pasien tidak melewatkan jadwal kontrol.
- **Riwayat Antrean & Tiket Digital**: Simpan riwayat kunjungan dengan aman dan unduh karcis antrean dalam format PDF *paperless*.
- **Papan Informasi Real-time**: Cek status jam kerja operasional Buka/Tutup Rumah Sakit dan dokter jaga secara aktual.

## Catatan Pengembangan Lanjutan
- **Integrasi Pendaftaran BPJS**: Antarmuka antrean untuk pasien BPJS telah dikembangkan, namun saat ini berstatus *Upcoming Feature* (menunggu rilis Data API Key resmi dan integrasi SimRS BPJS dari pihak rumah sakit) dan akan segera dikembangkan secara lanjut setelah api key didapatkan dan sinkronisasi data BPJS selesai.
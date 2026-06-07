# GiliranKu Kiosk - RSUD Porsea
Aplikasi Kiosk mandiri untuk Rumah Sakit Umum Daerah (RSUD) Porsea yang memungkinkan pasien mengambil dan mencetak karcis antrean secara langsung di lokasi rumah sakit.

## Panduan Instalasi (Production)
Aplikasi ini ditujukan untuk dipasang pada mesin Kiosk/Tablet di lobi Rumah Sakit.
1. Siapkan mesin Kiosk (Windows/Android) yang terhubung dengan printer *thermal* dan koneksi internet stabil.
2. Unduh *installer* atau file *release* aplikasi (`.exe` untuk Windows atau `.apk` untuk Android).
3. Jalankan proses instalasi pada perangkat Kiosk hingga selesai.
4. Buka aplikasi **GiliranKu Kiosk**. Aplikasi akan otomatis terhubung ke *server* produksi rumah sakit.

## Daftar Fitur Utama
- **Pengambilan Antrean Mandiri**: Pasien Umum dapat memilih poliklinik dan melihat jadwal dokter yang tersedia hari ini.
- **Pencetakan Tiket Fisik**: Otomatis menghasilkan dan mencetak struk antrean (PDF) ke printer kiosk.
- **Informasi Real-time**: Menampilkan ketersediaan jam operasional, kuota antrean, dan status poliklinik secara langsung terhubung dengan sistem pusat.

## Catatan Pengembangan Lanjutan
- **Integrasi Antrean BPJS**: Modul antrean untuk pasien BPJS sudah dipersiapkan, namun saat ini berstatus *Upcoming Feature* (menunggu rilis Data API Key resmi dan bridging dengan sistem V-Claim BPJS dari pihak rumah sakit).
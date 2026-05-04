class Service {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color; // hex color code
  final String hoverColor;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.hoverColor,
  });

  factory Service.consultation() {
    return Service(
      id: 'consultation',
      name: 'Antrian Konsultasi',
      description: 'Klik untuk mendaftarkan diri anda dan mengambil nomor antrian',
      icon: 'fas fa-stethoscope',
      color: '#5FA092',
      hoverColor: '#4D8E7E',
    );
  }

  factory Service.pharmacy() {
    return Service(
      id: 'pharmacy',
      name: 'Antrian Farmasi',
      description: 'Klik untuk mengambil nomor antrian menuju farmasi',
      icon: 'fas fa-pills',
      color: '#8CC63F',
      hoverColor: '#7AB52E',
    );
  }

  factory Service.qrCode() {
    return Service(
      id: 'qrcode',
      name: 'Cetak Kertas Antrian melalui',
      description: 'kode antrian (smartphone)',
      icon: 'fas fa-qrcode',
      color: '#0066CC',
      hoverColor: '#0052A3',
    );
  }
}

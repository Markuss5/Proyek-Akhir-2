-- Giliranku Database Schema (PostgreSQL)
CREATE TABLE Profil_Rumah_Sakit (
    hospitalID SERIAL PRIMARY KEY,
    hospitalName VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    visionMission TEXT,
    operationalHours VARCHAR(50)
);

CREATE TABLE Poliklinik (
    polyID SERIAL PRIMARY KEY,
    polyName VARCHAR(30) NOT NULL,
    description TEXT,
    isActive BOOLEAN DEFAULT true
);

CREATE TABLE Laporan_Kunjungan (
    reportID SERIAL PRIMARY KEY,
    period VARCHAR(20) NOT NULL,
    totalVisits INTEGER DEFAULT 0,
    polyID INTEGER REFERENCES Poliklinik(polyID) ON DELETE CASCADE
);

CREATE TABLE Jadwal_Dokter (
    scheduleID SERIAL PRIMARY KEY,
    day VARCHAR(20) NOT NULL,
    startTime TIME NOT NULL,
    endTime TIME NOT NULL
);

CREATE TABLE Dokter (
    doctorID SERIAL PRIMARY KEY,
    doctorName VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    status BOOLEAN DEFAULT true,
    polyID INTEGER REFERENCES Poliklinik(polyID) ON DELETE SET NULL,
    scheduleID INTEGER REFERENCES Jadwal_Dokter(scheduleID) ON DELETE SET NULL
);

CREATE TABLE Pasien (
    NIK VARCHAR(16) PRIMARY KEY,
    noRM VARCHAR(20),
    patientName VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(50)
);

CREATE TABLE Kontrol_Rutin (
    controlID SERIAL PRIMARY KEY,
    controlDate DATE NOT NULL,
    notes TEXT,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    NIK VARCHAR(16) REFERENCES Pasien(NIK) ON DELETE CASCADE
);

CREATE TABLE Kode_Booking (
    codeID SERIAL PRIMARY KEY,
    bookingCode VARCHAR(20) UNIQUE NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Tiket_Apotek (
    queueNumber SERIAL PRIMARY KEY,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Tiket_Antrian (
    ticketID SERIAL PRIMARY KEY,
    polyNumber VARCHAR(20) NOT NULL,
    queueNumber INTEGER NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    codeID INTEGER REFERENCES Kode_Booking(codeID) ON DELETE SET NULL,
    polyID INTEGER REFERENCES Poliklinik(polyID) ON DELETE CASCADE,
    doctorID INTEGER REFERENCES Dokter(doctorID) ON DELETE SET NULL,
    NIK VARCHAR(16) REFERENCES Pasien(NIK) ON DELETE CASCADE
);

CREATE TABLE Notifikasi (
    notificationID SERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    scheduledDate DATE,
    isSent BOOLEAN DEFAULT false,
    sentAt TIMESTAMP,
    NIK VARCHAR(16) REFERENCES Pasien(NIK) ON DELETE CASCADE
);
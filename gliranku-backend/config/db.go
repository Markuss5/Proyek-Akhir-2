package config

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"

	_ "github.com/lib/pq"
)

func ConnectDB() *sql.DB {
	host := GetEnv("DB_HOST", "localhost")
	port := GetEnv("DB_PORT", "5432")
	user := GetEnv("DB_USER", "postgres")
	password := GetEnv("DB_PASSWORD", "postgres")
	dbname := GetEnv("DB_NAME", "giliranku")
	sslmode := GetEnv("DB_SSLMODE", "disable")

	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		host, port, user, password, dbname, sslmode,
	)

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Fatalf("Failed to open database connection: %v", err)
	}

	err = db.Ping()
	if err != nil {
		log.Fatalf("Failed to ping database: %v", err)
	}

	log.Println("Database connected successfully")

	// Jalankan migrasi otomatis
	runMigrations(db)

	return db
}

func runMigrations(db *sql.DB) {
	migrationsDir := "database/migrations"
	
	files, err := os.ReadDir(migrationsDir)
	if err != nil {
		log.Printf("Skipping migrations: could not read directory %s: %v", migrationsDir, err)
		return
	}

	var upFiles []string
	for _, file := range files {
		if !file.IsDir() && strings.HasSuffix(file.Name(), ".up.sql") {
			upFiles = append(upFiles, file.Name())
		}
	}

	// Pastikan urutannya benar (000001, 000002, dst)
	sort.Strings(upFiles)

	for _, fileName := range upFiles {
		filePath := filepath.Join(migrationsDir, fileName)
		content, err := os.ReadFile(filePath)
		if err != nil {
			log.Printf("Failed to read migration file %s: %v", fileName, err)
			continue
		}

		sqlQuery := string(content)
		if strings.TrimSpace(sqlQuery) == "" {
			continue
		}

		log.Printf("Executing migration: %s", fileName)
		_, err = db.Exec(sqlQuery)
		if err != nil {
			log.Printf("Warning executing %s (might already exist): %v", fileName, err)
		} else {
			log.Printf("Success executing: %s", fileName)
		}
	}

	// Tambahan kolom jika diperlukan (dari kode sebelumnya)
	_, _ = db.Exec(`ALTER TABLE antrian ADD COLUMN IF NOT EXISTS source VARCHAR(50) DEFAULT 'smartphone';`)
	_, _ = db.Exec(`ALTER TABLE antrian ADD COLUMN IF NOT EXISTS no_rm VARCHAR(50) DEFAULT '-';`)
}
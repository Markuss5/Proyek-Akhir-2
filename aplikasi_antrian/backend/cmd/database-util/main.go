package main

import (
	"flag"
	"log"
	"os"

	"github.com/joho/godotenv"

	"aplikasi_antrian/backend/internal/database"
)

func main() {
	// Load .env file
	_ = godotenv.Load()

	// Define flags
	resetFlag := flag.Bool("reset", false, "Reset database (drop tables and reseed)")
	validateFlag := flag.Bool("validate", false, "Validate database integrity and show all data")
	flag.Parse()

	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		databaseURL = "postgres://postgres:postgres@localhost:5432/aplikasi_antrian?sslmode=disable"
	}

	log.Printf("Connecting to database: %s", databaseURL)

	db, err := database.OpenDatabase(databaseURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	if *resetFlag {
		log.Println("=== DATABASE RESET MODE ===")
		if err := database.ResetDatabase(db); err != nil {
			log.Fatalf("Reset failed: %v", err)
		}
		log.Println("✅ Database reset completed successfully!")
		log.Println("You can now run the server with: go run ./cmd/server")
	} else if *validateFlag {
		log.Println("=== DATABASE VALIDATION MODE ===")
		if err := database.ValidateDatabaseIntegrity(db); err != nil {
			log.Fatalf("Validation failed: %v", err)
		}
		log.Println("✅ Database validation completed!")
	} else {
		log.Println("Usage:")
		log.Println("  go run ./cmd/database-util -reset       (Reset database)")
		log.Println("  go run ./cmd/database-util -validate    (Check database integrity)")
	}
}

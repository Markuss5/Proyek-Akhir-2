package main

import (
	"log"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"

	"aplikasi_antrian/backend/internal/database"
	"aplikasi_antrian/backend/internal/repository"
	"aplikasi_antrian/backend/internal/service"
	"aplikasi_antrian/backend/internal/transport/httpapi"
)

func main() {
	// Load .env file (ignore error if file not found)
	_ = godotenv.Load()

	apiAddr := envOrDefault("API_ADDR", ":8081")
	databaseURL := envOrDefault(
		"DATABASE_URL",
		"postgres://postgres:postgres@localhost:5432/aplikasi_antrian?sslmode=disable",
	)

	db, err := database.OpenDatabase(databaseURL)
	if err != nil {
		log.Fatalf("database init failed: %v", err)
	}
	defer db.Close()

	repo := repository.NewValidationRepository(db)
	validationService := service.NewValidationService(repo)
	handler := httpapi.NewHandler(validationService)

	mux := http.NewServeMux()
	handler.RegisterRoutes(mux)

	server := &http.Server{
		Addr:         apiAddr,
		Handler:      requestLogger(mux),
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  30 * time.Second,
	}

	log.Printf("API server running on %s", apiAddr)
	log.Printf("Health check: http://localhost%s/health", apiAddr)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("server stopped: %v", err)
	}
}

func envOrDefault(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}
	return value
}

func requestLogger(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		log.Printf("%s %s %s", r.Method, r.URL.Path, time.Since(start))
	})
}

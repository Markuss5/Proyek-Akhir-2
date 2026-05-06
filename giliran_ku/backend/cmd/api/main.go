package main

import (
	"log"
	"net/http"

	"giliran_ku_backend/config"
	"giliran_ku_backend/handlers"
	"giliran_ku_backend/repo"
	"giliran_ku_backend/routes"
	"giliran_ku_backend/services"
)

func main() {
	cfg := config.Load()

	db, err := repo.NewDB(cfg)
	if err != nil {
		log.Fatalf("gagal konek database: %v", err)
	}
	defer db.Close()

	repository := repo.NewRepository(db)
	service := services.NewQueueService(repository)
	appHandlers := handlers.NewAppHandlers(service, cfg.PdfOutputDir)
	router := routes.NewRouter(appHandlers)

	address := ":" + cfg.ServerPort
	log.Printf("API berjalan di %s", address)

	if err := http.ListenAndServe(address, router); err != nil {
		log.Fatalf("server error: %v", err)
	}
}

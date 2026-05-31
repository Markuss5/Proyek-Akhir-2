package main

import (
	"log"
	"net/http"
	"time"
	_ "time/tzdata"

	"gliranku/config"
	"gliranku/controller"
	"gliranku/repository"
	"gliranku/routes"
	"gliranku/service"

	"github.com/gin-gonic/gin"
)

func main() {
	loc, err := time.LoadLocation("Asia/Jakarta")
	if err == nil {
		time.Local = loc
	} else {
		log.Printf("Warning: Failed to load timezone Asia/Jakarta: %v", err)
	}

	config.LoadEnv()

	db := config.ConnectDB()
	defer db.Close()

	migrations := []string{
		`ALTER TABLE antrian ADD COLUMN IF NOT EXISTS no_antrian_poli VARCHAR(20)`,
		`ALTER TABLE antrian ADD COLUMN IF NOT EXISTS source VARCHAR(50) NOT NULL DEFAULT 'smartphone'`,
		`ALTER TABLE antrian ADD COLUMN IF NOT EXISTS no_rm VARCHAR(50) NOT NULL DEFAULT '-'`,
	}
	for _, stmt := range migrations {
		if _, err := db.Exec(stmt); err != nil {
			log.Printf("[migration] WARNING: %s\n  → %v\n", stmt, err)
		}
	}
	log.Println("[migration] Antrian schema check selesai.")

	antrianRepo := repository.NewAntrianRepository(db)

	antrianService := service.NewAntrianService(antrianRepo)

	antrianCtrl := controller.NewAntrianController(antrianService)
	kioskCtrl := controller.NewKioskController(antrianService)

	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(gin.Logger())
	r.SetTrustedProxies(nil)

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"service": "GiliranKu Antrian Service",
			"version": "1.0.0",
			"status":  "running",
		})
	})
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	routes.SetupAntrianRoutes(r, antrianCtrl, kioskCtrl)

	port := config.GetEnv("PORT", "8081")

	srv := &http.Server{
		Addr:         ":" + port,
		Handler:      r,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 60 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	log.Printf("[antrian-service] Running on port %s", port)
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("[antrian-service] Server error: %v", err)
	}
}
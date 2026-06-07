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

	log.Println("[migration] Master schema check selesai.")

	poliRepo := repository.NewPoliRepository(db)
	dokterRepo := repository.NewDokterRepository(db)
	informasiRepo := repository.NewInformasiRepository(db)
	spesialisRepo := repository.NewSpesialisRepository(db)

	poliService := service.NewPoliService(poliRepo)
	dokterService := service.NewDokterService(dokterRepo)
	informasiService := service.NewInformasiService(informasiRepo)
	spesialisService := service.NewSpesialisService(spesialisRepo)

	poliCtrl := controller.NewPoliController(poliRepo, poliService)
	dokterCtrl := controller.NewDokterController(dokterRepo, dokterService)
	informasiCtrl := controller.NewInformasiController(informasiService)
	spesialisCtrl := controller.NewSpesialisController(spesialisService)

	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(gin.Logger())
	r.SetTrustedProxies(nil)

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"service": "GiliranKu Master Service",
			"version": "1.0.0",
			"status":  "running",
		})
	})
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	routes.SetupMasterRoutes(r, poliCtrl, dokterCtrl, informasiCtrl, spesialisCtrl)

	port := config.GetEnv("PORT", "8083")

	srv := &http.Server{
		Addr:         ":" + port,
		Handler:      r,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 60 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	log.Printf("[master-service] Running on port %s", port)
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("[master-service] Server error: %v", err)
	}
}
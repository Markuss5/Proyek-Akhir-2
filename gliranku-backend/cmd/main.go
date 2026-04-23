package main

import (
	"gliranku/config"
	"gliranku/controller"
	"gliranku/repository"
	"gliranku/routes"
	"gliranku/service"

	"github.com/gin-gonic/gin"
)

func main() {
	// Load environment variables
	config.LoadEnv()

	// Connect to database
	db := config.ConnectDB()
	defer db.Close()

	// Initialize repositories
	pasienRepo := repository.NewPasienRepository(db)
	kontrolRutinRepo := repository.NewKontrolRutinRepository(db)
	notifikasiRepo := repository.NewNotifikasiRepository(db)
	poliRepo := repository.NewPoliRepository(db)
	dokterRepo := repository.NewDokterRepository(db)
	antrianRepo := repository.NewAntrianRepository(db) 

	// Initialize services
	pasienService := service.NewPasienService(pasienRepo)
	kontrolRutinService := service.NewKontrolRutinService(kontrolRutinRepo, notifikasiRepo, pasienRepo)
	notifikasiService := service.NewNotifikasiService(notifikasiRepo, pasienRepo)
	antrianService := service.NewAntrianService(antrianRepo) 

	// Initialize controllers
	pasienCtrl := controller.NewPasienController(pasienService)
	kontrolRutinCtrl := controller.NewKontrolRutinController(kontrolRutinService)
	notifikasiCtrl := controller.NewNotifikasiController(notifikasiService)
	poliCtrl := controller.NewPoliController(poliRepo)
	dokterCtrl := controller.NewDokterController(dokterRepo)
	antrianCtrl := controller.NewAntrianController(antrianService) 

	// Setup Gin router
	r := gin.Default()
	r.SetTrustedProxies(nil)

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "GiliranKu Backend API"})
	})

	// Register routes
	routes.SetupRoutes(r, kontrolRutinCtrl, notifikasiCtrl, poliCtrl, dokterCtrl, pasienCtrl, antrianCtrl)

	// Start server
	port := config.GetEnv("PORT", "8080")
	r.Run(":" + port)
}
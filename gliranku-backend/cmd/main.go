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

	// Initialize services
	kontrolRutinService := service.NewKontrolRutinService(kontrolRutinRepo, notifikasiRepo, pasienRepo)
	notifikasiService := service.NewNotifikasiService(notifikasiRepo, pasienRepo)

	// Initialize controllers
	kontrolRutinCtrl := controller.NewKontrolRutinController(kontrolRutinService)
	notifikasiCtrl := controller.NewNotifikasiController(notifikasiService)

	// Setup Gin router
	r := gin.Default()
	r.SetTrustedProxies(nil)

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "GiliranKu Backend API",
		})
	})

	// Register routes
	routes.SetupRoutes(r, kontrolRutinCtrl, notifikasiCtrl)

	// Start server
	port := config.GetEnv("PORT", "8080")
	r.Run(":" + port)
}
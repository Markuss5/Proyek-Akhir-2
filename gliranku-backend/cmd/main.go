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
	config.LoadEnv()

	db := config.ConnectDB()
	defer db.Close()

	pasienRepo := repository.NewPasienRepository(db)
	kontrolRutinRepo := repository.NewKontrolRutinRepository(db)
	notifikasiRepo := repository.NewNotifikasiRepository(db)
	poliRepo := repository.NewPoliRepository(db)
	dokterRepo := repository.NewDokterRepository(db)
	informasiRepo := repository.NewInformasiRepository(db)
	antrianRepo := repository.NewAntrianRepository(db)

	pasienService := service.NewPasienService(pasienRepo)
	kontrolRutinService := service.NewKontrolRutinService(kontrolRutinRepo, notifikasiRepo, pasienRepo)
	notifikasiService := service.NewNotifikasiService(notifikasiRepo, pasienRepo)
	poliService := service.NewPoliService(poliRepo)
	dokterService := service.NewDokterService(dokterRepo)
	informasiService := service.NewInformasiService(informasiRepo)
	antrianService := service.NewAntrianService(antrianRepo)

	pasienCtrl := controller.NewPasienController(pasienService)
	kontrolRutinCtrl := controller.NewKontrolRutinController(kontrolRutinService)
	notifikasiCtrl := controller.NewNotifikasiController(notifikasiService)
	poliCtrl := controller.NewPoliController(poliRepo, poliService)
	dokterCtrl := controller.NewDokterController(dokterRepo, dokterService)
	informasiCtrl := controller.NewInformasiController(informasiService)
	antrianCtrl := controller.NewAntrianController(antrianService)
	kioskCtrl := controller.NewKioskController(antrianService)

	r := gin.Default()
	r.SetTrustedProxies(nil)

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{"message": "GiliranKu Backend API"})
	})

	routes.SetupRoutes(r, kontrolRutinCtrl, notifikasiCtrl, poliCtrl, dokterCtrl, pasienCtrl, informasiCtrl, antrianCtrl, kioskCtrl)

	port := config.GetEnv("PORT", "8080")
	r.Run(":" + port)
}
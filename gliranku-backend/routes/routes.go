package routes

import (
	"gliranku/controller"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(
	r *gin.Engine,
	kontrolRutinCtrl *controller.KontrolRutinController,
	notifikasiCtrl *controller.NotifikasiController,
) {
	api := r.Group("/api/v1")

	// Kontrol Rutin routes
	kontrolRutin := api.Group("/kontrol-rutin")
	{
		kontrolRutin.POST("", kontrolRutinCtrl.Create)
		kontrolRutin.GET("/pasien/:nik", kontrolRutinCtrl.GetByNIK)
		kontrolRutin.GET("/upcoming", kontrolRutinCtrl.GetUpcoming)
	}

	// Notifikasi routes
	notifikasi := api.Group("/notifikasi")
	{
		notifikasi.POST("", notifikasiCtrl.Create)
		notifikasi.GET("/pasien/:nik", notifikasiCtrl.GetByNIK)
		notifikasi.GET("/pending", notifikasiCtrl.GetPending)
		notifikasi.PUT("/:id/mark-sent", notifikasiCtrl.MarkAsSent)
		notifikasi.POST("/process", notifikasiCtrl.ProcessPending)
	}
}

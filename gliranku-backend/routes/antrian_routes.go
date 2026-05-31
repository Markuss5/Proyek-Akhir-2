package routes

import (
	"gliranku/controller"
	"gliranku/middleware"

	"github.com/gin-gonic/gin"
)

func SetupAntrianRoutes(r *gin.Engine, antrianCtrl *controller.AntrianController, kioskCtrl controller.KioskController) {
	r.Use(middleware.SecurityHeaders())
	r.Use(middleware.CORS())
	r.Use(middleware.RequestSizeLimit(4 * 1024 * 1024))
	r.Use(middleware.RateLimit())

	api := r.Group("/api/v1")

	api.POST("/tickets/pdf", kioskCtrl.UploadPDF)

	antrian := api.Group("/antrian")
	{
		antrian.GET("/layanan", antrianCtrl.GetLayanan)
		antrian.GET("/dashboard-stats", antrianCtrl.GetDashboardStats)
		antrian.GET("/kunjungan-stats", antrianCtrl.GetKunjunganStats)
		antrian.POST("/cek-nik", antrianCtrl.CekNIK)
		antrian.POST("/bpjs", middleware.StrictRateLimit(), antrianCtrl.CreateBpjsAntrian)
		antrian.GET("/bpjs/rujukan/:nik", middleware.RequireAuth(), middleware.RequirePatientOwnership(), antrianCtrl.GetRujukanBPJS)
		antrian.POST("", middleware.StrictRateLimit(), antrianCtrl.CreateAntrian)
		antrian.GET("/riwayat/:nik", middleware.RequireAuth(), middleware.RequirePatientOwnership(), antrianCtrl.GetRiwayat)
		antrian.DELETE("/:kode_booking", antrianCtrl.DeleteAntrian)
	}

	kiosk := api.Group("/kiosk")
	{
		kiosk.POST("/farmasi", kioskCtrl.CreatePharmacyTicket)
		kiosk.GET("/booking/:code", kioskCtrl.GetBooking)
		kiosk.POST("/pdf", kioskCtrl.UploadPDF)
		kiosk.POST("/bpjs", kioskCtrl.CreateBpjsTicket)
	}
}
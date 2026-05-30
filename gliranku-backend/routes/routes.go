package routes

import (
	"gliranku/controller"
	"gliranku/middleware"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(
	r *gin.Engine,
	kontrolRutinCtrl *controller.KontrolRutinController,
	notifikasiCtrl *controller.NotifikasiController,
	poliCtrl *controller.PoliController,
	dokterCtrl *controller.DokterController,
	pasienCtrl *controller.PasienController,
	informasiCtrl *controller.InformasiController,
	antrianCtrl *controller.AntrianController,
	kioskCtrl controller.KioskController,
) {
	r.Use(middleware.SecurityHeaders())
	r.Use(middleware.CORS())
	r.Use(middleware.RequestSizeLimit(4 * 1024 * 1024))
	r.Use(middleware.RateLimit())

	api := r.Group("/api/v1")

	api.POST("/tickets/pdf", kioskCtrl.UploadPDF)

	pasien := api.Group("/pasien")
	{
		pasien.POST("/login", middleware.StrictRateLimit(), pasienCtrl.Login)
		pasien.GET("/profile/:nik", pasienCtrl.GetProfile)
		pasien.PUT("/profile", pasienCtrl.UpdateProfile)
	}

	informasi := api.Group("/informasi")
	{
		informasi.GET("", informasiCtrl.Get)
		informasi.PUT("", informasiCtrl.Update)
	}

	poliklinik := api.Group("/poliklinik")
	{
		poliklinik.GET("", poliCtrl.GetAll)
		poliklinik.POST("", poliCtrl.Create)
		poliklinik.PUT("/:id", poliCtrl.Update)
		poliklinik.DELETE("/:id", poliCtrl.Delete)
	}

	dokter := api.Group("/dokter")
	{
		dokter.GET("", dokterCtrl.GetByPoly)
		dokter.GET("/poli/:poly_id", dokterCtrl.GetByPoly)
		dokter.POST("", dokterCtrl.Create)
		dokter.PUT("/:id", dokterCtrl.Update)
		dokter.DELETE("/:id", dokterCtrl.Delete)
	}

	kontrolRutin := api.Group("/kontrol-rutin")
	{
		kontrolRutin.POST("", kontrolRutinCtrl.Create)
		kontrolRutin.GET("/all", kontrolRutinCtrl.GetAll)
		kontrolRutin.GET("/pasien/:nik", kontrolRutinCtrl.GetByNIK)
		kontrolRutin.GET("/upcoming", kontrolRutinCtrl.GetUpcoming)
		kontrolRutin.DELETE("/:id", kontrolRutinCtrl.Delete)
	}

	notifikasi := api.Group("/notifikasi")
	{
		notifikasi.POST("", notifikasiCtrl.Create)
		notifikasi.GET("/pasien/:nik", notifikasiCtrl.GetByNIK)
		notifikasi.GET("/pending", notifikasiCtrl.GetPending)
		notifikasi.PUT("/:id/mark-sent", notifikasiCtrl.MarkAsSent)
		notifikasi.POST("/process", notifikasiCtrl.ProcessPending)
		notifikasi.DELETE("/:id", notifikasiCtrl.Delete)
	}

	antrian := api.Group("/antrian")
	{
		antrian.GET("/layanan", antrianCtrl.GetLayanan)
		antrian.GET("/dashboard-stats", antrianCtrl.GetDashboardStats)
		antrian.GET("/kunjungan-stats", antrianCtrl.GetKunjunganStats)
		antrian.POST("/cek-nik", antrianCtrl.CekNIK)
		// Booking antrian diberi rate limit ketat: maks 5 per 10 detik per IP
		antrian.POST("/bpjs", middleware.StrictRateLimit(), antrianCtrl.CreateBpjsAntrian)
		antrian.GET("/bpjs/rujukan/:nik", antrianCtrl.GetRujukanBPJS)
		antrian.POST("", middleware.StrictRateLimit(), antrianCtrl.CreateAntrian)
		antrian.GET("/riwayat/:nik", antrianCtrl.GetRiwayat)
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

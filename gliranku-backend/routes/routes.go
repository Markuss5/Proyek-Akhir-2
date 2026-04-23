package routes

import (
	"gliranku/controller"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(
	r *gin.Engine,
	kontrolRutinCtrl *controller.KontrolRutinController,
	notifikasiCtrl *controller.NotifikasiController,
	poliCtrl *controller.PoliController,
	dokterCtrl *controller.DokterController,
	pasienCtrl *controller.PasienController,
	antrianCtrl *controller.AntrianController, 
) {
	api := r.Group("/api/v1")

	// Pasien routes
	pasien := api.Group("/pasien")
	{
		pasien.POST("/login", pasienCtrl.Login)
		pasien.GET("/profile/:nik", pasienCtrl.GetProfile)
		pasien.PUT("/profile", pasienCtrl.UpdateProfile)
	}

	// Poliklinik routes
	api.GET("/poliklinik", poliCtrl.GetAll)

	// Dokter routes
	api.GET("/dokter", dokterCtrl.GetByPoly)

	// Kontrol Rutin routes
	kontrolRutin := api.Group("/kontrol-rutin")
	{
		kontrolRutin.POST("", kontrolRutinCtrl.Create)
		kontrolRutin.GET("/all", kontrolRutinCtrl.GetAll)
		kontrolRutin.GET("/pasien/:nik", kontrolRutinCtrl.GetByNIK)
		kontrolRutin.GET("/upcoming", kontrolRutinCtrl.GetUpcoming)
		kontrolRutin.DELETE("/:id", kontrolRutinCtrl.Delete)
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

	// GET  /api/v1/antrian/layanan  → tampilkan jenis layanan
	// POST /api/v1/antrian/cek-nik  → verifikasi NIK pasien lama
	// POST /api/v1/antrian          → buat antrian baru
	antrian := api.Group("/antrian")
	{
		antrian.GET("/layanan", antrianCtrl.GetLayanan)
		antrian.POST("/cek-nik", antrianCtrl.CekNIK)
		antrian.POST("", antrianCtrl.CreateAntrian)
	}
}
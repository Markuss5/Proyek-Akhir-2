package routes

import (
	"gliranku/controller"
	"gliranku/middleware"

	"github.com/gin-gonic/gin"
)

func SetupMasterRoutes(r *gin.Engine, poliCtrl *controller.PoliController, dokterCtrl *controller.DokterController, informasiCtrl *controller.InformasiController) {
	r.Use(middleware.SecurityHeaders())
	r.Use(middleware.CORS())
	r.Use(middleware.RequestSizeLimit(4 * 1024 * 1024))
	r.Use(middleware.RateLimit())

	api := r.Group("/api/v1")

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
}
package main

import (
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	// FIX WARNING proxy
	r.SetTrustedProxies(nil)

	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "Backend jalan",
		})
	})

	r.Run(":8080")
}
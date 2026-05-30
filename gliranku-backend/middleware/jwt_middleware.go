package middleware

import (
	"gliranku/utils"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

func RequireAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			utils.Error(c, http.StatusUnauthorized, "Authorization header is missing")
			c.Abort()
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			utils.Error(c, http.StatusUnauthorized, "Authorization header format must be Bearer {token}")
			c.Abort()
			return
		}

		tokenString := parts[1]
		claims, err := utils.ValidateToken(tokenString)
		if err != nil {
			utils.Error(c, http.StatusUnauthorized, "Invalid or expired token: "+err.Error())
			c.Abort()
			return
		}

		c.Set("nik", claims.NIK)
		c.Next()
	}
}

func RequirePatientOwnership() gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenNIK, exists := c.Get("nik")
		if !exists {
			utils.Error(c, http.StatusUnauthorized, "Unauthorized: NIK not found in context")
			c.Abort()
			return
		}

		paramNIK := c.Param("nik")
		if paramNIK == "" {
			c.Next()
			return
		}

		if tokenNIK.(string) != paramNIK {
			utils.Error(c, http.StatusForbidden, "Forbidden: Anda tidak diizinkan mengakses data pasien lain (IDOR Protection Active)")
			c.Abort()
			return
		}

		c.Next()
	}
}
package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/time/rate"
)

type ipLimiter struct {
	limiter  *rate.Limiter
	lastSeen time.Time
}

var (
	mu       sync.Mutex
	limiters = make(map[string]*ipLimiter)
)

func init() {
	go func() {
		for {
			time.Sleep(5 * time.Minute)
			mu.Lock()
			for ip, l := range limiters {
				if time.Since(l.lastSeen) > 5*time.Minute {
					delete(limiters, ip)
				}
			}
			mu.Unlock()
		}
	}()
}

func getLimiter(ip string) *rate.Limiter {
	mu.Lock()
	defer mu.Unlock()

	if l, exists := limiters[ip]; exists {
		l.lastSeen = time.Now()
		return l.limiter
	}

	l := &ipLimiter{
		limiter:  rate.NewLimiter(rate.Every(time.Second), 60),
		lastSeen: time.Now(),
	}
	limiters[ip] = l
	return l.limiter
}

func RateLimit() gin.HandlerFunc {
	return func(c *gin.Context) {
		ip := c.ClientIP()
		limiter := getLimiter(ip)

		if !limiter.Allow() {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"status":  429,
				"message": "Terlalu banyak permintaan. Harap tunggu sebentar.",
			})
			return
		}

		c.Next()
	}
}

func StrictRateLimit() gin.HandlerFunc {
	strictLimiters := make(map[string]*ipLimiter)
	var mu2 sync.Mutex

	return func(c *gin.Context) {
		ip := c.ClientIP()

		mu2.Lock()
		if _, exists := strictLimiters[ip]; !exists {
			strictLimiters[ip] = &ipLimiter{
				limiter:  rate.NewLimiter(rate.Every(10*time.Second), 5),
				lastSeen: time.Now(),
			}
		}
		l := strictLimiters[ip]
		l.lastSeen = time.Now()
		lim := l.limiter
		mu2.Unlock()

		if !lim.Allow() {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"status":  429,
				"message": "Terlalu banyak percobaan. Harap tunggu 10 detik.",
			})
			return
		}

		c.Next()
	}
}
# ============================================================
# GiliranKu Backend — Multi-Service Dockerfile
# ============================================================
# Build a specific service by passing --build-arg:
#   docker build --build-arg SERVICE_NAME=antrian-service .
#   docker build --build-arg SERVICE_NAME=pasien-service  .
#   docker build --build-arg SERVICE_NAME=master-service  .
# ============================================================

# Build stage
FROM golang:alpine AS builder
WORKDIR /app

# Accept the service name as a build argument (required)
ARG SERVICE_NAME
RUN test -n "$SERVICE_NAME" || (echo "ERROR: SERVICE_NAME build arg is required" && exit 1)

# Download dependencies first (cached layer)
COPY go.mod go.sum ./
RUN go mod download

# Copy full source and build the specified service
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/${SERVICE_NAME}/main.go

# ── Run stage ───────────────────────────────────────────────
FROM alpine:latest
WORKDIR /app

# Add timezone data for Asia/Jakarta support
RUN apk --no-cache add tzdata ca-certificates

COPY --from=builder /app/main .
COPY --from=builder /app/database ./database

EXPOSE 8080
CMD ["./main"]

# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS builder

# Set working directory
WORKDIR /app

# Copy the Flutter project
COPY five_to_one_mobile/ ./five_to_one_mobile/

# Navigate to Flutter project directory
WORKDIR /app/five_to_one_mobile

# Get Flutter dependencies
RUN flutter pub get

# Enable Flutter web
RUN flutter config --enable-web

# Accept build arguments for Supabase and Canny configuration
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG CANNY_SUBDOMAIN
ARG CANNY_BOARD_TOKEN
ARG CANNY_APP_ID

# Build for web with environment variables
RUN flutter build web --release --web-renderer canvaskit \
  --dart-define=SUPABASE_URL=${SUPABASE_URL} \
  --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
  --dart-define=CANNY_SUBDOMAIN=${CANNY_SUBDOMAIN} \
  --dart-define=CANNY_BOARD_TOKEN=${CANNY_BOARD_TOKEN} \
  --dart-define=CANNY_APP_ID=${CANNY_APP_ID}

# Stage 2: Serve the app using Python
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy built web app from builder
COPY --from=builder /app/five_to_one_mobile/build/web ./web

# Expose port
EXPOSE 8080

# Start simple HTTP server
CMD ["python", "-m", "http.server", "8080", "-d", "web"]

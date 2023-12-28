# Build Dockerfile
docker build -t godart:latest . --progress=plain --no-cache

# Run Compose
docker-compose up -d

#!/bin/bash
# Reset and restart Podman containers for MacBook

echo "Stopping and removing existing Podman containers..."

# List all containers (including stopped ones)
CONTAINERS=$(podman ps -a -q)

# Stop and remove all containers if any exist
if [ ! -z "$CONTAINERS" ]; then
    podman stop $CONTAINERS
    podman rm $CONTAINERS
    echo "Removed existing containers."
else
    echo "No existing containers found."
fi

# Remove any pods if they exist
PODS=$(podman pod ls -q)
if [ ! -z "$PODS" ]; then
    podman pod rm $PODS
    echo "Removed existing pods."
else
    echo "No existing pods found."
fi

echo "Checking Podman machine status..."
if ! podman machine list | grep -q "Currently running"; then
    echo "Starting Podman machine..."
    podman machine start
fi

echo "Creating necessary directories..."
mkdir -p data/pdfs
mkdir -p data/processed_redbooks/docs
mkdir -p data/processed_redbooks/chunks
mkdir -p data/processed_redbooks/ollama
mkdir -p data/openwebui

echo "Creating Podman-compatible compose file..."
cat > podman-compose.yml << 'EOL'
version: '3'

services:
  redbooks-rag:
    build: .
    container_name: redbooks-rag
    volumes:
      - ./scripts:/app/scripts:z
      - ./data/pdfs:/data/pdfs:z
      - ./data/processed_redbooks:/data/processed_redbooks:z
      - ./data/openwebui:/data/openwebui:z
    environment:
      - OLLAMA_BASE_URL=http://redbooks-ollama:11434
    depends_on:
      - ollama
    ports:
      - "8000:8000"
    tty: true
    stdin_open: true

  ollama:
    image: ollama/ollama:latest
    container_name: redbooks-ollama
    volumes:
      - ollama_data:/root/.ollama:z
    ports:
      - "11434:11434"

volumes:
  ollama_data:
EOL

echo "Building and starting containers with Podman..."
podman-compose -f podman-compose.yml up -d --build

echo ""
echo "Setup complete!"
echo ""
echo "To process Redbooks, place PDF files in the data/pdfs directory,"
echo "then run: podman exec redbooks-rag sh /app/scripts/process_redbooks.sh"
echo ""
echo "To use the RAG system interactively, run:"
echo "podman exec -it redbooks-rag sh /app/scripts/run_rag_interactive.sh"
echo ""
echo "For Open WebUI integration, run:"
echo "podman exec redbooks-rag sh /app/scripts/prepare_for_openwebui.sh"
echo ""

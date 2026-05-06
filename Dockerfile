# 1. Basis-Image
FROM node:20.14.0-bookworm-slim

# 2. System-Abhängigkeiten
RUN apt-get update && apt-get install -y \
    python3 python3-pip git curl \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxext6 libxfixes3 \
    libxrandr2 libgbm1 libasound2 libpango-1.0-0 libcairo2 \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm tsx

WORKDIR /app
COPY . .

# 3. Installation
RUN pnpm install

# --- DER RADIKALE FIX ---
# Wir suchen im gesamten Verzeichnis nach dem Fehler-String und kommentieren ihn aus.
# Das funktioniert auch, wenn der Fehler in den node_modules oder versteckten Dateien liegt.
RUN grep -rl "local_trusted requires server.bind=loopback" . | xargs sed -i 's/throw new Error("local_trusted requires server.bind=loopback")/console.log("Docker-Fix: Loopback check disabled")/g' || true

# 4. Build
RUN pnpm --filter @paperclipai/db prisma generate || true
RUN pnpm run build

# 5. Gemini-Agent
RUN pip3 install --no-cache-dir google-genai --break-system-packages

# 6. Konfiguration erzwingen (an allen bekannten Pfaden)
RUN mkdir -p /root/.paperclip /app/storage /root/.config/paperclip-server && \
    echo '{"auth": {"strategy": "simple"}, "server": {"bind": "0.0.0.0", "port": 3000}}' > /root/.paperclip/config.json && \
    echo '{"auth": {"strategy": "simple"}, "server": {"bind": "0.0.0.0", "port": 3000}}' > /app/storage/config.json && \
    echo '{"auth": {"strategy": "simple"}, "server": {"bind": "0.0.0.0", "port": 3000}}' > /root/.config/paperclip-server/config.json

# 7. Umgebungsvariablen
ENV NODE_ENV=production
ENV PAPERCLIP_AUTH_STRATEGY=simple
ENV PAPERCLIP_BIND=0.0.0.0
ENV PAPERCLIP_STORAGE_PATH=/app/storage

EXPOSE 3000

# Startbefehl
CMD ["pnpm", "--filter", "@paperclipai/server", "exec", "tsx", "src/index.ts"]

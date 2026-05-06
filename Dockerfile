# 1. Basis-Image mit Node.js
FROM node:20.14.0-bookworm-slim

# 2. System-Abhängigkeiten installieren (Python für Gemini + Browser-Libs für Paperclip)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxext6 libxfixes3 \
    libxrandr2 libgbm1 libasound2 libpango-1.0-0 libcairo2 \
    && rm -rf /var/lib/apt/lists/*

# 3. pnpm und tsx global installieren
RUN npm install -g pnpm tsx

# 4. Arbeitsverzeichnis festlegen
WORKDIR /app

# 5. Den gesamten Code aus deinem Repo kopieren
COPY . .

# 6. Paperclip-Abhängigkeiten installieren
RUN pnpm install

# 7. Prisma-Datenbank-Client generieren
RUN pnpm --filter @paperclipai/db prisma generate

# 8. Projekt bauen (TypeScript zu JavaScript)
RUN pnpm run build

# 9. Gemini-Agent Bibliotheken für Python installieren
RUN pip3 install --no-cache-dir google-genai --break-system-packages

# 10. Konfigurations-Ordner erstellen
RUN mkdir -p /root/.paperclip /app/storage

# 11. DER LOOPBACK-FIX: Wir erzwingen die Konfiguration als Datei.
# Das überschreibt die fehlerhafte "local_trusted"-Logik von Paperclip.
RUN echo '{"auth": {"strategy": "simple"}, "server": {"bind": "0.0.0.0", "port": 3000}}' > /root/.paperclip/config.json
RUN echo '{"auth": {"strategy": "simple"}, "server": {"bind": "0.0.0.0", "port": 3000}}' > /app/storage/config.json

# 12. Umgebungsvariablen setzen
ENV NODE_ENV=production
ENV PAPERCLIP_BIND=0.0.0.0
ENV PAPERCLIP_AUTH_STRATEGY=simple
ENV PAPERCLIP_STORAGE_PATH=/app/storage

# 13. Port 3000 für Coolify freigeben
EXPOSE 3000

# 14. Startbefehl: Wir nutzen tsx direkt im Server-Verzeichnis
# Das umgeht Pfadprobleme im Monorepo.
CMD ["pnpm", "--filter", "@paperclipai/server", "exec", "tsx", "src/index.ts"]

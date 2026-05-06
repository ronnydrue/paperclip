# 1. Basis-Image
FROM node:20.14.0-bookworm-slim

# 2. System-Abhängigkeiten
RUN apt-get update && apt-get install -y \
    python3 python3-pip git curl \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxext6 libxfixes3 \
    libxrandr2 libgbm1 libasound2 libpango-1.0-0 libcairo2 \
    && rm -rf /var/lib/apt/lists/*

# pnpm und tsx global installieren
RUN npm install -g pnpm tsx

WORKDIR /app
COPY . .

# 3. Installation & Vorbereitung
RUN pnpm install
RUN pnpm --filter @paperclipai/db prisma generate

# Wir bauen das Projekt (wichtig für Assets/Frontend)
RUN pnpm run build

# 4. Gemini-Agent
RUN pip3 install --no-cache-dir google-genai --break-system-packages

# 5. Verzeichnisse
RUN mkdir -p /app/storage
ENV PAPERCLIP_STORAGE_PATH=/app/storage

EXPOSE 3000

# --- DER FIX FÜR DEN START-FEHLER ---
# Statt 'node dist/index.js' nutzen wir 'tsx', damit die TypeScript-Referenzen 
# im Monorepo aufgelöst werden können.
CMD ["pnpm", "--filter", "@paperclipai/server", "exec", "tsx", "src/index.ts"]

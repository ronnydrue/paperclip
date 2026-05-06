FROM node:20.14.0-bookworm-slim

# System-Abhängigkeiten
RUN apt-get update && apt-get install -y \
    python3 python3-pip git curl \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxext6 libxfixes3 \
    libxrandr2 libgbm1 libasound2 libpango-1.0-0 libcairo2 \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm tsx

WORKDIR /app
COPY . .

# Installation und Build
RUN pnpm install
RUN pnpm --filter @paperclipai/db prisma generate
RUN pnpm run build

# Gemini-Agent Vorbereitung
RUN pip3 install --no-cache-dir google-genai --break-system-packages

# Umgebungsvariablen setzen
ENV NODE_ENV=production
ENV TS_NODE_TRANSPILE_ONLY=true

EXPOSE 3000

# DER TRICK: Wir starten den Server mit dem tsx-Loader, 
# damit er .ts Dateien versteht, falls die Symlinks darauf zeigen.
CMD ["tsx", "packages/server/src/index.ts"]

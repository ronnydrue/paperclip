FROM node:20.14.0-bookworm-slim

# System-Tools
RUN apt-get update && apt-get install -y python3 python3-pip git curl \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxext6 libxfixes3 \
    libxrandr2 libgbm1 libasound2 libpango-1.0-0 libcairo2 \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm

WORKDIR /app
COPY . .

RUN pnpm install
RUN pnpm --filter @paperclipai/db prisma generate
RUN pnpm run build

# Gemini-Agent
RUN pip3 install --no-cache-dir google-genai --break-system-packages

# Verzeichnisse für Daten
RUN mkdir -p /app/storage
ENV PAPERCLIP_STORAGE_PATH=/app/storage

EXPOSE 3000

CMD ["pnpm", "--filter", "@paperclipai/server", "run", "start"]

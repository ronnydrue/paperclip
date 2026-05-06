# Nutzen der Node-Version aus deinem ursprünglichen File
FROM node:20.14.0-bookworm-slim

# Installiere System-Abhängigkeiten (Python + Browser-Libs + pnpm Vorbereitung)
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

# Installiere pnpm global
RUN npm install -g pnpm

WORKDIR /app

COPY . .

# 1. Alle Abhängigkeiten installieren
RUN pnpm install

# 2. Prisma Client generieren (Wichtig, da die Fehlermeldung aus /packages/db kam)
RUN pnpm --filter @paperclipai/db prisma generate

# 3. Das gesamte Projekt bauen (TypeScript -> JavaScript)
RUN pnpm run build

# ... (Gemini-Agent Vorbereitung bleibt gleich)

EXPOSE 3000

# Startbefehl: Wir stellen sicher, dass wir im Produktionsmodus starten
ENV NODE_ENV=production

# Versuche diesen spezifischen Startbefehl
CMD ["pnpm", "--filter", "@paperclipai/server", "run", "start"]

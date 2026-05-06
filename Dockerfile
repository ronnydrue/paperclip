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

# Installiere pnpm global (WICHTIG für Paperclip)
RUN npm install -g pnpm

WORKDIR /app

# Paperclip bauen - wir nutzen pnpm statt npm, da das Projekt darauf optimiert ist
COPY package*.json ./
# Falls eine pnpm-lock.yaml existiert, kopieren wir die auch
COPY pnpm-lock.yaml* ./ 

RUN pnpm install

COPY . .
RUN pnpm run build

# Unseren Gemini-Agenten vorbereiten
RUN pip3 install --no-cache-dir google-genai --break-system-packages

# Ordner für Paperclip-Konfiguration erstellen
RUN mkdir -p /root/.paperclip /root/.gemini

EXPOSE 3000

# Startbefehl (meistens nutzt Paperclip pnpm start oder npm start)
CMD ["npm", "start"]

# Nutzen der Node-Version aus deinem ursprünglichen File
FROM node:20.14.0-bookworm-slim

# Installiere System-Abhängigkeiten (Python + Browser-Libs für Paperclip Skills)
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

WORKDIR /app

# Paperclip bauen
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Unseren Gemini-Agenten vorbereiten
# Wir nutzen --break-system-packages, da wir in einem Container sind
RUN pip3 install --no-cache-dir google-genai --break-system-packages

# Ordner für Paperclip-Konfiguration erstellen (Wichtig für Persistenz)
RUN mkdir -p /root/.paperclip /root/.gemini

EXPOSE 3000

# Startbefehl
CMD ["npm", "start"]

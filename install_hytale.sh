#!/bin/bash
set -e

#############################
# CONFIGURATION
#############################
RAM_GB=16
HYTALE_DIR="$HOME/hytale"
SERVER_DIR="$HYTALE_DIR/Server"

echo "==============================="
echo " INSTALLATION SERVEUR HYTALE"
echo " Ubuntu 22.04"
echo "==============================="

#############################
# 1️⃣ MISE À JOUR SYSTÈME
#############################
echo "🔄 Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

#############################
# 2️⃣ DÉPENDANCES
#############################
echo "📦 Installation des dépendances..."
sudo apt install -y curl wget unzip screen ufw

#############################
# 3️⃣ INSTALLATION JAVA 25
#############################
echo "☕ Installation de Java 25..."
sudo apt install -y openjdk-25-jdk

java -version

#############################
# 4️⃣ FIREWALL (UFW)
#############################
echo "🔥 Configuration du firewall..."
sudo ufw allow ssh
sudo ufw allow 22/tcp
sudo ufw allow 5520/udp
sudo ufw --force enable

#############################
# 5️⃣ DOSSIER HYTALE
#############################
echo "📁 Création des dossiers..."
mkdir -p "$HYTALE_DIR"
cd "$HYTALE_DIR"

#############################
# 6️⃣ DOWNLOADER HYTALE
#############################
echo "📥 Téléchargement du downloader Hytale..."
wget -q https://downloader.hytale.com/hytale-downloader.zip
unzip -o hytale-downloader.zip
chmod +x hytale-downloader-linux-amd64

#############################
# 7️⃣ AUTHENTIFICATION HYTALE
#############################
echo ""
echo "🔑 Authentification Hytale requise (OAuth)"
echo "➡️ Suis les instructions à l’écran"
./hytale-downloader-linux-amd64

#############################
# 8️⃣ EXTRACTION DERNIÈRE ARCHIVE
#############################
echo "📦 Recherche de la dernière archive serveur..."
LATEST_ZIP=$(ls -t 2026*.zip | head -n 1)

if [ -z "$LATEST_ZIP" ]; then
  echo "❌ Aucune archive 2026*.zip trouvée"
  exit 1
fi

echo "📂 Extraction de $LATEST_ZIP..."
unzip -o "$LATEST_ZIP"

#############################
# 9️⃣ CRÉATION start.sh
#############################
echo "▶️ Création du script start.sh..."

cat > "$SERVER_DIR/start.sh" <<EOF
#!/bin/bash
cd "\$(dirname "\$0")"

/usr/lib/jvm/java-25-openjdk-amd64/bin/java \\
-Xms${RAM_GB}G -Xmx${RAM_GB}G \\
--enable-native-access=ALL-UNNAMED \\
-jar HytaleServer.jar --assets ../Assets.zip
EOF

chmod +x "$SERVER_DIR/start.sh"

#############################
# 10️⃣ FIN
#############################
echo ""
echo "✅ INSTALLATION TERMINÉE"
echo "👉 Pour démarrer le serveur :"
echo "cd ~/hytale"
echo "screen -S hytale"
echo "bash Server/start.sh"
echo "➡️ Détacher : Ctrl + A puis D"

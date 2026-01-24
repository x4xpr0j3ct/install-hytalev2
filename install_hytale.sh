#!/bin/bash
set -e

#############################
# CONFIGURATION
#############################
RAM_GB=16
HYTALE_DIR="$HOME/hytale"
SERVER_DIR="$HYTALE_DIR/Server"
JAVA="/usr/lib/jvm/java-25-openjdk-amd64/bin/java"

echo "==============================="
echo " INSTALLATION COMPLETE HYTALE"
echo " (Post-update & reboot)"
echo "==============================="

#############################
# 1️⃣ DÉPENDANCES
#############################
echo "📦 Installation des dépendances..."
sudo apt install -y curl wget unzip screen ufw

#############################
# 2️⃣ JAVA 25
#############################
echo "☕ Installation de Java 25..."
sudo apt install -y openjdk-25-jdk
java -version

#############################
# 3️⃣ FIREWALL
#############################
echo "🔥 Configuration UFW..."
sudo ufw allow ssh
sudo ufw allow 22/tcp
sudo ufw allow 5520/udp
sudo ufw --force enable

#############################
# 4️⃣ DOSSIERS
#############################
echo "📁 Création dossier Hytale..."
mkdir -p "$HYTALE_DIR"
cd "$HYTALE_DIR"

#############################
# 5️⃣ DOWNLOADER
#############################
echo "📥 Téléchargement du downloader Hytale..."
wget -q https://downloader.hytale.com/hytale-downloader.zip
unzip -o hytale-downloader.zip
chmod +x hytale-downloader-linux-amd64

#############################
# 6️⃣ AUTH + TÉLÉCHARGEMENT
#############################
echo ""
echo "🔑 Authentification Hytale requise (OAuth)"
echo "➡️ Suis les instructions affichées"
./hytale-downloader-linux-amd64

#############################
# 7️⃣ CRÉATION start.sh
#############################
echo "▶️ Création du start.sh..."

cat > "$SERVER_DIR/start.sh" <<EOF
#!/bin/bash
cd "\$(dirname "\$0")"

$JAVA \\
-Xms${RAM_GB}G -Xmx${RAM_GB}G \\
--enable-native-access=ALL-UNNAMED \\
-jar HytaleServer.jar --assets ../Assets.zip
EOF

chmod +x "$SERVER_DIR/start.sh"

#############################
# FIN
#############################
echo ""
echo "✅ INSTALLATION TERMINÉE"
echo ""
echo "👉 Pour démarrer le serveur :"
echo "cd ~/hytale"
echo "screen -S hytale"
echo "bash Server/start.sh"

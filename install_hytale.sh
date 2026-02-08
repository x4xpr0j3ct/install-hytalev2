#!/bin/bash
set -e

echo "=============================================="
echo "   HYTALE SERVER AUTO INSTALLER"
echo "=============================================="

# Sécurité utilisateur
if [ "$USER" = "root" ]; then
  echo "❌ Ne pas lancer ce script en root."
  exit 1
fi

# RAM
TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
RECOMMENDED_RAM=$((TOTAL_RAM * 70 / 100))

echo "🧠 RAM totale : ${TOTAL_RAM} Go"
echo "👉 RAM recommandée : ${RECOMMENDED_RAM} Go"
read -p "RAM à allouer (Entrée = recommandé) : " RAM_GB
RAM_GB=${RAM_GB:-$RECOMMENDED_RAM}

if [ "$RAM_GB" -ge "$TOTAL_RAM" ]; then
  echo "❌ RAM trop élevée"
  exit 1
fi

# Mises à jour système
sudo apt update && sudo apt upgrade -y

# Dépendances
sudo apt install -y curl wget unzip screen ufw openjdk-25-jdk

# Pare-feu
sudo ufw allow ssh
sudo ufw allow 22/tcp
sudo ufw allow 5520/udp
sudo ufw --force enable

# Dossier serveur
mkdir -p ~/hytale-server
cd ~/hytale-server

# Downloader
if [ ! -f hytale-downloader-linux-amd64 ]; then
  wget -q https://downloader.hytale.com/hytale-downloader.zip
  unzip -o hytale-downloader.zip
  chmod +x hytale-downloader-linux-amd64
fi

DOWNLOADER=./hytale-downloader-linux-amd64

# 🔐 OAuth (une seule fois)
echo "🔍 Vérification de l'authentification Hytale..."
if ! $DOWNLOADER auth status >/dev/null 2>&1; then
  echo "🔐 Authentification requise"
  echo "➡️ Ouvre le lien, valide le code, puis REVIENS ici"
  $DOWNLOADER auth login device
  echo "✅ Authentification validée"
else
  echo "✅ Authentification déjà active"
fi

# 📦 Téléchargement serveur
echo "📦 Téléchargement du serveur Hytale..."
$DOWNLOADER download server

# Extraction dernière archive
LATEST_ZIP=$(ls -t *.zip | head -n 1)
unzip -o "$LATEST_ZIP"

# Script de démarrage
cat > Server/start.sh <<EOF
#!/bin/bash
cd "\$(dirname "\$0")"
screen -S hytale java \\
-Xms${RAM_GB}G -Xmx${RAM_GB}G \\
--enable-native-access=ALL-UNNAMED \\
-jar HytaleServer.jar --assets ../Assets.zip
EOF

chmod +x Server/start.sh

echo ""
echo "=============================================="
echo "✅ INSTALLATION TERMINÉE by Thekewaze / x3xtaziix" 
echo "➡️ Lancer le serveur :"
echo "   cd ~/hytale-server/Server && ./start.sh"
echo "➡️ Détacher screen : Ctrl+A puis D"
echo "=============================================="

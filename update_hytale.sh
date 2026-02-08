#!/bin/bash
set -e

#############################
# CONFIG
#############################
HYTALE_DIR="$HOME/hytale"
SERVER_DIR="$HYTALE_DIR/Server"
DOWNLOADER="$HYTALE_DIR/hytale-downloader-linux-amd64"
SCREEN_NAME="hytale"
JAVA="/usr/lib/jvm/java-25-openjdk-amd64/bin/java"

echo "==============================="
echo "  UPDATE AUTO SERVEUR HYTALE"
echo "==============================="

cd "$HYTALE_DIR"

#############################
# 1️⃣ ARRÊT DU SERVEUR (SCREEN)
#############################
echo "🛑 Arrêt du serveur..."
if screen -ls | grep -q "$SCREEN_NAME"; then
  screen -S "$SCREEN_NAME" -X quit
  sleep 5
else
  echo "ℹ️ Aucun serveur en cours."
fi

#############################
# 2️⃣ UPDATE VIA DOWNLOADER
#############################
echo "📥 Mise à jour via downloader Hytale..."
chmod +x "$DOWNLOADER"
"$DOWNLOADER" update

#############################
# 3️⃣ EXTRACTION DERNIÈRE ARCHIVE
#############################
echo "📦 Recherche de la dernière archive..."
LATEST_ZIP=$(ls -t 2026*.zip | head -n 1)

if [ -z "$LATEST_ZIP" ]; then
  echo "❌ Aucune archive trouvée"
  exit 1
fi

echo "📂 Extraction de $LATEST_ZIP..."
unzip -o "$LATEST_ZIP"

#############################
# 4️⃣ DÉCOMPRESSION DES ASSETS
#############################
if [ -f "$HYTALE_DIR/Assets.zip" ]; then
  echo "🎨 Décompression des Assets..."
  unzip -o "$HYTALE_DIR/Assets.zip" -d "$SERVER_DIR"
  rm -f "$HYTALE_DIR/Assets.zip"
else
  echo "ℹ️ Aucun Assets.zip à extraire"
fi

#############################
# 5️⃣ DÉMARRAGE DU SERVEUR
#############################
echo "🚀 Démarrage du serveur dans screen..."
screen -dmS "$SCREEN_NAME" bash -c "
$JAVA \
-Xms16G -Xmx16G \
--enable-native-access=ALL-UNNAMED \
-jar HytaleServer.jar --assets ../Assets.zip
"

echo "✅ UPDATE TERMINÉ by THEKEWAZE et X3XTAZIIX"
echo "👉 Console : screen -r hytale"


#!/bin/bash
# Script d'instal·lació per al Recordatori de Descans v2

# --- Variables de Configuració ---
APP_NAME="recordatori-descansv2"
SCRIPT_FILENAME="${APP_NAME}.py"
SOURCE_SCRIPT_PATH="./${SCRIPT_FILENAME}" # Assumeix que l'script Python està al mateix directori

BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/recordatori-descans" # Corregit el camí
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"

INSTALL_TARGET="${BIN_DIR}/${SCRIPT_FILENAME}"
DESKTOP_FILE="${DESKTOP_ENTRY_DIR}/${APP_NAME}.desktop"
AUTOSTART_FILE="${AUTOSTART_DIR}/${APP_NAME}.desktop"

# --- Colors per a missatges ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Instal·lant ${APP_NAME}...${NC}"

# --- Comprovar si l'script font existeix ---
if [ ! -f "$SOURCE_SCRIPT_PATH" ]; then
  echo -e "${RED}Error: El fitxer '${SCRIPT_FILENAME}' no es troba al directori actual.${NC}"
  echo "Si us plau, executa aquest script des del mateix directori on es troba '${SCRIPT_FILENAME}'."
  exit 1
fi

# --- Comprovar i instal·lar dependències (Debian/Ubuntu) ---
echo "Comprovant dependències (per a Debian/Ubuntu)..."
declare -a DEPENDENCIES=("python3-gi" "python3-gi-cairo" "gir1.2-gtk-3.0" "gir1.2-notify-0.7" "pulseaudio-utils")
declare -a MISSING_DEPS=()

for pkg in "${DEPENDENCIES[@]}"; do
    if ! dpkg -s "$pkg" &> /dev/null; then
        MISSING_DEPS+=("$pkg")
    fi
done

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo -e "${YELLOW}Algunes dependències falten: ${MISSING_DEPS[*]}${NC}"
    echo "Es requereix accés sudo per instal·lar-les."
    read -p "Vols intentar instal·lar-les ara? (s/N): " install_confirm
    if [[ "$install_confirm" =~ ^[Ss]$ ]]; then
        sudo apt-get update && sudo apt-get install -y "${MISSING_DEPS[@]}"
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error durant la instal·lació de dependències. Si us plau, instal·la manualment: ${MISSING_DEPS[*]} i torna a executar l'script.${NC}"
            exit 1
        fi
        echo -e "${GREEN}Dependències instal·lades correctament.${NC}"
    else
        echo -e "${RED}Instal·lació cancel·lada. Instal·la les dependències manualment i torna a executar l'script.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Totes les dependències necessàries semblen estar instal·lades.${NC}"
fi

# --- Crear directoris ---
echo "Creant directoris necessaris..."
mkdir -p "$BIN_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$AUTOSTART_DIR"
mkdir -p "$DESKTOP_ENTRY_DIR"

# --- Comprovar si ~/.local/bin està al PATH ---
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo -e "${YELLOW}Avís: El directori '$BIN_DIR' no sembla estar al teu PATH.${NC}"
  echo "Potser hauràs d'afegir-lo al teu fitxer ~/.bashrc, ~/.profile o ~/.zshrc afegint la línia:"
  echo 'export PATH="$HOME/.local/bin:$PATH"'
  echo "I després reiniciar la teva sessió o executar 'source ~/.bashrc' (o l'equivalent)."
fi

# --- Copiar l'script principal ---
echo "Instal·lant l'script a '$INSTALL_TARGET'..."
cp "$SOURCE_SCRIPT_PATH" "$INSTALL_TARGET"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: No s'ha pogut copiar l'script a '$INSTALL_TARGET'.${NC}"
    exit 1
fi

# --- Fer l'script executable ---
echo "Establent permisos d'execució..."
chmod +x "$INSTALL_TARGET"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: No s'han pogut establir els permisos d'execució a '$INSTALL_TARGET'.${NC}"
    exit 1
fi

# --- Crear l'entrada al menú d'aplicacions (.desktop) ---
echo "Creant accés directe al menú d'aplicacions..."
cat > "$DESKTOP_FILE" << EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Recordatori de Descans v2
Comment=Aplicació de recordatori de descansos saludables
Exec=python3 "$INSTALL_TARGET"
Icon=preferences-system-time
Terminal=false
Categories=Utility;GTK;
StartupNotify=false
EOL
# Actualitzar la base de dades de fitxers .desktop (opcional, però recomanat)
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications"
fi

# --- Crear l'entrada d'autoarranc (.desktop) ---
# Nota: Ja no afegim --autostart aquí, l'app ho gestiona internament.
echo "Configurant autoarranc (si està activat a la configuració de l'app)..."
cat > "$AUTOSTART_FILE" << EOL
[Desktop Entry]
Type=Application
Name=Recordatori de Descans v2
Comment=Aplicació de recordatori de descansos saludables
Exec=python3 "$INSTALL_TARGET"
Terminal=false
Categories=Utility;
StartupNotify=false
Hidden=false
X-GNOME-Autostart-enabled=true
EOL

# --- Missatges Finals ---
echo -e "${GREEN}Instal·lació completada!${NC}"
echo "L'script s'ha instal·lat a: $INSTALL_TARGET"
echo "S'ha creat un accés directe al menú d'aplicacions."
echo "S'ha creat una entrada per a l'autoarranc. L'aplicació s'iniciarà automàticament si l'opció 'Iniciar automàticament' està marcada dins la configuració de l'aplicació (activada per defecte)."
echo "Pots iniciar l'aplicació des del menú o executant:"
echo "python3 \"$INSTALL_TARGET\""
echo ""
echo -e "${YELLOW}Nota:${NC} Si és la primera vegada que instal·les una aplicació a '$BIN_DIR', pot ser necessari que tanquis sessió i tornis a entrar perquè el menú d'aplicacions i el PATH s'actualitzin correctament."
echo ""

# --- Preguntar per iniciar ara ---
read -p "Vols iniciar l'aplicació ara mateix? (s/N): " resposta
if [[ "$resposta" =~ ^[Ss]$ ]]; then
    echo "Iniciant l'aplicació en segon pla..."
    # Executar en segon pla i redirigir sortida per evitar bloquejar el terminal
    (python3 "$INSTALL_TARGET" > /dev/null 2>&1 &)
    echo "Aplicació iniciada!"
fi

exit 0
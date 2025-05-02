#!/bin/bash
# Script de desinstal·lació per al Recordatori de Descans v2

# --- Variables (han de coincidir amb install.sh) ---
APP_NAME="recordatori-descansv2"
SCRIPT_FILENAME="${APP_NAME}.py"

BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/recordatori-descans" # El camí correcte
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_ENTRY_DIR="$HOME/.local/share/applications"

INSTALL_TARGET="${BIN_DIR}/${SCRIPT_FILENAME}"
DESKTOP_FILE="${DESKTOP_ENTRY_DIR}/${APP_NAME}.desktop"
AUTOSTART_FILE="${AUTOSTART_DIR}/${APP_NAME}.desktop"

# --- Colors per a missatges ---
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Desinstal·lant ${APP_NAME}...${NC}"
echo ""

# --- Preguntar confirmació ---
read -p "Estàs segur que vols desinstal·lar el Recordatori de Descans? (això eliminarà l'script, els accessos directes i l'entrada d'autoarranc, però NO la teva configuració) (s/N): " confirm
if [[ ! "$confirm" =~ ^[Ss]$ ]]; then
    echo "Desinstal·lació cancel·lada."
    exit 0
fi
echo ""

# --- Aturar l'aplicació si s'està executant (opcional, pot ser complex detectar-ho) ---
# Aquesta part és més complexa i pot requerir 'pkill' o 'killall'.
# Per simplicitat, podem ometre-la o demanar a l'usuari que la tanqui manualment.
echo -e "${YELLOW}Si l'aplicació s'està executant, si us plau, tanca-la des de la icona de la safata abans de continuar.${NC}"
read -p "Prem Enter per continuar..."

# --- Eliminar l'script principal ---
echo "Eliminant l'script principal '$INSTALL_TARGET'..."
if [ -f "$INSTALL_TARGET" ]; then
    rm -f "$INSTALL_TARGET"
    if [ $? -eq 0 ]; then
        echo "Script eliminat."
    else
        echo -e "${RED}Error: No s'ha pogut eliminar '$INSTALL_TARGET'. Potser necessites permisos?${NC}"
    fi
else
    echo "L'script no existeix (potser ja s'ha eliminat)."
fi

# --- Eliminar l'accés directe del menú ---
echo "Eliminant l'accés directe del menú '$DESKTOP_FILE'..."
if [ -f "$DESKTOP_FILE" ]; then
    rm -f "$DESKTOP_FILE"
    if [ $? -eq 0 ]; then
        echo "Accés directe eliminat."
        # Actualitzar la base de dades de fitxers .desktop (opcional)
        if command -v update-desktop-database &> /dev/null; then
            echo "Actualitzant la base de dades d'aplicacions..."
            update-desktop-database "$HOME/.local/share/applications"
        fi
    else
        echo -e "${RED}Error: No s'ha pogut eliminar '$DESKTOP_FILE'.${NC}"
    fi
else
    echo "L'accés directe no existeix."
fi

# --- Eliminar l'entrada d'autoarranc ---
echo "Eliminant l'entrada d'autoarranc '$AUTOSTART_FILE'..."
if [ -f "$AUTOSTART_FILE" ]; then
    rm -f "$AUTOSTART_FILE"
    if [ $? -eq 0 ]; then
        echo "Entrada d'autoarranc eliminada."
    else
        echo -e "${RED}Error: No s'ha pogut eliminar '$AUTOSTART_FILE'.${NC}"
    fi
else
    echo "L'entrada d'autoarranc no existeix."
fi

# --- Informar sobre la configuració ---
echo ""
echo -e "${YELLOW}Nota: La configuració de l'aplicació NO s'ha eliminat.${NC}"
echo "Si vols eliminar-la també, pots esborrar el directori:"
echo "$CONFIG_DIR"
echo "(Conté el fitxer 'config.json')"
echo ""

echo -e "${GREEN}Desinstal·lació completada.${NC}"

exit 0
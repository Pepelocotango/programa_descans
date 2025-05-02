#!/bin/bash
# Script d'instal·lació per al recordatori de descansos

# Colors per a missatges
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Instal·lant el recordatori de descansos...${NC}"

# Comprovar si tenim les dependències necessàries
echo "Comprovant dependències..."
sudo apt-get update
sudo apt-get install -y python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-notify-0.7

# Crear directoris
echo "Creant directoris..."
mkdir -p ~/.local/bin
mkdir -p ~/.config/recordatori-descansv2v2
mkdir -p ~/.config/autostart

# Copiar l'script
echo "Instal·lant l'script principal..."
cat > ~/.local/bin/recordatori-descansv2v2.py << 'EOL'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import gi
import os
import sys
import json
import argparse
from datetime import datetime
import time
import threading

gi.require_version('Gtk', '3.0')
gi.require_version('Notify', '0.7')
from gi.repository import Gtk, GLib, Notify, Gdk

CONFIG_PATH = os.path.expanduser("~/.config/recordatori-descansv2v2")
CONFIG_FILE = os.path.join(CONFIG_PATH, "config.json")

DEFAULT_CONFIG = {
    "temps_treball": 50,  # Temps de treball en minuts
    "temps_descans": 10,  # Temps de descans en minuts
    "missatge": "Descansa 10 min!"
}

class ConfigDialog(Gtk.Dialog):
    def __init__(self, parent, config):
        Gtk.Dialog.__init__(
            self, title="Configuració", transient_for=parent, flags=0
        )
        self.set_default_size(300, 200)
        
        box = self.get_content_area()
        
        grid = Gtk.Grid()
        grid.set_column_spacing(10)
        grid.set_row_spacing(10)
        grid.set_margin_top(10)
        grid.set_margin_bottom(10)
        grid.set_margin_start(10)
        grid.set_margin_end(10)
        
        # Temps de treball
        label_treball = Gtk.Label(label="Temps de treball (minuts):")
        grid.attach(label_treball, 0, 0, 1, 1)
        
        self.temps_treball_entry = Gtk.SpinButton()
        self.temps_treball_entry.set_adjustment(Gtk.Adjustment(value=config["temps_treball"], lower=1, upper=120, step_increment=1))
        grid.attach(self.temps_treball_entry, 1, 0, 1, 1)
        
        # Temps de descans
        label_descans = Gtk.Label(label="Temps de descans (minuts):")
        grid.attach(label_descans, 0, 1, 1, 1)
        
        self.temps_descans_entry = Gtk.SpinButton()
        self.temps_descans_entry.set_adjustment(Gtk.Adjustment(value=config["temps_descans"], lower=1, upper=60, step_increment=1))
        grid.attach(self.temps_descans_entry, 1, 1, 1, 1)
        
        # Missatge
        label_missatge = Gtk.Label(label="Missatge:")
        grid.attach(label_missatge, 0, 2, 1, 1)
        
        self.missatge_entry = Gtk.Entry()
        self.missatge_entry.set_text(config["missatge"])
        grid.attach(self.missatge_entry, 1, 2, 1, 1)
        
        box.add(grid)
        
        # Botons
        self.add_button(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL)
        self.add_button(Gtk.STOCK_OK, Gtk.ResponseType.OK)
        
        self.show_all()
    
    def get_config(self):
        return {
            "temps_treball": self.temps_treball_entry.get_value_as_int(),
            "temps_descans": self.temps_descans_entry.get_value_as_int(),
            "missatge": self.missatge_entry.get_text()
        }

class BreakWindow(Gtk.Window):
    def __init__(self, missatge, temps_descans):
        Gtk.Window.__init__(self, title="Recordatori de Descans")
        self.set_keep_above(True)
        self.set_default_size(400, 200)
        self.set_position(Gtk.WindowPosition.CENTER)
        
        # Fer la finestra transparent
        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual and screen.is_composited():
            self.set_visual(visual)
            self.set_app_paintable(True)
        
        # Contingut
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        vbox.set_margin_top(20)
        vbox.set_margin_bottom(20)
        vbox.set_margin_start(20)
        vbox.set_margin_end(20)
        
        # Missatge principal
        label_missatge = Gtk.Label()
        label_missatge.set_markup(f'<span size="xx-large" weight="bold">{missatge}</span>')
        vbox.pack_start(label_missatge, True, True, 0)
        
        # Compte enrere
        self.temps_restant = temps_descans * 60
        self.label_compte = Gtk.Label()
        self.actualitza_compte()
        vbox.pack_start(self.label_compte, True, True, 0)
        
        # Botó per tancar manualment
        button = Gtk.Button(label="Tanca")
        button.connect("clicked", self.on_button_clicked)
        vbox.pack_start(button, False, False, 0)
        
        self.add(vbox)
        
        # Iniciar compte enrere
        GLib.timeout_add_seconds(1, self.actualitza_compte)
    
    def actualitza_compte(self):
        if self.temps_restant <= 0:
            self.destroy()
            return False
        
        minuts = self.temps_restant // 60
        segons = self.temps_restant % 60
        self.label_compte.set_text(f"Es tancarà en: {minuts:02d}:{segons:02d}")
        
        self.temps_restant -= 1
        return True
    
    def on_button_clicked(self, widget):
        self.destroy()

class RecordatoriApp:
    def __init__(self):
        # Inicialitzar notificacions
        Notify.init("Recordatori de Descans")
        
        # Carregar configuració
        self.config = self.carregar_config()
        
        # Crear icona a la barra de tasques
        self.create_tray_icon()
        
        # Variables per al temporitzador
        self.timer_running = False
        self.timer_thread = None
        self.next_break_time = None
    
    def carregar_config(self):
        # Assegurar-se que el directori de configuració existeix
        os.makedirs(CONFIG_PATH, exist_ok=True)
        
        # Carregar config o crear-ne una per defecte
        if os.path.exists(CONFIG_FILE):
            try:
                with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except:
                return DEFAULT_CONFIG
        else:
            self.guardar_config(DEFAULT_CONFIG)
            return DEFAULT_CONFIG
    
    def guardar_config(self, config):
        with open(CONFIG_FILE, 'w', encoding='utf-8') as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
    
    def create_tray_icon(self):
        # Creació de la icona de la safata del sistema
        self.menu = Gtk.Menu()
        
        # Opció 1: Iniciar/Parar temporitzador
        self.menu_start_stop = Gtk.MenuItem(label="Iniciar temporitzador")
        self.menu_start_stop.connect("activate", self.toggle_timer)
        self.menu.append(self.menu_start_stop)
        
        # Opció 2: Configuració
        menu_config = Gtk.MenuItem(label="Configuració")
        menu_config.connect("activate", self.obrir_configuracio)
        self.menu.append(menu_config)
        
        # Separador
        self.menu.append(Gtk.SeparatorMenuItem())
        
        # Opció 3: Sortir
        menu_quit = Gtk.MenuItem(label="Sortir")
        menu_quit.connect("activate", Gtk.main_quit)
        self.menu.append(menu_quit)
        
        self.menu.show_all()
        
        # Crear la icona a la safata
        self.icon = Gtk.StatusIcon()
        self.icon.set_from_stock(Gtk.STOCK_REFRESH)
        self.icon.set_tooltip_text("Recordatori de Descans")
        self.icon.connect("popup-menu", self.on_right_click)
        self.icon.set_visible(True)
    
    def on_right_click(self, icon, button, time):
        self.menu.popup(None, None, None, None, button, time)
    
    def obrir_configuracio(self, widget):
        dialog = ConfigDialog(None, self.config)
        response = dialog.run()
        
        if response == Gtk.ResponseType.OK:
            self.config = dialog.get_config()
            self.guardar_config(self.config)
            
            # Reiniciar el temporitzador si estava actiu
            if self.timer_running:
                self.stop_timer()
                self.start_timer()
        
        dialog.destroy()
    
    def toggle_timer(self, widget):
        if self.timer_running:
            self.stop_timer()
            self.menu_start_stop.set_label("Iniciar temporitzador")
        else:
            self.start_timer()
            self.menu_start_stop.set_label("Parar temporitzador")
    
    def start_timer(self):
        if self.timer_thread and self.timer_thread.is_alive():
            return
        
        self.timer_running = True
        self.timer_thread = threading.Thread(target=self.timer_loop)
        self.timer_thread.daemon = True
        self.timer_thread.start()
        
        # Actualitzar informació del proper descans
        self.next_break_time = time.time() + (self.config["temps_treball"] * 60)
        self.update_tooltip()
    
    def stop_timer(self):
        self.timer_running = False
        self.next_break_time = None
        self.icon.set_tooltip_text("Recordatori de Descans")
    
    def update_tooltip(self):
        if self.next_break_time:
            remaining = max(0, self.next_break_time - time.time())
            minutes = int(remaining // 60)
            seconds = int(remaining % 60)
            self.icon.set_tooltip_text(f"Proper descans en: {minutes:02d}:{seconds:02d}")
        else:
            self.icon.set_tooltip_text("Recordatori de Descans")
    
    def timer_loop(self):
        while self.timer_running:
            # Actualitzar tooltip cada segon
            GLib.idle_add(self.update_tooltip)
            
            # Comprovar si és hora de descans
            if self.next_break_time and time.time() >= self.next_break_time:
                GLib.idle_add(self.show_break_notification)
                
                # Calcular el temps del següent descans
                self.next_break_time = time.time() + (self.config["temps_treball"] * 60)
            
            time.sleep(1)
    
    def show_break_notification(self):
        # Mostrar notificació del sistema
        notificacio = Notify.Notification.new(
            "Hora de descansar!",
            f"{self.config['missatge']} - Descans: {self.config['temps_descans']} minuts",
            "dialog-information"
        )
        notificacio.set_urgency(Notify.Urgency.CRITICAL)
        notificacio.show()
        
        # Mostrar finestra de descans
        break_window = BreakWindow(self.config["missatge"], self.config["temps_descans"])
        break_window.connect("destroy", self.on_break_window_closed)
        break_window.show_all()
    
    def on_break_window_closed(self, window):
        pass

def main():
    parser = argparse.ArgumentParser(description="Recordatori de descansos per a Ubuntu")
    parser.add_argument("--autostart", action="store_true", help="Inicia automàticament el temporitzador")
    args = parser.parse_args()
    
    app = RecordatoriApp()
    
    # Iniciar automàticament si s'indica
    if args.autostart:
        GLib.idle_add(app.toggle_timer, None)
    
    Gtk.main()

if __name__ == "__main__":
    main()
EOL

# Fer l'script executable
chmod +x ~/.local/bin/recordatori-descansv2v2.py

# Crear l'entrada d'autoarranc
echo "Configurant autoarranc..."
cat > ~/.config/autostart/recordatori-descansv2v2.desktop << EOL
[Desktop Entry]
Type=Application
Name=Recordatori de Descans
Comment=Aplicació de recordatori de descansos saludables
Exec=python3 $HOME/.local/bin/recordatori-descansv2v2.py --autostart
Terminal=false
Categories=Utility;
StartupNotify=false
Hidden=false
EOL

# Crear una entrada al menú d'aplicacions
echo "Creant accés directe..."
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/recordatori-descansv2.desktop << EOL
[Desktop Entry]
Type=Application
Name=Recordatori de Descans
Comment=Aplicació de recordatori de descansos saludables
Exec=python3 $HOME/.local/bin/recordatori-descansv2.py
Icon=appointment-soon
Terminal=false
Categories=Utility;
StartupNotify=false
EOL

echo -e "${GREEN}Instal·lació completada!${NC}"
echo "L'aplicació s'iniciarà automàticament quan iniciïs sessió."
echo "També pots iniciar-la des del menú d'aplicacions o executant:"
echo "python3 ~/.local/bin/recordatori-descansv2.py"
echo ""
echo "Vols iniciar l'aplicació ara mateix? (s/n)"
read -r resposta
if [[ $resposta =~ ^[Ss]$ ]]; then
    echo "Iniciant l'aplicació..."
    python3 ~/.local/bin/recordatori-descansv2.py &
    echo "Aplicació iniciada!"
fi

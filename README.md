# Recordatori de Descans v2

Un senzill recordatori de descansos per a escriptoris Linux (especialment aquells basats en GTK3 com Ubuntu MATE), escrit en Python 3 i GTK3. T'ajuda a gestionar el temps de treball i descans mostrant una finestra bloquejant durant els períodes de pausa.

**Versió:** 2.0

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.txt)

*(Pots afegir una captura de pantalla aquí)*
<!-- ![Captura de pantalla](screenshot.png) -->

## Descripció

Aquesta aplicació s'executa en segon pla i monitora el temps. Després d'un interval de treball configurable, mostra una notificació del sistema (amb so opcional) i una finestra a pantalla completa que t'insta a descansar durant un temps determinat. La finestra de descans mostra un compte enrere i es pot tancar manualment o esperar que el temps s'esgoti. Inclou una icona a la safata del sistema per controlar el temporitzador i accedir a la configuració.

## Característiques

*   Temporitzadors configurables per als períodes de treball i descans (1-120 minuts / 1-60 minuts).
*   Missatge de descans personalitzable.
*   Finestra de descans bloquejant (stay-on-top) amb fons negre i compte enrere visible.
*   Notificació nativa del sistema a l'inici de cada descans.
*   **Opció per activar/desactivar un so d'alerta** per a la notificació (requereix `paplay`).
*   Icona a la safata del sistema amb menú contextual per:
    *   Iniciar / Aturar el temporitzador.
    *   Accedir al diàleg de configuració.
    *   Sortir de l'aplicació.
*   **Opció configurable per iniciar el temporitzador automàticament** en executar l'aplicació.
*   La configuració es desa a `~/.config/recordatori-descans/config.json`.
*   Gestió bàsica de canvis d'hora del sistema per evitar activacions incorrectes.
*   Arguments de línia d'ordres (`--autostart`, `--no-autostart`) per sobreescriure la configuració d'inici automàtic en llançar l'app.

## Requisits

Per executar aquesta aplicació, necessites un sistema **Linux** amb:

1.  **Python 3**.
2.  **PyGObject:** Les bindings de Python per a GObject, GTK, etc.
    *   A Debian/Ubuntu: `sudo apt update && sudo apt install python3-gi python3-gi-cairo gir1.2-gtk-3.0 gir1.2-notify-0.7`
    *   A Fedora: `sudo dnf install python3-gobject gtk3 libnotify`
    *   A Arch Linux: `sudo pacman -S python-gobject gtk3 libnotify`
3.  **GTK 3:** La llibreria del toolkit gràfic (normalment instal·lada amb l'escriptori).
4.  **LibNotify:** Per a les notificacions d'escriptori i un *dimoni de notificacions* actiu.
5.  **(Opcional, per al so)** `paplay`: Utilitat per reproduir so via PulseAudio/PipeWire.
    *   A Debian/Ubuntu: `sudo apt install pulseaudio-utils`
    *   A Fedora: `sudo dnf install pulseaudio-utils`
    *   A Arch Linux: `sudo pacman -S libpulse` (o `pipewire-pulse`)

## Instal·lació (Recomanat: Usant l'Script)

L'script d'instal·lació automatitza la còpia dels fitxers, la creació d'accessos directes i la configuració de l'autoarranc.

1.  **Descarrega:** Obtén els fitxers `recordatori-descansv2.py` i `install.sh` d'aquest repositori i desa'ls **al mateix directori**.
2.  **Obre un Terminal:** Navega fins al directori on has desat els fitxers.
3.  **Dona Permisos:** Fes executable l'script d'instal·lació:
    ```bash
    chmod +x install.sh
    ```
4.  **Executa l'Instal·lador:**
    ```bash
    bash install.sh
    ```
    *   L'script comprovarà les dependències (per a sistemes Debian/Ubuntu) i et preguntarà si vols instal·lar les que faltin (requereix `sudo`).
    *   Copiarà l'aplicació a `~/.local/bin/`.
    *   Crearà un accés directe al menú d'aplicacions (`~/.local/share/applications/`).
    *   Crearà una entrada d'autoarranc (`~/.config/autostart/`).

5.  **(Important)** Pot ser que hagis de **tancar sessió i tornar a entrar** perquè el teu escriptori reconegui el nou accés directe al menú i perquè l'script sigui executable directament des del terminal (si `~/.local/bin` no estava prèviament al teu PATH).

## Desinstal·lació (Usant l'Script)

Si has instal·lat l'aplicació amb l'`install.sh`, pots utilitzar l'`uninstall.sh` per eliminar-la.

1.  **Descarrega:** Obtén el fitxer `uninstall.sh` (si no el tens ja).
2.  **Obre un Terminal:** Navega fins on hagis desat `uninstall.sh`.
3.  **Dona Permisos:**
    ```bash
    chmod +x uninstall.sh
    ```
4.  **Executa el Desinstal·lador:**
    ```bash
    bash uninstall.sh
    ```
    *   L'script et demanarà confirmació.
    *   Eliminarà l'script de `~/.local/bin/`, l'accés directe de `~/.local/share/applications/` i l'entrada d'autoarranc de `~/.config/autostart/`.
    *   **No eliminarà el directori de configuració** (`~/.config/recordatori-descans`) per preservar les teves preferències. Pots eliminar-lo manualment si ho desitges.

## Ús

*   **Iniciar:**
    *   Busca "Recordatori de Descans v2" al menú d'aplicacions.
    *   Obre un terminal i executa: `recordatori-descansv2.py` (si `~/.local/bin` està al teu PATH).
    *   O executa la ruta completa: `python3 ~/.local/bin/recordatori-descansv2.py`
*   **Icona de Safata:** L'aplicació s'executa en segon pla amb una icona a la safata.
    *   **Clic Dret:** Mostra el menú per "Iniciar/Parar temporitzador", obrir la "Configuració" o "Sortir".
    *   **Tooltip:** Passa el ratolí per sobre per veure el temps restant fins al proper descans (si el temporitzador està actiu).
*   **Finestra de Descans:** Apareixerà automàticament quan acabi el temps de treball.
*   **Arguments de Línia d'Ordres:** (per a usuaris avançats o scripting)
    *   `--autostart`: Força l'inici del temporitzador en llançar l'app.
    *   `--no-autostart`: Evita l'inici del temporitzador en llançar l'app.

## Configuració

La configuració es gestiona a través del diàleg accessible des de la icona de la safata o editant manualment el fitxer:
`~/.config/recordatori-descans/config.json`

Opcions disponibles:

*   `temps_treball` (número): Durada del període de treball en minuts (per defecte: 50).
*   `temps_descans` (número): Durada del període de descans en minuts (per defecte: 10).
*   `missatge` (text): Text que es mostra a la finestra de descans (per defecte: "Descansa 10 min!").
*   `autostart` (booleà): `true` per iniciar el temporitzador automàticament, `false` altrament (per defecte: `true`).
*   `amb_so` (booleà): `true` per reproduir so amb la notificació, `false` altrament (per defecte: `true`).

## Compatibilitat

Dissenyada per a **entorns d'escriptori Linux basats en GTK3** (MATE, XFCE, Cinnamon, etc.).

*   Pot funcionar a KDE Plasma.
*   A GNOME Shell pot requerir una extensió per a la icona de safata (`Gtk.StatusIcon`).
*   **No compatible** directament amb Windows o macOS.
*   El so requereix `paplay` (de `pulseaudio-utils` o equivalent PipeWire).

## Llicència

Aquest projecte està llicenciat sota la Llicència MIT. Vegeu el fitxer `LICENSE.txt`.
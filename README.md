# Recordatori de Descans v2

Un senzill recordatori de descansos per a escriptoris Linux (especialment aquells basats en GTK3 com Ubuntu MATE), escrit en Python 3 i GTK3. T'ajuda a gestionar el temps de treball i descans mostrant una finestra bloquejant durant els períodes de pausa.

**Versió:** 2.0

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

*(Opcional: Pots afegir una captura de pantalla aquí quan en tinguis una)*
<!-- ![Captura de pantalla](screenshot.png) -->

## Descripció

Aquesta aplicació s'executa en segon pla i monitora el temps. Després d'un interval de treball configurable, mostra una notificació del sistema i una finestra a pantalla completa que t'insta a descansar durant un temps determinat. La finestra de descans mostra un compte enrere i només es pot tancar manualment o esperant que el temps s'esgoti. Inclou una icona a la safata del sistema per controlar el temporitzador i accedir a la configuració.

## Característiques

*   Temporitzadors configurables per als períodes de treball i descans.
*   Missatge de descans personalitzable.
*   Finestra de descans bloquejant (stay-on-top) amb fons negre i compte enrere.
*   Notificació nativa del sistema a l'inici de cada descans.
*   Opció per activar/desactivar un so d'alerta per a la notificació (requereix `paplay`).
*   Icona a la safata del sistema amb menú contextual per:
    *   Iniciar / Aturar el temporitzador.
    *   Accedir al diàleg de configuració.
    *   Sortir de l'aplicació.
*   Opció configurable per iniciar el temporitzador automàticament en executar l'aplicació.
*   La configuració es desa a `~/.config/recordatori-descans/config.json`.
*   Gestió bàsica de canvis d'hora del sistema.
*   Arguments de línia d'ordres (`--autostart`, `--no-autostart`) per sobreescriure la configuració d'inici automàtic.

## Requisits

Per executar aquesta aplicació, necessites:

1.  **Python 3:** La majoria de distribucions Linux el tenen preinstal·lat.
2.  **PyGObject:** Les bindings de Python per a GObject, GTK, etc.
    *   A Debian/Ubuntu: `sudo apt install python3-gi gir1.2-gtk-3.0 gir1.2-notify-0.7`
3.  **GTK 3:** La llibreria del toolkit gràfic.
    *   A Debian/Ubuntu: Normalment instal·lat per defecte amb l'escriptori (`libgtk-3-0`).
4.  **LibNotify:** Per a les notificacions d'escriptori.
    *   A Debian/Ubuntu: `sudo apt install libnotify4` (la llibreria) i assegurar-se que un dimoni de notificacions està actiu (ex: `mate-notification-daemon`, `notification-daemon`, `dunst`).
5.  **(Opcional, per al so)** `paplay`: Utilitat per reproduir so via PulseAudio/PipeWire.
    *   A Debian/Ubuntu: `sudo apt install pulseaudio-utils`

## Instal·lació

No cal instal·lació formal. Només has de:

1.  Descarregar el fitxer `recordatori-descansv2.py`.
2.  Donar-li permisos d'execució: `chmod +x recordatori-descansv2.py`
3.  Executar-lo: `./recordatori-descansv2.py`

Perquè s'executi automàticament a l'iniciar sessió, pots afegir-lo a les aplicacions d'inici del teu entorn d'escriptori.

## Ús

*   **Executar:** Obre un terminal i navega fins al directori on has descarregat el fitxer i executa `./recordatori-descansv2.py`.
*   **Icona de Safata:** Un cop executat, apareixerà una icona a la safata del sistema (normalment una icona de refresc/rellotge).
    *   **Clic Dret:** Obre el menú.
    *   **Iniciar/Parar temporitzador:** Activa o desactiva el cicle treball/descans.
    *   **Configuració:** Obre una finestra per ajustar els temps, el missatge, l'autostart i el so. Els canvis es desen automàticament en prémer "OK".
    *   **Sortir:** Tanca l'aplicació.
*   **Finestra de Descans:** Quan sigui hora de descansar, apareixerà una finestra gran i fosca. Pots esperar que acabi el compte enrere o fer clic a "Tanca" per tornar a la feina abans d'hora.
*   **Arguments de Línia d'Ordres:**
    *   `./recordatori-descansv2.py --autostart`: Força l'inici del temporitzador, ignorant la configuració desada (però la desa com a activa).
    *   `./recordatori-descansv2.py --no-autostart`: Evita l'inici del temporitzador, ignorant la configuració desada (però la desa com a inactiva).

## Configuració

L'aplicació desa la seva configuració al fitxer:
`~/.config/recordatori-descans/config.json`

Pots editar aquest fitxer manualment (mentre l'aplicació no s'està executant) o utilitzar el diàleg de configuració des del menú de la icona de safata.

Opcions disponibles:

*   `temps_treball`: Durada del període de treball en minuts (per defecte: 50).
*   `temps_descans`: Durada del període de descans en minuts (per defecte: 10).
*   `missatge`: Text que es mostra a la finestra de descans (per defecte: "Descansa 10 min!").
*   `autostart`: Si el temporitzador s'ha d'iniciar automàticament quan es llança l'aplicació (`true`/`false`, per defecte: `true`).
*   `amb_so`: Si s'ha de reproduir un so amb la notificació de descans (`true`/`false`, per defecte: `true`).

## Compatibilitat

Aquesta aplicació està dissenyada principalment per a **entorns d'escriptori Linux que utilitzen GTK3** i segueixen els estàndards de Freedesktop.org per a notificacions i icones de safata.

*   **Ideal:** Funciona millor en escriptoris com **Ubuntu MATE, XFCE, Cinnamon, LXDE/LXQt**.
*   **Possiblement Funcional:** Hauria de funcionar a **KDE Plasma** (bona compatibilitat amb GTK i estàndards). En **GNOME Shell modern**, la icona de safata (`Gtk.StatusIcon`) podria requerir una extensió addicional (com "AppIndicator Support") per ser visible.
*   **No Compatible Directament:** **Windows i macOS**. Requereixen adaptacions significatives, ja que depèn fortament de GTK3, LibNotify, `Gtk.StatusIcon` i l'ordre `paplay`, que no són nadius d'aquests sistemes operatius.

La funcionalitat de **so** depèn específicament de tenir `paplay` instal·lat i un servidor de so compatible (PulseAudio o PipeWire) funcionant. Si `paplay` no es troba, el so simplement no es reproduirà, però l'aplicació continuarà funcionant.

## Llicència

Aquest projecte està llicenciat sota la Llicència MIT. Consulta el fitxer `LICENSE.txt` (o el text inclòs a les fonts si no n'hi ha) per a més detalls.
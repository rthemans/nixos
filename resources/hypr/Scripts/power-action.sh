#!/usr/bin/env bash
#
# power-action.sh - Exécute une action d'alimentation (reboot, hibernate, etc.)
# avec notification via Caelestia Shell (toaster IPC) avant/après.
#
# Usage: power-action.sh <reboot|hibernate|suspend|poweroff>

set -euo pipefail

ACTION="${1:-}"

# Icônes à ajuster plus tard (freedesktop icon names, chemins absolus, ou "")
ICON_INFO="info"
ICON_ERROR="error"

notify() {
    local level="$1" title="$2" message="$3"
    caelestia-shell ipc call toaster "$level" "$title" "$message" \
        "$([ "$level" = "error" ] && echo "$ICON_ERROR" || echo "$ICON_INFO")" \
        2>/dev/null || true
}

case "$ACTION" in
    reboot)
        TITLE="Redémarrage"
        MESSAGE="La machine va redémarrer..."
        CMD="systemctl reboot"
        ;;
    hibernate)
        TITLE="Hibernation"
        MESSAGE="La machine va se mettre en hibernation..."
        CMD="systemctl hibernate"
        ;;
    suspend)
        TITLE="Suspension"
        MESSAGE="La machine va se suspendre..."
        CMD="systemctl suspend"
        ;;
    poweroff)
        TITLE="Extinction"
        MESSAGE="La machine va s'éteindre..."
        CMD="systemctl poweroff"
        ;;
    *)
        echo "Usage: $0 <reboot|hibernate|suspend|poweroff>" >&2
        exit 1
        ;;
esac

notify "info" "$TITLE" "$MESSAGE"

# Petit délai pour laisser le temps à la notif de s'afficher avant l'action
sleep 1

if ! OUTPUT=$($CMD 2>&1); then
    notify "error" "Échec: $TITLE" "Erreur: $OUTPUT"
    exit 1
fi

# Pour suspend/hibernate, on relance le lock écran une fois réveillé
case "$ACTION" in
    hibernate|suspend)
        hyprlock
        ;;
esac

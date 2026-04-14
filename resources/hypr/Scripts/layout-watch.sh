CITRIX_CLASS="wfica"  

handle() {
    local event="$1"
    
    # Événement activewindow>>CLASS,TITLE
    if [[ "$event" == activewindow* ]]; then
        local class=$(echo "$event" | cut -d'>' -f3 | cut -d',' -f1)
        
        if [[ "$class" == *"$CITRIX_CLASS"* ]]; then
            notify-send "Switching to Citrix layout"
            hyprctl switchxkblayout current 1
        else
            # On quitte Citrix
            notify-send "Restoring default layout"
            hyprctl switchxkblayout current 0
        fi
    fi
}

socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | \
    while read -r line; do handle "$line"; done

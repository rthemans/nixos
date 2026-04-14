CITRIX_CLASS="Wfica"  

handle() {
    local event="$1"
    
    if [[ "$event" == "activewindow>>"* ]]; then
        local class=$(echo "$event" | cut -d'>' -f3 | cut -d',' -f1)
        
        notify-send "changed to $class"

        if [[ "$class" == *"$CITRIX_CLASS"* ]]; then
            notify-send "Switching Layout to BE"
            hyprctl switchxkblayout current 1
        else
            notify-send "Switching Layout to FR"
            hyprctl switchxkblayout current 0
        fi
    fi
}

socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | \
    while read -r line; do handle "$line"; done

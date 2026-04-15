CITRIX_CLASS="Wfica"  
mode="default"

handle() {
    local event="$1"
    
    if [[ "$event" == "activewindow>>"* ]]; then
        local class=$(echo "$event" | cut -d'>' -f3 | cut -d',' -f1)
        if [[ "$class" == *"$CITRIX_CLASS"* ]] && [[ "$mode" != "citrix" ]]; then
            mode="citrix"
            hyprctl dispatch submap CLEAN
            hyprctl switchxkblayout current 1
        elif [[ "$mode" != "default" ]]; then
            mode="default"
            hyprctl dispatch submap reset
            hyprctl switchxkblayout current 0
        fi
    fi
}

socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | \
    while read -r line; do handle "$line"; done

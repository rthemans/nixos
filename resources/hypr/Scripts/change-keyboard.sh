class_to_match=${1:-""}
title_to_match=${2:-""}
mode="bepo"

handle() {
    local event="$1"
    
    if [[ "$event" == "activewindow>>"* ]]; then
        local base=$(echo "$event" | cut -d'>' -f3)
        local class=$(echo "$base" | cut -d',' -f1)
        local title=$(echo "$base" | cut -d',' -f2)
        if [[ "$class" == *"$class_to_match"* ]] && [[ "$title" == *"$title_to_match"* ]] && [[ "$mode" != "azerty" ]]; then
            mode="azerty"
            hyprctl switchxkblayout current 1
        elif [[ "$mode" != "default" ]]; then
            mode="default"
            hyprctl switchxkblayout current 0
        fi
    fi
}

socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | \
    while read -r line; do handle "$line"; done

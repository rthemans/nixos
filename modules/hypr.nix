{ config, inputs, pkgs, ...} : {

    imports = [
        inputs.hyprland.homeManagerModules.default
    ];

    home.file = {
        ".config/hypr" = {
            source = ../resources/hypr;
            recursive = true;
        };
    };

    home.packages = [
        pkgs.hyprshot
        pkgs.hyprpolkitagent
        pkgs.dbus
# file manager
        pkgs.nemo
# used to transfer data between processes
        pkgs.socat
    ];
    wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        extraConfig = ''
            # Moniteurs
            hl.monitor({
                output = "desc:AOC",
                mode = "1920x1080@239.96",
                position = "0x0",
                scale = 1,
            })
            hl.monitor({
                output = "desc:BNQ",
                mode = "1920x1080@60.00",
                position = "1920x0",
                scale = 1,
            })

            hl.workspace_rule({ workspace = "1", monitor = "desc:AOC", default = true)

            hl.on("hyprland.start", function()
                hl.exec_cmd("hyprctl dispatch workspace 1")
                hl.exec_cmd("mpvpaper -n 20 -o "--geometry=1920x1060 --shuffle --no-audio" ALL /DataDrive/liveWallpaper/")
            end)

            require("start")
            require("settings")
            require("binds")
            require("rules")
        '';
    };
    wayland.windowManager.hyprland.extraConfig = ''
    '';

    programs = {
        mpv.enable = true;
        hyprlock.enable = true;
    };

    services = {
        swaync = {
            enable = true;
        };
    };
}

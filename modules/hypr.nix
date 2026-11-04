{ config, inputs, pkgs, ...} : {

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
    ];
    wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        configType = "lua";
# package.path est déjà préconfiguré par Hyprland vers <configDir>/?.lua
        extraConfig = ''
            require("settings")
            require("start")
            require("binds")
            require("rules")
            require("events")
        '';
    };

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

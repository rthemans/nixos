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
        configType = "hyprlang";
        extraConfig = ''
            source = start.conf
            source = settings.conf
            source = binds.conf
            source = rules.conf
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

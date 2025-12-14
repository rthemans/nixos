{ config, inputs, pkgs, ...} : {

    imports = [
        inputs.walker.homeManagerModules.default
        inputs.hyprland.homeManagerModules.default
    ];

    home.file = {
        ".config/hypr" = {
            source = ../resources/hypr;
            recursive = true;
        };
        ".config/waybar" = {
            source = ../resources/waybar;
            recursive = true;
        };
    };

    home.packages = [
        pkgs.hyprshot
    ];
    wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
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
        walker = {
            enable = true;
            runAsService = true;

            config = {
                search.placeholder = "Example";
                ui.fullscreen = true;
                list = {
                    height = 200;
                };
                websearch.prefix = "?";
                switcher.prefix = "/";
            };

        };
        waybar.enable = true;
    };

    services = {
        swaync = {
            enable = true;
        };
    };
}

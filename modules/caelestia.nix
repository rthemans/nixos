{ config, inputs, pkgs, ...} : {
    imports = [
        inputs.caelestia-shell.homeManagerModules.default
    ];

    programs.caelestia = {
            enable = true;
            systemd = {
                enable = false; # if you prefer starting from your compositor
                    target = "graphical-session.target";
                environment = [];
            };
            settings = {
                general = {
                    apps = {
                        terminal = "kitty";
                        audio = "pavucontrol";
                        playback = "mpv";
                        explorer = "nemo";
                    };
                    idle = {
# I manage idle and lock without caelestia
                        lockBeforeSleep = false;
                        inhibitWhenAudio = false;
                        timeouts = [ ];
                    };
                };
                background = {
                    enabled = false;
                    desktopClock = {
                        enabled = false;
                    };
                };
                visualiser = {
                    enable = false;
                };
                bar = {
                    persistent = false;
                    showOnHover = true;
                    dragThreshold = 20;
                    scrollActions = {
                        workspaces = true;
                        volume = true;
                        brightness = true;
                    };
                    popouts = {
                        activeWindow = true;
                        tray = true;
                        statusIcons = true;
                    };
                    workspaces = {
                        shown = 5;
                        activeIndicator = true;
                        occupiedBg = false;
                        showWindows = true;
                        showWindowsOnSpecialWorkspaces = true;
                        activeTrail = false;
                        perMonitorWorkspaces = true;
                        label = "  ";
                        occupiedLabel = "󰮯";
                        activeLabel = "󰮯";
                        capitalisation = "preserve";
                        specialWorkspaceIcons = [];
                    };
                    tray = {
                        background = true;
                        recolour = false;
                        compact = false;
                        iconSubs = [];
                    };
                    status = {
                        showAudio = true;
                        showMicrophone = false;
                        showKbLayout = false;
                        showNetwork = true;
                        showBluetooth = true;
                        showBattery = false;
                        showLockStatus = true;
                    };
                    clock = {
                        showIcon = false;
                    };
                    sizes = {
                        innerWidth = 40;
                        windowPreviewSize = 400;
                        trayMenuWidth = 300;
                        batteryWidth = 250;
                        networkWidth = 320;
                    };
                    entries = [
                    {
                        enabled = true;
                        id = "logo";
                    }
                    {
                        enabled = true;
                        id = "workspaces";
                    }
                    {
                        enabled = true;
                        id = "spacer";
                    }
                    {
                        enabled = true;
                        id = "activeWindow";
                    }
                    {
                        enabled = true;
                        id = "spacer";
                    }
                    {
                        enabled = true;
                        id = "tray";
                    }
                    {
                        enabled = true;
                        id = "clock";
                    }
                    {
                        enabled = true;
                        id = "statusIcons";
                    }
                    {
                        enabled = true;
                        id = "power";
                    }
                    ];
                };
            };
            cli = {
                enable = true; # Also add caelestia-cli to path
                    settings = {
                        theme.enableGtk = false;
                    };
            };
        };
}

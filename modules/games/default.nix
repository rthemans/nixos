{ config, inputs, pkgs, ...} : {
    home.packages = [
      pkgs.wineWowPackages.waylandFull
      pkgs.winetricks
      pkgs.protontricks
    ];
}

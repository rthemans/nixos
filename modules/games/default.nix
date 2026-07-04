{ config, inputs, pkgs, ...} : {
    home.packages = [
      pkgs.wineWow64Packages.waylandFull
      pkgs.winetricks
      pkgs.protontricks
    ];
}

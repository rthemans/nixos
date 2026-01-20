{ config, inputs, pkgs, ...} : {

    imports = [
        (import ./hypr.nix {inherit config inputs pkgs;})
        (import ./caelestia.nix {inherit config inputs pkgs;})
    ];
}

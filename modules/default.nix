{ config, inputs, pkgs, ...} : {

    imports = [
        (import ./hypr.nix {inherit config inputs pkgs;})
    ];
}

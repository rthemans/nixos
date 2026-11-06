# Service utilisateur OpenClaw Gateway, déclaré côté home-manager.
# Remplace l'unité auto-générée par `openclaw` (~/.config/systemd/user/openclaw-gateway.service)
# qui sera sauvegardée en .hmbackup lors de l'activation.
#
# NOTE : si `openclaw daemon install` est relancé lors d'une mise à jour,
# il écraserait cette unité déclarative — ne pas l'utiliser ; rebuild suffit.
{ config, pkgs, ... }:

let
  openclaw = pkgs.openclaw;

  # Node 22 = la série utilisée par la dérivation openclaw (nodejs-slim_22).
  # Ne pas utiliser pkgs.nodejs-slim (déjà en 24.x sur ce canal).
  node = pkgs.nodejs-slim_22;

  # PATH fermé pour le gateway + fallback sur l'environnement système
  # pour les tools des skills (à affiner si un skill exige autre chose).
  runtimePath = builtins.concatStringsSep ":" (
    (map (p: "${p}/bin") [
      node
      pkgs.bash
      pkgs.coreutils
      pkgs.curl
      pkgs.git
      pkgs.jq
      pkgs.ripgrep
      pkgs.fd
      pkgs.findutils
      pkgs.gnugrep
      pkgs.gawk
      # Outils utilisés par les skills/agents du gateway (inventaire explicite)
      pkgs.gogcli # binaire "gog" (config: ~/.config/gogcli)
    ])
    ++ [ "/run/current-system/sw/bin" ]
  );
in
{
  systemd.user.services.openclaw-gateway = {
    Unit = {
      Description = "OpenClaw Gateway (v${openclaw.version})";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
      StartLimitBurst = 5;
      StartLimitIntervalSec = 60;
    };

    Service = {
      Type = "simple";
      ExecStart = "${openclaw}/bin/openclaw gateway --port 18789";
      Restart = "always";
      RestartSec = "5s";
      RestartPreventExitStatus = 78;
      TimeoutStopSec = "30s";
      TimeoutStartSec = "30s";
      SuccessExitStatus = "0 143";
      KillMode = "control-group";

      Environment = [
        "HOME=%h"
        "TMPDIR=/tmp"
        "PATH=${runtimePath}"
        "OPENCLAW_GATEWAY_PORT=18789"
        "OPENCLAW_SYSTEMD_UNIT=openclaw-gateway.service"
        "OPENCLAW_WINDOWS_TASK_NAME=OpenClaw Gateway"
        "OPENCLAW_SERVICE_MARKER=openclaw"
        "OPENCLAW_SERVICE_KIND=gateway"
        "OPENCLAW_SERVICE_VERSION=${openclaw.version}"
        # Backend keyring fichier pour gog (gogcli) : le mot de passe vient
        # du secret sops via EnvironmentFile (GOG_KEYRING_PASSWORD).
        "GOG_KEYRING_BACKEND=file"
      ];

      # Fichier rendu par sops-nix templates — chemin par défaut du module
      # sops-nix : /run/secrets/rendered/<nom> (owner=rthemans, 0400)
      EnvironmentFile = "/run/secrets/rendered/gogcli_env";

      # Durcissement incrémental (full, pas strict : l'état reste ~/.openclaw
      # et les skills peuvent écrire dans $HOME). Resserrer après validation.
      UMask = "0077";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "full";
      RestrictSUIDSGID = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      LockPersonality = true;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
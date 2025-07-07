{ stdenvNoCC, fetchFromGitHub, libsForQt5, wrapQtAppsHook }:

stdenvNoCC.mkDerivation rec {
  pname = "tokyo-night-sddm";
  version = "320c8e74";  # commit ou version
  dontBuild = true;

  nativeBuildInputs = [ wrapQtAppsHook ];
  propagatedUserEnvPkgs = [
    libsForQt5.qtbase
    libsForQt5.qtgraphicaleffects
    libsForQt5.qtquickcontrols2
  ];

  src = fetchFromGitHub {
    owner = "rototrash";
    repo = "tokyo-night-sddm";
    rev = version;
    sha256 = "sha256‑JRVVzyefqR2L3UrEK2iWyhUKfPMUNUnfRZmwdz05wL0=";
  };

  installPhase = ''
    mkdir -p $out/share/sddm/themes/$pname
    cp -aR $src/* $out/share/sddm/themes/$pname/
  '';
}


{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "whitesur-theme";

  src = pkgs.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "WhiteSur-gtk-theme";
      rev = "5a52172d2f27437555cc58c7dad15d06af74553d";
      sha256 = "0zmfcz9x966frsnkznjid0w2dpb7rzk8ic49a4ipvrnx2hwjqxpl";
  };

  installPhase = ''
    mkdir -p $out
    cp -R ./* $out/
    ls
    cd $out
    ls
    ./install.sh -c light -t red -o solid -HD --silent-mode -N whitesur-theme
  '';
}
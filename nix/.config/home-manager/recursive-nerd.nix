{ lib
, pkgs
, stdenvNoCC
, fetchFromGitHub
, python3Packages
}:
stdenvNoCC.mkDerivation rec {
  pname = "recursive-nerd";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "ryanoasis";
    repo = "nerd-fonts";
    rev = "v${version}";
    sparseCheckout = [
      "font-patcher"
      "src/"
      "!src/unpatched-fonts/"
    ];
    sha256 = "sha256-pdhYiL3Sx4dV6JTstx4JDbElHYcc0Srt9EoVt5mC7ZE=";
  };

  nativeBuildInputs = with python3Packages; [
    python
    fontforge
  ];

  buildPhase = ''
    mkdir -p $out/share/fonts/opentype
    for f in ${pkgs.recursive}/share/fonts/opentype/RecursiveMonoLnrSt-*; do
      python font-patcher $f --quiet --careful --complete --outputdir $out/share/fonts/opentype
    done
  '';

  dontInstall = true;
  dontFixup = true;

  meta = with lib; {
    homepage = "https://www.recursive.design";
    platforms = platforms.all;
  };
}

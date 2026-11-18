{ lib
, pkgs
, stdenvNoCC
, fetchgit
, python3Packages
}:
stdenvNoCC.mkDerivation rec {
  pname = "recursive-nerd";
  version = "3.5.1";

  src = fetchgit {
    url = "https://github.com/ryanoasis/nerd-fonts";
    rev = "v${version}";
    sparseCheckout = [
      "font-patcher"
      "bin/scripts"
      "src/"
      "!src/unpatched-fonts/"
    ];
    sha256 = "sha256-hpYDly9mQg9lx9hQPjk6LKzbIDPIkutwPGsSQZsM6PY=";
  };

  nativeBuildInputs = with python3Packages; [
    python
    fontforge
  ];

  buildPhase = ''
    mkdir -p $out/share/fonts/opentype
    # Only the styles that alacritty and awesome use. font-patcher opens the source
    # font for writing, so copy it out of the read-only store first.
    install -m 644 -t . ${pkgs.recursive}/share/fonts/opentype/RecursiveMonoLnrSt-{Regular,Italic,Black,BlackItalic}.otf
    printf '%s\n' RecursiveMonoLnrSt-*.otf \
      | xargs -P $NIX_BUILD_CORES -I {} python font-patcher {} --quiet --careful --complete --outputdir $out/share/fonts/opentype
  '';

  dontInstall = true;
  dontFixup = true;

  meta = with lib; {
    homepage = "https://www.recursive.design";
    platforms = platforms.all;
  };
}

{ lib
, pkgs
, stdenvNoCC
, fetchgit
, python3Packages
}:
stdenvNoCC.mkDerivation rec {
  pname = "recursive-nerd";
  version = "3.3.0";

  src = fetchgit {
    url = "https://github.com/ryanoasis/nerd-fonts";
    rev = "v${version}";
    sparseCheckout = [
      "font-patcher"
      "bin/scripts"
      "src/"
      "!src/unpatched-fonts/"
    ];
    sha256 = "sha256-EupyDZ+CT+TpWeY96CRoR7311iaPiyi/cs/DtfMqZl4=";
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

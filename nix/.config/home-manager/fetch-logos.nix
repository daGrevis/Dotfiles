{ stdenvNoCC
, librsvg
, python3
, src
}:
stdenvNoCC.mkDerivation {
  name = "fetch-logos";

  inherit src;

  nativeBuildInputs = [
    librsvg
    (python3.withPackages (ps: [ ps.pillow ]))
  ];

  buildPhase = ''
    sh render.sh $out
  '';

  dontInstall = true;
  dontFixup = true;
}

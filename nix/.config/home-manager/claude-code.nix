{ lib
, stdenvNoCC
, fetchurl
}:
let
  platforms = {
    aarch64-darwin = {
      platform = "darwin-arm64";
      hash = "sha256-zheZEBl2vgw14Q8tb+lZNps75iJ2RTMmcUdcr9b0VZE=";
    };
    x86_64-linux = {
      platform = "linux-x64";
      hash = "sha256-0U7A/KQAFRCSySaSj+p+jjgjH3qQ5uH47rKlXCRnavs=";
    };
  };
  current = platforms.${stdenvNoCC.hostPlatform.system} or (throw "unsupported platform");
in
stdenvNoCC.mkDerivation rec {
  pname = "claude-code";
  version = "2.1.283";

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code-${current.platform}/-/claude-code-${current.platform}-${version}.tgz";
    hash = current.hash;
  };

  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    mkdir -p $out/bin
    cp claude $out/bin/claude
    chmod +x $out/bin/claude
  '';

  meta = with lib; {
    description = "An agentic coding tool that lives in your terminal";
    homepage = "https://github.com/anthropics/claude-code";
    mainProgram = "claude";
  };
}

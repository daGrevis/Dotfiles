{ lib
, stdenvNoCC
, fetchurl
}:
let
  platforms = {
    aarch64-darwin = {
      platform = "darwin-arm64";
      hash = "sha256-rTr4re4yGiqx27Ox/y6L+PZsVLW039bzeSzm8MRqubY=";
    };
    x86_64-linux = {
      platform = "linux-x64";
      hash = "sha256-JdLiyubT0dXO6vDaAug8RcFkVeRe+hqzBTldwFInrQ0=";
    };
  };
  current = platforms.${stdenvNoCC.hostPlatform.system} or (throw "unsupported platform");
in
stdenvNoCC.mkDerivation rec {
  pname = "claude-code";
  version = "2.1.220";

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

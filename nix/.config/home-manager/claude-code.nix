{ lib
, stdenvNoCC
, fetchurl
, autoPatchelfHook
}:
let
  platforms = {
    aarch64-darwin = {
      platform = "darwin-arm64";
      hash = "sha256-TLTZRkP8YTXwgvS4+eadLkClHmAyFI0lgRKcrsxO5Cw=";
    };
  };
  current = platforms.${stdenvNoCC.hostPlatform.system} or (throw "unsupported platform");
in
stdenvNoCC.mkDerivation rec {
  pname = "claude-code";
  version = "2.1.116";

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code-${current.platform}/-/claude-code-${current.platform}-${version}.tgz";
    hash = current.hash;
  };

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

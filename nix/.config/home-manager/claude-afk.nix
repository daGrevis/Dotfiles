# The claude-afk command, which the timer and you start, and the image that each
# task run uses. See claude-afk/README.md in this repository.
{ lib
, dockerTools
, writeShellScriptBin
, writeTextDir
, bashInteractive
, coreutils
, findutils
, gnugrep
, gnused
, gawk
, diffutils
, gnutar
, gzip
, less
, procps
, which
, git
, curl
, jq
, ripgrep
, nix
, glibc
, tzdata
, util-linux
, systemd
, docker-client
, path
, claude-code
, dotfilesDirectory
, username
# Each run is you inside the container, so that the files in the task
# directory belong to you. The Nix store of the image also belongs to you, so
# that nix-shell can add paths to it. These must be the numbers of `id -u` and
# `id -g`.
, uid
, gid
}:
let
  passwd = writeTextDir "etc/passwd" ''
    root:x:0:0:root:/root:/bin/sh
    ${username}:x:${toString uid}:${toString gid}::/tmp:/bin/sh
  '';
  group = writeTextDir "etc/group" ''
    root:x:0:
    users:x:${toString gid}:
  '';
  # The Nix database of the image registers only the closure of contents. This
  # file puts the nixpkgs of NIX_PATH and the time zones in that closure,
  # without links to their files in the root of the image.
  references = writeTextDir "etc/claude-afk-references" ''
    ${path}
    ${tzdata}
  '';
  image = dockerTools.streamLayeredImage {
    name = "claude-afk";
    tag = "latest";
    contents = [
      claude-code
      bashInteractive
      coreutils
      findutils
      gnugrep
      gnused
      gawk
      diffutils
      gnutar
      gzip
      less
      procps
      which
      git
      curl
      jq
      ripgrep
      nix
      dockerTools.usrBinEnv
      dockerTools.binSh
      dockerTools.caCertificates
      passwd
      group
      references
    ];
    includeNixDB = true;
    inherit uid gid;
    uname = username;
    gname = "users";
    # claude is a Bun executable, which needs the loader at the path of common
    # Linux distributions. See dontPatchELF in claude-code.nix.
    extraCommands = ''
      mkdir -p lib64 tmp
      ln -s ${glibc}/lib/ld-linux-x86-64.so.2 lib64/ld-linux-x86-64.so.2
    '';
    # The store paths get uid and gid from the arguments above. The Nix database
    # is in this layer, which fakeroot makes as root.
    fakeRootCommands = ''
      chown -R ${toString uid}:${toString gid} nix
      chmod 1777 tmp
    '';
    config.Env = [
      "PATH=/bin:/usr/bin"
      "NIX_PATH=nixpkgs=${path}"
      "NIX_CONFIG=sandbox = false\nexperimental-features = nix-command flakes"
      "TZDIR=${tzdata}/share/zoneinfo"
      "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
      "USER=${username}"
      "DISABLE_UPDATES=1"
      "DISABLE_INSTALLATION_CHECKS=1"
    ];
  };
in
# The script is not copied into the store, so that a change to it applies at
# the next tick without a rebuild.
writeShellScriptBin "claude-afk" ''
  export CLAUDE_AFK_IMAGE=${image}
  export PATH=${lib.makeBinPath [ coreutils findutils gnugrep gnused gawk git curl jq util-linux systemd docker-client claude-code ]}:$PATH
  exec ${dotfilesDirectory}/claude-afk/claude-afk.sh "$@"
''

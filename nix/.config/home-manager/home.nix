{ config, lib, pkgs, ... }:

let
  inherit (pkgs) stdenv;
  username = "dagrevis";
  theme = "nightfox";
  themeColors = builtins.fromJSON (builtins.readFile "${dotfilesDirectory}/sh/sh/themes/${theme}.json");
  homeDirectory = if stdenv.isLinux then "/home/${username}" else "/Users/${username}";
  dotfilesDirectory = "${homeDirectory}/Dotfiles";
  recursive-nerd = pkgs.callPackage ./recursive-nerd.nix { };
  claude-code = pkgs.callPackage ./claude-code.nix { };
  fetch-logos = pkgs.callPackage ./fetch-logos.nix { src = /. + "${dotfilesDirectory}/fetch/logos"; };
  nix-rice = pkgs.callPackage (
    fetchTarball {
      url = "https://github.com/bertof/nix-rice/archive/refs/tags/v0.2.7.tar.gz";
      sha256 = "0kdh1f1cr0d8y4pcplzfgfkkif80drx3mjab9sfcss7svbr6wfd3";
    }
  ) {};
  brighten = hex:
    let
      rgba = nix-rice.color.hexToRgba hex;
      rgbaBrighter = nix-rice.color.brighten "10%" rgba;
      hexBrighter = nix-rice.color.toRgbHex rgbaBrighter;
    in
      hexBrighter;
  # Path of the Firefox profile directory, relative to the home directory. It is
  # the profile of the first install, or else the default profile. It is null if
  # Firefox did not start on this machine yet.
  firefoxProfile =
    let
      root = lib.findFirst (root: builtins.pathExists "${homeDirectory}/${root}/profiles.ini") null (
        if stdenv.isDarwin then [ "Library/Application Support/Firefox" ] else [ ".config/mozilla/firefox" ".mozilla/firefox" ]
      );
      ini = (lib.foldl' (acc: line:
        let
          section = builtins.match "\\[(.+)]" line;
          pair = builtins.match "([^=]+)=(.*)" line;
        in
          if section != null then acc // { current = lib.head section; }
          else if pair != null then lib.recursiveUpdate acc { sections.${acc.current}.${lib.head pair} = lib.last pair; }
          else acc
      ) { current = null; sections = { }; } (lib.splitString "\n" (builtins.readFile "${homeDirectory}/${root}/profiles.ini"))).sections;
      sections = prefix: lib.attrValues (lib.filterAttrs (name: _: lib.hasPrefix prefix name) ini);
      paths = map (install: install.Default) (sections "Install")
        ++ map (profile: profile.Path) (lib.filter (profile: (profile.Default or null) == "1") (sections "Profile"));
    in
      if root == null || paths == [ ] then null else "${root}/${lib.head paths}";
in
{
  home.stateVersion = "23.05";

  home.username = username;
  home.homeDirectory = homeDirectory;

  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  # {{{ Packages

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    alacritty
    asciinema
    asdf-vm
    autojump
    bat
    cargo
    chafa
    claude-code
    cloc
    codex
    deno
    dig
    docker
    docker-compose
    eza
    fastfetch
    fd
    ffmpeg
    file
    fzf
    gcc
    gist
    git
    git-lfs
    delta
    gh
    gnumake
    gnupg
    htop
    id3v2
    imagemagick
    inetutils
    jq
    killall
    less
    libnotify
    lsof
    lua
    man
    mkcert
    ncdu
    neovim
    nodejs
    openssl
    pandoc
    pass
    patchelf
    pinentry-curses
    postgresql
    prettierd
    pstree
    pv
    python3
    recursive
    recursive-nerd
    rename
    ripgrep
    shellcheck
    sops
    sqlite
    stow
    tmux
    tmuxinator
    tree-sitter
    unzip
    wget
    wordnet
    xclip
    xkcdpass
    xev
    yarn
    yt-dlp
    zsh
    zsh-fzf-tab
    pnpm
    yalc
    # unfree:
    ngrok
  ] ++ lib.optionals stdenv.isLinux [
    xdotool
  ];

  # }}}

  # {{{ Misc

  # https://github.com/NixOS/nixpkgs/issues/196651#issuecomment-1283814322
  manual.manpages.enable = false;

  # Manage fonts through fontconfig.
  fonts.fontconfig.enable = true;

  # Do not display notifications about home-manager news.
  news.display = "silent";

  # }}}

  # {{{ Asdf

  home.sessionVariables.ASDF_SH = "${pkgs.asdf-vm.outPath}/etc/profile.d/asdf-prepare.sh";

  home.file.".tool-versions".source = "${dotfilesDirectory}/asdf/.tool-versions";

  # }}}

  # {{{ Neovim

  home.file.".config/nvim/init.lua".source = "${dotfilesDirectory}/neovim/.config/nvim/init.lua";
  home.file.".config/nvim/lua/".source = "${dotfilesDirectory}/neovim/.config/nvim/lua";
  home.file.".config/nvim/snippets/".source = "${dotfilesDirectory}/neovim/.config/nvim/snippets";

  # }}}

  # {{{ Zsh

  home.file.".zshrc".source = "${dotfilesDirectory}/zsh/.zshrc";
  home.file.".zshenv".source = "${dotfilesDirectory}/zsh/.zshenv";
  home.file."sh/".source = "${dotfilesDirectory}/sh/sh";
  home.file."theme.sh".text =
    ''
      #!/usr/bin/env bash

      export THEME='${theme}'
      export THEME_BLACK='${themeColors.black}'
      export THEME_RED='${themeColors.red}'
      export THEME_GREEN='${themeColors.green}'
      export THEME_YELLOW='${themeColors.yellow}'
      export THEME_BLUE='${themeColors.blue}'
      export THEME_MAGENTA='${themeColors.magenta}'
      export THEME_CYAN='${themeColors.cyan}'
      export THEME_WHITE='${themeColors.white}'
      export THEME_BRIGHT_BLACK='${brighten themeColors.black}'
      export THEME_BRIGHT_RED='${brighten themeColors.red}'
      export THEME_BRIGHT_GREEN='${brighten themeColors.green}'
      export THEME_BRIGHT_YELLOW='${brighten themeColors.yellow}'
      export THEME_BRIGHT_BLUE='${brighten themeColors.blue}'
      export THEME_BRIGHT_MAGENTA='${brighten themeColors.magenta}'
      export THEME_BRIGHT_CYAN='${brighten themeColors.cyan}'
      export THEME_BRIGHT_WHITE='${brighten themeColors.white}'
      export THEME_ORANGE='${themeColors.orange}'
      export THEME_PINK='${themeColors.pink}'
      export THEME_COMMENT='${themeColors.comment}'
      export THEME_BG0='${themeColors.bg0}'
      export THEME_BG1='${themeColors.bg1}'
      export THEME_BG2='${themeColors.bg2}'
      export THEME_BG3='${themeColors.bg3}'
      export THEME_BG4='${themeColors.bg4}'
      export THEME_FG0='${themeColors.fg0}'
      export THEME_FG1='${themeColors.fg1}'
      export THEME_FG2='${themeColors.fg2}'
      export THEME_FG3='${themeColors.fg3}'
      export THEME_SEL0='${themeColors.sel0}'
      export THEME_SEL1='${themeColors.sel1}'
    '';

  # }}}

  # {{{ Tmux

  # A rebuild writes the file, but a tmux that already runs keeps the config it
  # read at start, so the status bar stays on the version from before the
  # rebuild. onChange runs only when the file changed.
  home.file.".tmux.conf" = {
    source = "${dotfilesDirectory}/tmux/.tmux.conf";
    onChange = ''
      if ${pkgs.tmux}/bin/tmux has-session 2> /dev/null; then
        # The config reads $THEME_* from the environment of the tmux server,
        # which has the values from when it started, so give it the new ones.
        while IFS== read -r name value; do
          $DRY_RUN_CMD ${pkgs.tmux}/bin/tmux set-environment -g "$name" "$value"
        done < <(. "$HOME/theme.sh"; env | grep '^THEME')
        $DRY_RUN_CMD ${pkgs.tmux}/bin/tmux source-file "$HOME/.tmux.conf" || true
      fi
    '';
  };
  home.file.".tmux/plugins/tpm".source = builtins.fetchGit { url = "https://github.com/tmux-plugins/tpm"; };

  # }}}

  # {{{ Git

  home.file.".gitconfig".source = "${dotfilesDirectory}/git/.gitconfig";
  home.file.".gitignore_global".source = "${dotfilesDirectory}/git/.gitignore_global";

  # }}}

  # {{{ Alacritty

  home.file.".config/alacritty/alacritty.toml".source = "${dotfilesDirectory}/alacritty/.config/alacritty/alacritty.toml";
  home.file.".config/alacritty/nixos.toml" = (lib.mkIf stdenv.isLinux {
    source = "${dotfilesDirectory}/alacritty/.config/alacritty/nixos.toml";
  });
  home.file.".config/alacritty/macos.toml" = (lib.mkIf stdenv.isDarwin {
    source = "${dotfilesDirectory}/alacritty/.config/alacritty/macos.toml";
  });
  home.file.".config/alacritty/theme.toml".text =
    ''
      [colors.primary]
      background = "${themeColors.bg0}"
      foreground = "${themeColors.fg1}"

      [colors.normal]
      black = "${themeColors.black}"
      red = "${themeColors.red}"
      green = "${themeColors.green}"
      yellow = "${themeColors.yellow}"
      blue = "${themeColors.blue}"
      magenta = "${themeColors.magenta}"
      cyan = "${themeColors.cyan}"
      white = "${themeColors.white}"

      [colors.bright]
      black = "${brighten themeColors.black}"
      red = "${brighten themeColors.red}"
      green = "${brighten themeColors.green}"
      yellow = "${brighten themeColors.yellow}"
      blue = "${brighten themeColors.blue}"
      magenta = "${brighten themeColors.magenta}"
      cyan = "${brighten themeColors.cyan}"
      white = "${brighten themeColors.white}"
    '';

  # }}}

  # {{{ Firefox

  # NOTE: nix does not install Firefox. The profile directory name is random and
  # different on each machine, so the name of this entry is not its target.
  # user.js is symlinked out of the store, so that a change applies at the next
  # start of Firefox without a rebuild.
  home.file."firefox-user.js" = (lib.mkIf (firefoxProfile != null) {
    target = "${firefoxProfile}/user.js";
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDirectory}/firefox/user.js";
  });
  home.file.".tridactylrc".source = "${dotfilesDirectory}/firefox/.tridactylrc";

  # }}}

  # {{{ Fzf

  home.file.".fzf-bindings.zsh".source = "${dotfilesDirectory}/fzf/.fzf-bindings.zsh";
  home.file.".fzf.zsh".source = "${dotfilesDirectory}/fzf/.fzf.zsh";

  # }}}

  # {{{ Awesome

  home.file.".config/awesome/rc.lua".source = "${dotfilesDirectory}/awesome/.config/awesome/rc.lua";

  # }}}

  # {{{ Hammerspoon

  home.file.".hammerspoon/init.lua".source = "${dotfilesDirectory}/hammerspoon/.hammerspoon/init.lua";

  # }}}

  # {{{ Ripgrep

  home.file.".ripgreprc".source = "${dotfilesDirectory}/ripgrep/.ripgreprc";

  # }}}

  # {{{ Fetch

  home.file.".config/fetch/logos/".source = fetch-logos;

  # }}}

  # {{{ Claude

  # NOTE: settings.json is copied (not symlinked) because `claude plugin install`
  # mutates it, and the read-only nix store path causes EACCES.
  # Upstream issue: anthropics/claude-code#3575
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    dst="$HOME/.claude/settings.json"
    $DRY_RUN_CMD mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ]; then
      $DRY_RUN_CMD rm "$dst"
    fi
    $DRY_RUN_CMD install -m 0644 "${dotfilesDirectory}/claude/.claude/settings.json" "$dst"
  '';

  # NOTE: skills are symlinked out of the store, so that a change to a SKILL.md
  # applies in the next session without a rebuild.
  home.file.".claude/skills/handoff".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDirectory}/claude/.claude/skills/handoff";
  home.file.".claude/skills/pickup".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDirectory}/claude/.claude/skills/pickup";

  # NOTE: the built-in Concise style and the simple-english plugin style cannot
  # both be active, because outputStyle takes one name. concise-ste merges them.
  home.file.".claude/output-styles/concise-ste.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesDirectory}/claude/.claude/output-styles/concise-ste.md";

  # claude (nix) is a Bun exe detected as "native" at runtime, so it warns
  # "command not found at ~/.local/bin/claude". Disable that check.
  home.sessionVariables.DISABLE_INSTALLATION_CHECKS = "1";

  # NOTE: the org default model (Sonnet) has override enabled, so it beats the
  # `model` key in settings.json on every launch. ANTHROPIC_MODEL takes
  # precedence over the org default, so it is the only way to pin Opus.
  home.sessionVariables.ANTHROPIC_MODEL = "claude-opus-5-5";

  # NOTE: effort is per-model since 2.1.280, and the top-level effortLevel in
  # settings.json does not apply to Opus 5.5, which starts at medium. The
  # settings schema has no modelSettings key, so the env var is the only pin.
  # It locks the level, so /effort cannot change it in a session.
  home.sessionVariables.CLAUDE_CODE_EFFORT_LEVEL = "xhigh";

  home.activation.installClaudePlugins = lib.hm.dag.entryAfter [ "claudeSettings" ] ''
    PATH="${claude-code}/bin:$PATH"
    if ! ${pkgs.jq}/bin/jq -e '.plugins | has("simple-english@simple-english")' "$HOME/.claude/plugins/installed_plugins.json" >/dev/null 2>&1; then
      $DRY_RUN_CMD claude plugin marketplace add AminBlg/SimpleEnglish || true
      $DRY_RUN_CMD claude plugin install simple-english@simple-english || true
    fi
  '';

  # }}}

  # {{{ Tunnel

  # NOTE: not systemd.user.services, because its Install.WantedBy enables the
  # unit on every host. systemd takes the unit name from the store file name.
  home.file.".config/systemd/user/tunnel.service" = (lib.mkIf stdenv.isLinux {
    source = "${pkgs.writeTextDir "tunnel.service" ''
      [Unit]
      Description=Reverse SSH tunnel to dagrev.is
      StartLimitIntervalSec=0

      [Service]
      ExecStart=${pkgs.openssh}/bin/ssh -F none -N -i %h/.ssh/tunnel_ed25519 -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o StrictHostKeyChecking=yes -R 0.0.0.0:2222:localhost:22 tunnel@dagrev.is
      Restart=always
      RestartSec=10

      [Install]
      WantedBy=default.target
    ''}/tunnel.service";
  });

  # }}}
}

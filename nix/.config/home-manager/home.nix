{ lib, pkgs, ... }:

let
  inherit (pkgs) stdenv;
  username = "dagrevis";
  theme = "nightfox";
  themeColors = builtins.fromJSON (builtins.readFile "${dotfilesDirectory}/sh/sh/themes/${theme}.json");
  homeDirectory = if stdenv.isLinux then "/home/${username}" else "/Users/${username}";
  dotfilesDirectory = "${homeDirectory}/Dotfiles";
  recursive-nerd = pkgs.callPackage ./recursive-nerd.nix { };
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
    cloc
    deno
    dig
    docker
    docker-compose
    eza
    fd
    ffmpeg
    file
    fzf
    gcc
    gist
    git
    git-lfs
    gitAndTools.delta
    gnumake
    gnupg
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
    htop
    id3v2
    inetutils
    jq
    killall
    kubectl
    libnotify
    lsof
    lua
    man
    fastfetch
    neovim
    nodejs
    openssl
    pandoc
    pass
    patchelf
    pinentry-curses
    postgresql
    pstree
    python3
    recursive
    recursive-nerd
    rename
    ripgrep
    shellcheck
    sops
    sqlite
    stow
    terraform
    tmux
    tmuxinator
    unzip
    wget
    xclip
    xkcdpass
    xorg.xev
    yarn
    yt-dlp
    zsh
    # unfree:
    ngrok
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

  home.sessionVariables.ASDF_SH = "${pkgs.asdf-vm.outPath}/share/asdf-vm/asdf.sh";

  home.file.".tool-versions".source = "${dotfilesDirectory}/asdf/.tool-versions";

  # }}}

  # {{{ Neovim

  home.file.".config/nvim/init.vim".source = "${dotfilesDirectory}/neovim/.config/nvim/init.vim";
  home.file.".config/coc/ultisnips/".source = "${dotfilesDirectory}/neovim/.config/coc/ultisnips";

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

  home.file.".tmux.conf".source = "${dotfilesDirectory}/tmux/.tmux.conf";
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
      background = "${themeColors.bg1}"
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
}

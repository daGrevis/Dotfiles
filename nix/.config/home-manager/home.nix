{ config, lib, pkgs, ... }:

let
  inherit (pkgs) stdenv;
in
{
  home.stateVersion = "22.11";

  home.username = "dagrevis";
  home.homeDirectory = if stdenv.isLinux then "/home/dagrevis" else "/Users/dagrevis";

  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  # {{{ Packages

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    ack
    alacritty
    asciinema
    asdf-vm
    autojump
    bat
    cargo
    deno
    docker
    exa
    fd
    ffmpeg
    fzf
    gcc
    gist
    git
    git-lfs
    gitAndTools.delta
    gnumake
    gnupg
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
    hack-font
    htop
    id3v2
    inetutils
    jq
    killall
    kubectl
    libnotify
    lsof
    lua
    neofetch
    neovim
    (nerdfonts.override { fonts = [ "VictorMono" ]; })
    nodejs
    oh-my-zsh
    openssl
    pandoc
    pass
    patchelf
    pinentry-curses
    postgresql
    pstree
    python3
    python38Packages.grip
    shellcheck
    sops
    sqlite
    stow
    terraform
    tmux
    tmuxinator
    wget
    xclip
    xkcdpass
    xorg.xev
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

  home.sessionVariables = {
    ASDF_SH = "${pkgs.asdf-vm.outPath}/share/asdf-vm/asdf.sh";
  };

  # }}}

  # {{{ Neovim

  home.file.".config/nvim/init.vim".source = "${config.home.homeDirectory}/Dotfiles/neovim/.config/nvim/init.vim";
  home.file.".config/coc/ultisnips/".source = "${config.home.homeDirectory}/Dotfiles/neovim/.config/coc/ultisnips";

  # }}}

  # {{{ Zsh

  home.file.".zshrc".source = "${config.home.homeDirectory}/Dotfiles/zsh/.zshrc";
  home.file.".zshenv".source = "${config.home.homeDirectory}/Dotfiles/zsh/.zshenv";
  home.file.".oh-my-zsh/".source = "${pkgs.oh-my-zsh.outPath}/share/oh-my-zsh/";
  home.file.".oh-my-zsh-custom/".source = "${config.home.homeDirectory}/Dotfiles/zsh/.oh-my-zsh-custom";
  home.file."sh/".source = "${config.home.homeDirectory}/Dotfiles/sh/sh";

  # }}}

  # {{{ Tmux

  home.file.".tmux.conf".source = "${config.home.homeDirectory}/Dotfiles/tmux/.tmux.conf";
  home.file.".tmux/plugins/tpm".source = builtins.fetchGit { url = "https://github.com/tmux-plugins/tpm"; };

  # }}}

  # {{{ Git

  home.file.".gitconfig".source = "${config.home.homeDirectory}/Dotfiles/git/.gitconfig";
  home.file.".gitignore_global".source = "${config.home.homeDirectory}/Dotfiles/git/.gitignore_global";

  # }}}

  # {{{ Alacritty

  home.file.".config/alacritty/alacritty.yml".source = "${config.home.homeDirectory}/Dotfiles/alacritty/.config/alacritty/alacritty.yml";
  home.file.".config/alacritty/nixos.yml" = (lib.mkIf stdenv.isLinux {
    source = "${config.home.homeDirectory}/Dotfiles/alacritty/.config/alacritty/nixos.yml";
  });
  home.file.".config/alacritty/macos.yml" = (lib.mkIf stdenv.isDarwin {
    source = "${config.home.homeDirectory}/Dotfiles/alacritty/.config/alacritty/macos.yml";
  });

  # }}}

  # {{{ Ack

  home.file.".ackrc".source = "${config.home.homeDirectory}/Dotfiles/ack/.ackrc";

  # }}}

  # {{{ Fzf

  home.file.".fzf-bindings.zsh".source = "${config.home.homeDirectory}/Dotfiles/fzf/.fzf-bindings.zsh";
  home.file.".fzf.zsh".source = "${config.home.homeDirectory}/Dotfiles/fzf/.fzf.zsh";

  # }}}

  # {{{ Awesome

  home.file.".config/awesome/rc.lua".source = "${config.home.homeDirectory}/Dotfiles/awesome/.config/awesome/rc.lua";

  # }}}

  # {{{ Hammerspoon

  home.file.".hammerspoon/init.lua".source = "${config.home.homeDirectory}/Dotfiles/hammerspoon/.hammerspoon/init.lua";

  # }}}
}

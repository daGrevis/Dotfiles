{ lib, pkgs, ... }:

{
  home.stateVersion = "20.03";

  # {{{ Packages

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    neovim
    wget
    git
    git-lfs
    stow
    home-manager
    docker
    tmux
    tmuxinator
    zsh
    oh-my-zsh
    fzf
    fd
    autojump
    exa
    bat
    gitAndTools.delta
    ack
    gcc
    nodejs
    python
    python3
    lua
    asdf-vm
    shellcheck
    python38Packages.grip
    ffmpeg
    alacritty
    gist
    firefox-bin
    xclip
    xorg.xev
    killall
    patchelf
    libnotify
    pstree
    lsof
    htop
    hack-font
    (nerdfonts.override { fonts = [ "VictorMono" ]; })
    neofetch
    gnupg
    pinentry-curses
    pass
    xkcdpass
    jq
    sops
    kubectl
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
    terraform
    postgresql
    sqlite
    pandoc
    asciinema
    cargo
    deno
    gnumake
    id3v2
    inetutils
    luakit
    openssl
    yt-dlp
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

  home.file.".config/nvim/init.vim".source = ~/Dotfiles/neovim/.config/nvim/init.vim;
  home.file.".config/coc/ultisnips/".source = ~/Dotfiles/neovim/.config/coc/ultisnips;

  # }}}

  # {{{ Zsh

  home.file.".zshrc".source = ~/Dotfiles/zsh/.zshrc;
  home.file.".zshenv".source = ~/Dotfiles/zsh/.zshenv;
  home.file.".oh-my-zsh/".source = pkgs.oh-my-zsh.outPath + "/share/oh-my-zsh/";
  home.file.".oh-my-zsh-custom/".source = ~/Dotfiles/zsh/.oh-my-zsh-custom;
  home.file."sh/".source = ~/Dotfiles/sh/sh;

  # }}}

  # {{{ Tmux

  home.file.".tmux.conf".source = ~/Dotfiles/tmux/.tmux.conf;
  home.file.".tmux/plugins/tpm".source = builtins.fetchGit { url = "https://github.com/tmux-plugins/tpm"; };

  # }}}

  # {{{ Git

  home.file.".gitconfig".source = ~/Dotfiles/git/.gitconfig;
  home.file.".gitignore_global".source = ~/Dotfiles/git/.gitignore_global;

  # }}}

  # {{{ Alacritty

  home.file.".config/alacritty/alacritty.yml".source = ~/Dotfiles/alacritty/.config/alacritty/alacritty.yml;
  home.file.".config/alacritty/common.yml".source = ~/Dotfiles/alacritty/.config/alacritty/common.yml;
  home.file.".config/alacritty/nixos.yml".source = ~/Dotfiles/alacritty/.config/alacritty/nixos.yml;
  home.file.".config/alacritty/colors/".source = ~/Dotfiles/alacritty/.config/alacritty/colors;

  # }}}

  # {{{ Ack

  home.file.".ackrc".source = ~/Dotfiles/ack/.ackrc;

  # }}}

  # {{{ Fzf

  home.file.".fzf-bindings.zsh".source = ~/Dotfiles/fzf/.fzf-bindings.zsh;
  home.file.".fzf.zsh".source = ~/Dotfiles/fzf/.fzf.zsh;

  # }}}

  # {{{ Awesome

  home.file.".config/awesome/rc.lua".source = ~/Dotfiles/awesome/.config/awesome/rc.lua;

  # }}}
}

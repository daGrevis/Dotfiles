{ lib, pkgs, ... }:

{
  home.stateVersion = "22.11";

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
    firefox-bin
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
    home-manager
    htop
    id3v2
    inetutils
    jq
    killall
    kubectl
    libnotify
    lsof
    lua
    luakit
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
    python
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

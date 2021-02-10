{ lib, pkgs, ... }:

{
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
    zsh
    oh-my-zsh
    fzf
    fd
    autojump
    exa
    bat
    gitAndTools.delta
    ack
    nodejs
    yarn
    python
    python3
    python38Packages.virtualenv
    python38Packages.grip
    alacritty
    gist
    firefox
    xclip
    xorg.xev
    libnotify
    htop
    hack-font
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    # unfree:
    ngrok
  ];

  # Manage fonts through fontconfig.
  fonts.fontconfig.enable = true;

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
}

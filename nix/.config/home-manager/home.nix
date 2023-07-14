{ lib, pkgs, ... }:

let
  inherit (pkgs) stdenv;
  username = "dagrevis";
  homeDirectory = if stdenv.isLinux then "/home/${username}" else "/Users/${username}";
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
    ack
    alacritty
    asciinema
    asdf-vm
    autojump
    bat
    cargo
    deno
    docker
    docker-compose
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
    man
    neofetch
    neovim
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
    recursive
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

  home.file.".tool-versions".source = "${homeDirectory}/Dotfiles/asdf/.tool-versions";

  # }}}

  # {{{ Neovim

  home.file.".config/nvim/init.vim".source = "${homeDirectory}/Dotfiles/neovim/.config/nvim/init.vim";
  home.file.".config/coc/ultisnips/".source = "${homeDirectory}/Dotfiles/neovim/.config/coc/ultisnips";

  # }}}

  # {{{ Zsh

  home.file.".zshrc".source = "${homeDirectory}/Dotfiles/zsh/.zshrc";
  home.file.".zshenv".source = "${homeDirectory}/Dotfiles/zsh/.zshenv";
  home.file.".oh-my-zsh/".source = "${pkgs.oh-my-zsh.outPath}/share/oh-my-zsh/";
  home.file.".oh-my-zsh-custom/".source = "${homeDirectory}/Dotfiles/zsh/.oh-my-zsh-custom";
  home.file."sh/".source = "${homeDirectory}/Dotfiles/sh/sh";

  # }}}

  # {{{ Tmux

  home.file.".tmux.conf".source = "${homeDirectory}/Dotfiles/tmux/.tmux.conf";
  home.file.".tmux/plugins/tpm".source = builtins.fetchGit { url = "https://github.com/tmux-plugins/tpm"; };

  # }}}

  # {{{ Git

  home.file.".gitconfig".source = "${homeDirectory}/Dotfiles/git/.gitconfig";
  home.file.".gitignore_global".source = "${homeDirectory}/Dotfiles/git/.gitignore_global";

  # }}}

  # {{{ Alacritty

  home.file.".config/alacritty/alacritty.yml".source = "${homeDirectory}/Dotfiles/alacritty/.config/alacritty/alacritty.yml";
  home.file.".config/alacritty/nixos.yml" = (lib.mkIf stdenv.isLinux {
    source = "${homeDirectory}/Dotfiles/alacritty/.config/alacritty/nixos.yml";
  });
  home.file.".config/alacritty/macos.yml" = (lib.mkIf stdenv.isDarwin {
    source = "${homeDirectory}/Dotfiles/alacritty/.config/alacritty/macos.yml";
  });

  # }}}

  # {{{ Ack

  home.file.".ackrc".source = "${homeDirectory}/Dotfiles/ack/.ackrc";

  # }}}

  # {{{ Fzf

  home.file.".fzf-bindings.zsh".source = "${homeDirectory}/Dotfiles/fzf/.fzf-bindings.zsh";
  home.file.".fzf.zsh".source = "${homeDirectory}/Dotfiles/fzf/.fzf.zsh";

  # }}}

  # {{{ Awesome

  home.file.".config/awesome/rc.lua".source = "${homeDirectory}/Dotfiles/awesome/.config/awesome/rc.lua";

  # }}}

  # {{{ Hammerspoon

  home.file.".hammerspoon/init.lua".source = "${homeDirectory}/Dotfiles/hammerspoon/.hammerspoon/init.lua";

  # }}}
}

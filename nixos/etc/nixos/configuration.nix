{ config, pkgs, ... }:

{

  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "/dev/sda";
      };
      timeout = 1;
    };

    initrd.checkJournalingFS = false;
  };

  fileSystems."/mnt/nixos-shared" = {
    device = "NixOS-Shared";
    fsType = "vboxsf";
    options = [ "rw,nofail" ];
  };

  networking = {
    useDHCP = false;
    interfaces.enp0s3.useDHCP = true;

    firewall.enable = false;
  };

  time.timeZone = "Europe/Riga";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    stow
    home-manager
    docker
    man
  ];

  documentation = {
    enable = true;

    man = {
      enable = true;
      generateCaches = true;
    };
  };

  services = {
    openssh.enable = true;

    xserver = {
      enable = true;

      layout = "lv";

      displayManager = {
        defaultSession = "none+awesome";
        lightdm.enable = true;

        autoLogin = {
          enable = true;
          user = "dagrevis";
        };
      };

      windowManager = {
        awesome.enable = true;
      };

      desktopManager = {
        wallpaper.mode = "center";
      };
    };
  };

  virtualisation = {
    docker.enable = true;
  };

  users = {
    users = {
      dagrevis = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "docker" "vboxsf" ];
        shell = pkgs.zsh;
      };
    };
  };

  nix.trustedUsers = ["root" "dagrevis"];

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "20.03";

}

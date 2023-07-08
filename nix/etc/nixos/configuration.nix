{ config, pkgs, ... }:

{

  system.stateVersion = "22.11";

  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    loader = {
      grub = {
        enable = true;
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
    docker-compose
    gnupg
    man
  ];

  documentation = {
    enable = true;

    man = {
      enable = true;
      generateCaches = true;
    };
  };

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=15s
  '';

  systemd.user.services = let
    # https://discourse.nixos.org/t/does-anybody-have-working-automatic-resizing-in-virtualbox/7391/14
    vbox-client = desc: flags: {
      description = "VirtualBox Guest: ${desc}";

      wantedBy = [ "graphical-session.target" ];
      requires = [ "dev-vboxguest.device" ];
      after = [ "dev-vboxguest.device" ];

      unitConfig.ConditionVirtualization = "oracle";

      serviceConfig.ExecStart = "${config.boot.kernelPackages.virtualboxGuestAdditions}/bin/VBoxClient -fv ${flags}";
      };
  in {
    virtualbox-resize = vbox-client "Resize" "--vmsvga";
    virtualbox-clipboard = vbox-client "Clipboard" "--clipboard";
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

  nix.settings.trusted-users = ["root" "dagrevis"];

  security.sudo.wheelNeedsPassword = false;

  programs.gnupg.agent.enable = true;

  programs.zsh.enable = true;

}

{ config, lib, pkgs, ... }:

{

  system.stateVersion = "23.05";

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

    kernelParams = [
      # Stops systemd-ssh-generator, which slows the boot in VirtualBox. It
      # only adds SSH over vsock and a local Unix socket. sshd.service stays.
      "systemd.ssh_auto=no"
      # The size of the VGA text console, so that systemd does not query the
      # console with an escape sequence that it never answers.
      "systemd.tty.rows.console=25"
      "systemd.tty.columns.console=80"
      # systemd starts no mount unit while more than 5 mount table changes
      # per second came in, and the boot makes more than 5 at once. The
      # kernel passes this to PID 1 as an environment variable.
      "SYSTEMD_DEFAULT_MOUNT_RATE_LIMIT_BURST=50"
    ];
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
    git
    earlyoom
  ];

  documentation = {
    enable = true;

    man = {
      enable = true;
      cache.enable = true;
    };
  };

systemd.user.services.earlyoom = {
    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.earlyoom}/bin/earlyoom -g";
      Restart = "on-failure";
    };
  };

  services = {
    openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        # Tunnel clients all come from loopback, so scans would lock them out.
        PerSourcePenaltyExemptList = "127.0.0.1,::1";
        # Dead tunnel sessions count toward the limit on dagrev.is, so close them fast.
        ClientAliveInterval = 15;
        ClientAliveCountMax = 3;
      };
    };

    displayManager = {
      defaultSession = "none+awesome";

      autoLogin = {
        enable = true;
        user = "dagrevis";
      };
    };

    xserver = {
      enable = true;

      xkb.layout = "lv";

      displayManager = {
        lightdm.enable = true;
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
    virtualbox.guest.enable = true;
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

  nix.settings = {
    trusted-users = [ "root" "dagrevis" ];
    experimental-features = [ "nix-command" ];
  };

  # Without "bpf", systemd attaches no BPF LSM program at boot, which is slow
  # here. No unit uses RestrictFileSystems=, the only user of it.
  security.lsm = lib.mkForce [ "landlock" "yama" ];

  security.sudo.wheelNeedsPassword = false;

  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;

  programs.nix-ld.enable = true;

  programs.zsh.enable = true;

}

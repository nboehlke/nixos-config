# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
	./nextcloud.nix
    ];

 # This configuration worked on 09-03-2021 nixos-unstable @ commit 102eb68ceec
 # The image used https://hydra.nixos.org/build/134720986

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
        "8250.nr_uarts=1"
        "console=ttyAMA0,115200"
        "console=tty1"
        # Some gui programs need this
        "cma=128M"
    ];
  };

  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
  };
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  networking = {
    hostName = "homeserver"; # Define your hostname.
    networkmanager = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    neovim
    parted
    git
  ];

  #start own config

  services.openssh = {
    enable = true; 
    permitRootLogin = "no";
  };

  fileSystems."/data" = { 
    device = "/dev/disk/by-uuid/753953c6-b9f3-60f0-ef69-aa32dea6fab6";
    fsType = "ext4";
    };

  services.cfdyndns = {
    enable = true;
    email = "niklas.boehlke@gmail.com";
    apikeyFile = "/etc/nixos/secrets/cfdyndns-apikey";
    records = [
      "home.niklas-boehlke.de"
      "cloud.niklas-boehlke.de"
    ];
  };

  security.acme = {
    acceptTerms = true;
    email = "niklas.boehlke@gmail.com";
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
  };

  #end own config

  users = {
    defaultUserShell = pkgs.zsh;
    #users.root = {
     # password = "apassword";
    #};
    users.niklas = {
      isNormalUser = true;
      passwordFile = "/etc/nixos/secrets/user";
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    };
  };

  environment.variables = {
    EDITOR = "nvim";
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
    '';
    promptInit = ""; # otherwise it'll override the grml prompt
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
  };

  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
  powerManagement.cpuFreqGovernor = "ondemand";
  system.stateVersion = "21.05";
  #swapDevices = [ { device = "/swapfile"; size = 3072; } ];
  
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./desktop.nix      
    ];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    gfxmodeEfi= "text";
  };
  
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = true;
  hardware.graphics.enable = true;

  networking.hostName = "mikoshi"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Africa/Johannesburg";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_ZA.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ivy = {
    isNormalUser = true;
    description = "ivy";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    algorithm = "zstd";
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];
  
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "05ac:024f" ];
        settings = {
          main = {
            brightnessdown = "f1";
            brightnessup   = "f2";
            scale          = "f3";
            dashboard      = "f4";
            kbdillumdown   = "f5";
            kbdillumup     = "f6";
            previoussong   = "f7";
            playpause      = "f8";
            nextsong       = "f9";
            mute           = "f10";
            volumedown     = "f11";
            volumeup       = "f12";
          };
          fn = {
            brightnessdown = "brightnessdown";
            brightnessup   = "brightnessup";
            scale          = "scale";
            dashboard      = "dashboard";
            kbdillumdown   = "kbdillumdown";
            kbdillumup     = "kbdillumup";
            previoussong   = "previoussong";
            playpause      = "playpause";
            nextsong       = "nextsong";
            mute           = "mute";
            volumedown     = "volumedown";
            volumeup       = "volumeup";
          };
        };
      };
    };
  };
  
  fonts = {
  packages = with pkgs; [
    open-sans
    noto-fonts
    nerd-fonts.symbols-only
    noto-fonts-color-emoji
    jetbrains-mono
    courier-prime
  ];

  fontconfig = {
    defaultFonts = {
      sansSerif = [ "Noto Serif" ];
      serif     = [ "Noto Serif" ];
      monospace = [ "Courier Prime" ];
     };
   };
  };
  environment.variables = {
  XCURSOR_THEME = "Bibata-Modern-Classic";
  XCURSOR_SIZE = "20";
  };
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}




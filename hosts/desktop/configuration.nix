{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.consoleMode = "max";
  };

  boot.kernelParams = [ "amdgpu.dc=1"
  "videomode=1920x1080"
  ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.kernelPackages = pkgs.linuxPackages_zen;


  networking.hostName = "mikoshi"; # Define your hostname.

  environment.systemPackages = with pkgs; [
  ];

  system.stateVersion = "25.11"; # Did you read the comment?
}

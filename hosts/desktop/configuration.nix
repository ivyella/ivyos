{ config, pkgs, ... }:
{
	imports = [ ./hardware-configuration.nix ];

	networking.hostName = "mikoshi";

	services.xserver.videoDrivers = [ "amdgpu" ];
	boot = {
   	kernelPackages = pkgs.linuxPackages_zen;
    	kernelParams = [ "amdgpu.dc=1" "videomode=1920x1080" ];
     	loader = {
      	systemd-boot.enable = true;
       	systemd-boot.consoleMode = "max";
        	efi.canTouchEfiVariables = true;
      };
  	};
   programs.appimage.enable = true;
   programs.appimage.binfmt = true;
  system.stateVersion = "25.11"; # Please do not the system.stateVersion
}

{ config, pkgs, ... }:
{
	imports = [ ./hardware-configuration.nix ];

	networking.hostName = "izanagi";

	boot = {
   	kernelPackages = pkgs.linuxPackages_zen;
     	loader = {
      	systemd-boot.enable = true;
        	efi.canTouchEfiVariables = true;
      };
  	};

   services.pulseaudio.enable = false;
   security.rtkit.enable = true;
   services.pipewire = {
   	enable = true;
    	alsa.enable = true;
     	alsa.support32Bit = true;
      pulse.enable = true;
   };

   system.stateVersion = "25.11";
}

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
		kernelParams = [ "snd_intel_dspcfg.dsp_driver=3" "snd_hda_intel.dmic_detect=0" ];
  	};
	nixpkgs.config.allowUnfree = true;
	hardware.enableRedistributableFirmware = true;
	hardware.firmware = with pkgs; [ sof-firmware ];
	
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

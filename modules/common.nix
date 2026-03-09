{ config, pkgs, lib, ... }:
{
	users.users.ivy = {
		isNormalUser = true;
		description = "ivy";
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [];
  	};

   security.sudo.extraConfig = ''
    	Defaults pwfeedback
   '';

   networking.networkmanager.enable = true;

   time.timeZone = "Africa/Johannesburg";
   i18n = {
    	defaultLocale = "en_ZA.UTF-8";
   };

   services.xserver.xkb = {
    	layout = "us";
     	variant = "";
   };

	environment.systemPackages = with pkgs; [
   	kitty
	   fish
		jq
	   starship
	   fastfetch
	   eza
		pavucontrol
	   openjdk21
	   playerctl
	   flatpak
	   micro
	   glib
	   git
	   codeberg-cli
	   firefox
	   libnotify
	   efibootmgr
	   cava
	   spotify-player
	   hyfetch
	   nwg-look
	   nautilus
	   vesktop
	   vscodium
	   spotify
	   yazi
	   element-desktop
	   zed-editor
		gapless
		whatsapp-electron
	];

   hardware.graphics.enable = true;
   nixpkgs.config.allowUnfree = true;
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   programs.nix-ld.enable = true;
   programs.fish.enable = true;
  	users.defaultUserShell = pkgs.fish;
   services.flatpak.enable = true;
}

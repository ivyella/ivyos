{ config, pkgs, lib, inputs, ... }:
{
	users.users.ivy = {
		isNormalUser = true;
		description = "ivy";
		extraGroups = [ "video" "networkmanager" "wheel" "render"];
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
		(inputs.fenix.packages.${pkgs.system}.stable.withComponents [
	      "cargo"
	      "clippy"
	      "rust-src"
	      "rustc"
	      "rustfmt"
	    ])
    
    brightnessctl
    bluez
		gcc
		lazygit
		file
		
   	kitty
	   fish
		jq
		gh
		helix
	   starship
	   fastfetch
		pciutils
	   eza
		pavucontrol
	   papers
	   openjdk21
	   openjdk25
	   easyeffects
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
	   pkgs.unstable.zed-editor
		gapless
		whatsapp-electron
		vulkan-tools
		xorg.xrdb
	];

   hardware.graphics = {
  enable = true;
  enable32Bit = true;
};
	services.pipewire = {
	  enable = true;
	  alsa.enable = true;
	  alsa.support32Bit = true;
	  pulse.enable = true;
	};
   nixpkgs.config.allowUnfree = true;
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   programs.nix-ld.enable = true;
   programs.fish.enable = true;
  	users.defaultUserShell = pkgs.fish;
   services.flatpak.enable = true;
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    services.upower.enable = true;
}

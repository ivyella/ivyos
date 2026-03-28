{ config, pkgs, lib, inputs, ... }:
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
		(inputs.fenix.packages.${pkgs.system}.stable.withComponents [
	      "cargo"
	      "clippy"
	      "rust-src"
	      "rustc"
	      "rustfmt"
	    ])
		gcc
		lazygit
		file
		zellij
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
		vulkan-tools
	];

   hardware.graphics = {
	  enable = true;
	  enable32Bit = true; # This is the missing link for PS2/PCSX2
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
}

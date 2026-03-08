{ config, pkgs, lib, ... }:
{
	environment.systemPackages = with pkgs; [
		bibata-cursors
		adwaita-icon-theme
    	gnome-themes-extra
     	adw-gtk3
	];

  	fonts = {
   	packages = with pkgs; [
    		open-sans
     		noto-fonts
       	nerd-fonts.symbols-only
        	noto-fonts-color-emoji
         jetbrains-mono
         courier-prime
         material-symbols
         material-icons
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
}

{ config, pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    bibata-cursors
    adwaita-icon-theme
    gnome-themes-extra
    adw-gtk3
    kdePackages.breeze
  ];

  fonts = {
    packages = with pkgs; [
      open-sans
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.symbols-only

      jetbrains-mono
      courier-prime

      material-symbols
      material-icons
      source-serif
      ibm-plex
      google-fonts
      roboto-slab
      maple-mono.NF
    ];

     	fontconfig = {
     		defaultFonts = {
     			sansSerif = [ "Inter" ];
      		serif     = [ "IBM Plex Serif" ];
       		monospace = [ "Maple Mono" ];
      	};
   	};
  };

  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "20";
  };
}
{ config, pkgs, ... }:
{
  home.username = "ivory";
  home.homeDirectory = "/home/ivory";
  home.stateVersion = "25.11";
  
  programs.home-manager.enable = true;
  
  home.file = {
    # .config symlinks
    ".config/kitty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/kitty";
    ".config/fish".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/fish";
    ".config/fuzzel".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/fuzzel";
    ".config/niri".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/niri";
    ".config/waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/waybar";
    ".config/swaync".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/swaync";
    ".config/wlogout".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/wlogout";
    ".config/starship".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/starship";
    ".config/fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/fastfetch";
    ".config/vesktop".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/vesktop";
    ".config/gtk-3.0".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/gtk-3.0";
    ".config/gtk-4.0".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/gtk-4.0";
    ".config/qt5ct".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/qt5ct";
    ".config/qt6ct".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/qt6ct";
    ".config/quickshell".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/quickshell";
    ".config/zed".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/zed";
    ".config/systemd".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.config/systemd";
    
    # .local/share symlinks
    ".local/share/color-schemes".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.local/share/color-schemes";
    ".local/share/PrismLauncher/themes".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/ivyos/profiles/material/.local/share/PrismLauncher/themes";
  };
  
  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "20";
  };
  
  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 20;
    };
  };
  
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 20;
  };
}
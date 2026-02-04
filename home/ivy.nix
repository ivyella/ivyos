{ config, pkgs, ... }:
{
  home.username = "ivy";
  home.homeDirectory = "/home/ivy";
  home.stateVersion = "25.11";
  
  programs.home-manager.enable = true;
  
  home.file = {
    # .config symlinks
    ".config/kitty".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/kitty";
    ".config/fish".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/fish";
    ".config/fuzzel".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/fuzzel";
    ".config/niri".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/niri";
    ".config/waybar".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/waybar";
    ".config/swaync".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/swaync";
    ".config/wlogout".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/wlogout";
    ".config/starship".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/starship";
    ".config/fastfetch".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/fastfetch";
    ".config/qt5ct".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/qt5ct";
    ".config/qt6ct".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/qt6ct";
    ".config/quickshell".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/quickshell";
    ".config/zed".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/zed";

    ".config/gtk-3.0/colors.css".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/gtk-3.0/colors.css";
    ".config/gtk-3.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/gtk-3.0/gtk.css";
    ".config/gtk-4.0/colors.css".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/gtk-4.0/colors.css";
    ".config/gtk-4.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.config/gtk-4.0/gtk.css";
  
    # .local/share symlinks
    ".local/share/color-schemes".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.local/share/color-schemes";
    ".local/share/PrismLauncher/themes".source = config.lib.file.mkOutOfStoreSymlink "/home/ivy/ivyos/profiles/material/.local/share/PrismLauncher/themes";
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

  systemd.user.services = {
  waybar = {
    Unit = {
      Description = "Waybar status bar";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.waybar}/bin/waybar";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  
  swaync = {
    Unit = {
      Description = "Sway Notification Center";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
};
}

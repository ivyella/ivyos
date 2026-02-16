{ config, pkgs, ... }:

let
  ivyRoot = "${config.home.homeDirectory}/ivyos";

  configApps = [
    "kitty"
    "fish"
    "fuzzel"
    "niri"
    "wlogout"
    "starship"
    "fastfetch"
    "qt5ct"
    "qt6ct"
    "quickshell"
    "zed"
  ];

  gtkFiles = [
    "gtk-3.0/colors.css"
    "gtk-3.0/gtk.css"
    "gtk-4.0/colors.css"
    "gtk-4.0/gtk.css"
  ];

in
{
  home.username = "ivy";
  home.homeDirectory = "/home/ivy";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Symlinks for configs and themes
  home.file = builtins.listToAttrs (
    # .config apps
    map (app: {
      name = ".config/${app}";
      value.source = config.lib.file.mkOutOfStoreSymlink "${ivyRoot}/profiles/material/.config/${app}";
    }) configApps
    ++
    # GTK files
    map (file: {
      name = ".config/${file}";
      value.source = config.lib.file.mkOutOfStoreSymlink "${ivyRoot}/profiles/material/.config/${file}";
    }) gtkFiles
    ++
    # .local/share symlinks
    [
      { name = ".local/share/color-schemes"; value.source = config.lib.file.mkOutOfStoreSymlink "${ivyRoot}/profiles/material/.local/share/color-schemes"; }
      { name = ".local/share/PrismLauncher/themes"; value.source = config.lib.file.mkOutOfStoreSymlink "${ivyRoot}/profiles/material/.local/share/PrismLauncher/themes"; }
      { name = ".local/share/icons/poisonivy"; value.source = config.lib.file.mkOutOfStoreSymlink "${ivyRoot}/themes/icons/poisonivy"; }
    ]
  );

  # Session variables
  home.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "20";
  };

  # GTK settings
  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 20;
    };
    iconTheme = {
      name = "poisonivy";
    };
  };

  # Pointer/cursor
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 20;
  };

  # User services
  systemd.user.services = {
    quickshell = {
      Unit = {
        Description = "quickshell";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.quickshell}/bin/qs";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}

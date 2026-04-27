{ config, pkgs, ... }:
let
  ivyRoot = "${config.home.homeDirectory}/ivyos";
  ivyshell = "${ivyRoot}/ivyshell";
  qs = pkgs.quickshell;

  configApps = [
    "kitty"
    "fish"
    "niri"
    "starship"
    "fastfetch"
    "qt5ct"
    "qt6ct"
    "zed"
    "helix"
    "yazi"
    "ivyshell"
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

  home.file = builtins.listToAttrs (
    map (app: {
      name = ".config/${app}";
      value.source = config.lib.file.mkOutOfStoreSymlink "${ivyRoot}/ivyshell/.config/${app}";
    }) configApps
    ++
    map (file: {
      name = ".config/${file}";
      value.source = config.lib.file.mkOutOfStoreSymlink "${ivyRoot}/ivyshell/.config/${file}";
    }) gtkFiles
    ++
    [
      { name = ".config/quickshell";                    value.source = config.lib.file.mkOutOfStoreSymlink "${ivyshell}/shell"; }
      { name = ".local/share/color-schemes";            value.source = config.lib.file.mkOutOfStoreSymlink "${ivyshell}/.local/share/color-schemes"; }
      { name = ".local/share/PrismLauncher/themes";     value.source = config.lib.file.mkOutOfStoreSymlink "${ivyshell}/.local/share/PrismLauncher/themes"; }
      { name = ".local/share/icons/poisonivy";          value.source = config.lib.file.mkOutOfStoreSymlink "${ivyshell}/themes/icons/poisonivy"; }
      { name = ".vscode-oss/extensions/ivyella.ivy-theme-1.0.0"; value.source = config.lib.file.mkOutOfStoreSymlink "${ivyshell}/.vscode-oss/extensions/ivyella.ivy-theme-1.0.0"; }
    ]
  );

  home.sessionVariables = {
    EDITOR = "codium";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "20";
    GTK_THEME = "adw-gtk3-dark";
    ADW_DISABLE_PORTAL = "1";
  };

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

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 20;
  };

  systemd.user.services = {
    quickshell = {
      Unit = {
        Description = "quickshell";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${qs}/bin/qs";
        Restart = "on-failure";
        KillMode = "process";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}

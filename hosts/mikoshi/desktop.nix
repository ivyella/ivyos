{ pkgs, inputs, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    "nexusmods-app-0.21.1"
  ];

  environment.systemPackages = with pkgs; [
    kitty
    fish
    starship
    fastfetch
    eza
    pavucontrol
    keyd
    openjdk21
    playerctl
    flatpak
    micro
    xdg-desktop-portal-gnome
    glib
    git
    codeberg-cli
    firefox
    krita
    libnotify
    efibootmgr
    cava
    spotify-player
    hyfetch
    # waybar
    # swaynotificationcenter
    fuzzel
    # swww
    wlogout
    xwayland-satellite
    bibata-cursors
    nwg-look
    nautilus
    vesktop
    vscodium
    spotify
    prismlauncher
    steam
    yazi
    nexusmods-app
    adwaita-icon-theme
    gnome-themes-extra
    adw-gtk3
    protonplus
    heroic
    vitetris
    penpot-desktop
    aseprite
    blockbench
    obsidian
    element-desktop
    quickshell
    zed-editor

  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
            --remember \
            --remember-user-session \
            --time \
            --asterisks \
            --cmd niri-session
        '';
	user = "greeter";
      };
    };
  };

  services.dbus.enable = true;
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
    ];

    config = {
      common.default = "gnome";
    };
  };

  programs.niri.enable = true;

  programs.steam.enable = true;

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  services.flatpak.enable = true;
}

{ pkgs, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    "nexusmods-app-0.21.1"
  ];

  # Packages 
  environment.systemPackages = with pkgs; [
    # Core tools
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
    stow

    # Niri / Wayland stack
    niri
    waybar
    swaynotificationcenter
    fuzzel
    swww
    wlogout
    matugen
    xwayland-satellite
    bibata-cursors
    nwg-look

    # Applications
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
  ];

  # Login manager
 
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
        };
      };
     };

  services.dbus.enable = true;
  programs.dconf.enable = true;  	
  # Portals
  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  # Steam
  programs.steam.enable = true;

  # Fish as default shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Flatpak
  services.flatpak.enable = true;
}

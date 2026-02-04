{ pkgs, ... }:

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
    stow
    krita
    libnotify
    efibootmgr
    cava 
    spotify-player
    hyfetch
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
    inkscape
    pencil
  ];
 
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

  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  programs.steam.enable = true;

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  services.flatpak.enable = true;
}

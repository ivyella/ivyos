{ config, pkgs, lib, inputs, greeterPath, ... }:
let
  qs = pkgs.quickshell;
  ivyshell = inputs.ivyshell.packages.${pkgs.system}.default;
  sddmTheme = pkgs.stdenv.mkDerivation {
    name = "pixie-sddm";
    src = ../ivyshell/greeter;
    installPhase = ''
      mkdir -p $out/share/sddm/themes/pixie
      cp -r * $out/share/sddm/themes/pixie/
    '';
  };
in
{
  environment.systemPackages = [
    pkgs.wlsunset
    qs
    ivyshell
    pkgs.xwayland-satellite
    sddmTheme
    pkgs.kdePackages.qtdeclarative
    pkgs.kdePackages.qtsvg
  ];

  services.dbus.enable = true;
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config = {
      common.default = "gnome";
    };
  };

  programs.niri = {
    enable = true;
    package = pkgs.unstable.niri;
  };

  services.displayManager.sddm = {
    enable = true;
    theme = "pixie";
    wayland.enable = true;
  };
}
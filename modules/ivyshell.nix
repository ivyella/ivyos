{ config, pkgs, lib, inputs, greeterPath, ... }:
let
  qs = pkgs.quickshell;
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
    pkgs.xwayland-satellite
    sddmTheme
    pkgs.kdePackages.qtdeclarative
    pkgs.kdePackages.qtsvg
    (pkgs.callPackage ../ivyshell/shellv2/package.nix { })
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

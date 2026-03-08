{ config, pkgs, lib, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    quickshell
    xwayland-satellite
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
  programs.niri.enable = true;

  # expose greeter config to the greeter system user
  environment.etc."ivyshell-greeter" = {
    source = /home/ivy/ivyos/ivyshell/greeter;
    mode = "0755";
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.quickshell}/bin/qs --config /etc/ivyshell-greeter/shell.qml";
        user = "greeter";
      };
    };
  };
}

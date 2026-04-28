{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama-rocm; 
    acceleration = "rocm";
    rocmOverrideGfx = "11.0.2";
  };

  home-manager.users.ivy = {
    home.packages = [ pkgs.unstable.opencode ];
  };
}
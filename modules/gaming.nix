{ config, pkgs, lib, ... }:
{
 	#nixpkgs.config.permittedInsecurePackages = [
   # 	"nexusmods-app-0.21.1"
  	#];

   environment.systemPackages = with pkgs; [
   	steam
     	protonplus
      heroic
      vitetris
   #   nexusmods-app
      prismlauncher
      aria2
   ];

   programs.steam = {
      enable = true;
   };
}

{ config, pkgs, lib, ... }:
{
  	environment.systemPackages = with pkgs; [
    	krita
    	aseprite
     	blockbench
      penpot-desktop
      obsidian
   ];
}

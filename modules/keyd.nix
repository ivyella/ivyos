{ config, pkgs, lib, ... }:
{
  	environment.systemPackages = with pkgs; [
    	keyd
   ];

   services.keyd = {
    	enable = true;
     	keyboards = {
      	default = {
        		ids = [ "05ac:024f" ];
          	settings = {
           		main = {
	            	brightnessdown = "f1";
	             	brightnessup   = "f2";
	              	scale          = "f3";
	               dashboard      = "f4";
	               kbdillumdown   = "f5";
	               kbdillumup     = "f6";
	               previoussong   = "f7";
	               playpause      = "f8";
	               nextsong       = "f9";
	               mute           = "f10";
	               volumedown     = "f11";
	               volumeup       = "f12";
	            };
	            fn = {
	            	brightnessdown = "brightnessdown";
	             	brightnessup   = "brightnessup";
	             	scale          = "scale";
	              	dashboard      = "dashboard";
	               kbdillumdown   = "kbdillumdown";
	               kbdillumup     = "kbdillumup";
	               previoussong   = "previoussong";
	               playpause      = "playpause";
	               nextsong       = "nextsong";
	               mute           = "mute";
	               volumedown     = "volumedown";
	               volumeup       = "volumeup";
	            };
           	};
       	};
      };
   };
}

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
}

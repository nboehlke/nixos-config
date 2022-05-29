{ config, pkgs, ... }:

with pkgs;

{
  # just installed for ConBee firmware updates
  environment.systemPackages = with pkgs; [ (qt5.callPackage ./deconz.nix { }) ];

  services.nginx = {
    virtualHosts = {
      "home.niklas-boehlke.de" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:8123";
          proxyWebsockets = true;
        };
      };
    };
  };


  services.home-assistant = {
    enable = true;
    openFirewall = true;
    config = {
      homeassistant = {
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = 17;
        unit_system = "metric";
        temperature_unit = "C";
	time_zone = "Europe/Berlin";
        external_url = "https://home.niklas-boehlke.de";
      #IP hinzufügen 
        internal_url = "http://192.168.178.1:8123";
      };
      default_config = { };
      config = { };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" "::1" ];
      };
      "automation editor" = "!include automations.yaml";
      "scene editor" = "!include scenes.yaml";
      "script editor" = "!include scripts.yaml";
      automation = { };
      frontend = { };
      mobile_app = { };
      discovery = { };
      zeroconf = { };
      ssdp = { };
      shopping_list = { };
      zha = {
        database_path = "/var/lib/hass/zigbee.db";
        zigpy_config = { 
	    ota = { 
	    ikea_provider = true; 
	    ledvance_provider = true; 
	    }; 
        };
      };
      alarm_control_panel = [{
        platform = "manual";
        code = "!secret alarm_code";
        arming_time = 30;
        delay_time = 20;
        trigger_time = 120;
        disarmed = { trigger_time = 0; };
        armed_home = {
          arming_time = 0;
          delay_time = 0;
        };
      }];

    };
   # not working
   # configWritable = true;
  };
}

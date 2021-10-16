{ config, pkgs, lib, ... }:

let 
   nextcloudHost = "cloud.niklas-boehlke.de";
in
{
  services.nextcloud = {
    enable = true;
    https = true;
    package = pkgs.nextcloud22;
    maxUploadSize = "10G";
    hostName = nextcloudHost;
    config = {
      overwriteProtocol = "https";
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      adminpassFile = "/etc/nixos/secrets/nextcloudPw";
      adminuser = "root";
    };
   home = "/data/nextcloud";
 };

  services.nginx = {
    virtualHosts."${nextcloudHost}" = {
      enableACME = true;
      forceSSL = true;
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
     { name = "nextcloud";
       ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
     }
    ];
  };

  # ensure that postgres is running *before* running the setup
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

}


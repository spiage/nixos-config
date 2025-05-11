{ pkgs, ... }:
{

    services = {
      # Network shares
      samba = {
        package = pkgs.samba4Full;
        # ^^ `samba4Full` is compiled with avahi, ldap, AD etc support (compared to the default package, `samba`
        # Required for samba to register mDNS records for auto discovery 
        # See https://github.com/NixOS/nixpkgs/blob/592047fc9e4f7b74a4dc85d1b9f5243dfe4899e3/pkgs/top-level/all-packages.nix#L27268
        enable = true;
        openFirewall = true;
        # shares.testshare = {
        #   path = "/path/to/share";
        #   writable = "true";
        #   comment = "Hello World!";
        # };
        # extraConfig = ''
        #   server smb encrypt = required
        #   # ^^ Note: Breaks `smbclient -L <ip/host> -U%` by default, might require the client to set `client min protocol`?
        #   server min protocol = SMB3_00
        # '';
      };
      avahi = {
        publish.enable = true;
        publish.userServices = true;
        # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
        nssmdns4 = true;
        # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
        enable = true;
        openFirewall = true;
      };
      samba-wsdd = {
      # This enables autodiscovery on windows since SMB1 (and thus netbios) support was discontinued
        enable = true;
        openFirewall = true;
      };
    };

  # services.samba = {
  #   enable = true;
  #   openFirewall = true;
  #   settings = {
  #     global = {
  #       "workgroup" = "WORKGROUP";
  #       "server string" = "smbnix";
  #       "netbios name" = "smbnix";
  #       "security" = "auto";
  #       #"use sendfile" = "yes";
  #       #"max protocol" = "smb2";
  #       # note: localhost is the ipv6 localhost ::1
  #       "hosts allow" = "192.168.0. 127.0.0.1 localhost";
  #       "hosts deny" = "0.0.0.0/0";
  #       "guest account" = "nobody";
  #       "map to guest" = "bad user";
  #     };
  #   };
  # };

  # services.samba-wsdd = {
  #   enable = true;
  #   openFirewall = true;
  # };

  # services.avahi = {
  #   publish.enable = true;
  #   publish.userServices = true;
  #   # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
  #   nssmdns4 = true;
  #   # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
  #   enable = true;
  #   openFirewall = true;
  # };

  # # networking.firewall.enable = true;
  # networking.firewall.allowPing = true;
}
{ pkgs, ... }:
{
  # Принтеры и сканеры для всех десктопов
  # Включает: sane, airscan, Avahi, CUPS

  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.sane-airscan ];

  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.ipv6 = false;

  services.printing.enable = true;
}

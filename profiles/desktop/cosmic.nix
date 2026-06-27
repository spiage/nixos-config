{ pkgs, ... }:
{
  # KDE Plasma 6 с Wayland для всех десктопов
  # Включает: X11, раскладку, SDDM, автологин, libinput

  services.xserver.enable = true;
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:win_space_toggle";

  # Enable the COSMIC login manager
  services.displayManager.cosmic-greeter.enable = true;

  # Enable the COSMIC desktop environment
  services.desktopManager.cosmic.enable = true;

  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  # services.displayManager.plasma-login-manager.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "spiage";

  services.libinput.enable = true;

  programs.kdeconnect.enable = true;

  services.orca.enable = false;

}

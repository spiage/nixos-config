{ config, lib, pkgs, ... }:
{
  # Профиль для ноутбуков с WiFi

  # Отключаем systemd-networkd в пользу NetworkManager
  networking.useNetworkd = lib.mkForce false;
  networking.networkmanager.enable = true;

  # Управление питанием
  services.thermald.enable = true;
  services.tlp.enable = lib.mkDefault true;

  # Сенсоры (для ноутбуков с акселерометром/датчиками освещения)
  hardware.sensor.iio.enable = lib.mkDefault true;

  # Suspend/hibernate поддержка
  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchExternalPower = "ignore";

  # X11 настройки
  services.xserver.enable = lib.mkDefault true;
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:win_space_toggle";

  # Дополнительные пакеты для ноутбуков
  environment.systemPackages = with pkgs; [
    networkmanagerapplet # Tray applet для NetworkManager
    brightnessctl # Управление яркостью
  ];
}

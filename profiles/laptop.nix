{ config, lib, pkgs, ... }:
{
  # Профиль для ноутбуков с WiFi

  # Отключаем systemd-networkd в пользу NetworkManager
  networking.useNetworkd = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce true;

  # Датчики (акселерометр, освещённость и т.д.)
  hardware.sensor.iio.enable = true;
}
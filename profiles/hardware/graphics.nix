{ lib, ... }:
{
  # Базовая настройка графики для всех десктопов
  # Включает аппаратное ускорение, отключает 32-битную поддержку

  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = lib.mkForce false;
  };
}

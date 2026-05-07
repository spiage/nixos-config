{ pkgs, ... }:
{
  # Базовый набор пакетов для всех десктопов
  # Включает: мониторинг, утилиты, KDE приложения, браузеры
  services.flatpak.enable = true;
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    # Мониторинг и диагностика
    btop
    fastfetch
    lm_sensors
    lsof
    hw-probe
    inxi
    mesa-demos
    gpu-viewer

    # Утилиты
    mc
    git
    ffmpeg

    # Браузеры
    google-chrome

    # Мессенджеры
    telegram-desktop

    # IDE
    vscode

    # KDE Plasma
    kdePackages.plasma-workspace-wallpapers
    pavucontrol
    kdePackages.ktorrent
    mpv
    kdePackages.dragon
    kdePackages.kcalc
    kdePackages.skanpage
    kdePackages.konsole

    # Nix tools
    nix-tree
    nvd

    # Архиваторы
    p7zip
    rar

    # Сетевые утилиты
    bridge-utils
    wget
    inetutils
    usbutils

    # Диагностика
    dmidecode
    pciutils
    clinfo
    vulkan-tools

    # Прошивки и диски
    fwupd
    nvme-cli

    # Мультимедиа
    vlc

    # Удалённый доступ
    # remmina # will use flatpak version

    # Языки программирования
    python3

    # Управление CPU
    zenstates
  ];
}

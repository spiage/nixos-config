{ ... }:
{
  # Звук через Pipewire для всех десктопов
  # Заменяет PulseAudio, совместим с ALSA

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
}

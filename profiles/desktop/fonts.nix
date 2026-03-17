{ pkgs, ... }:
{
  # Базовый набор шрифтов для всех десктопов
  # Включает: кириллицу, CJK, эмодзи, моноширинные для кода, терминальные

  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    # Основные шрифты с поддержкой кириллицы
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    dejavu_fonts

    # Моноширинные шрифты для кода
    fira-code
    fira-code-symbols
    cascadia-code

    # Терминальные шрифты
    terminus_font
    terminus_font_ttf
    nerd-fonts.terminess-ttf

    # Дополнительные
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    freefont_ttf
    gyre-fonts
    unifont
  ];
}

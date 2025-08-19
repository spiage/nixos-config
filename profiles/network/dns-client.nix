{
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade"; # Лучше чем "false" для баланса безопасности
    extraConfig = ''
      DNS=192.168.1.18  # q1 как основной DNS
      Domains=k8s.local  # Домен для поиска
      DNSOverTLS=opportunistic
    '';
    fallbackDns = [
      "192.168.1.1" # Роутер как первый резерв
      "1.1.1.1" # Cloudflare как внешний резерв
    ];
    domains = [ "~k8s.local" ]; # Только для k8s.local
  };
}

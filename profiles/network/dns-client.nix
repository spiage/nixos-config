{
  services.resolved = {
    enable = true;
    settings.Resolve.DNSSEC = "allow-downgrade"; # Лучше чем "false" для баланса безопасности
    settings.Resolve.DNS = "192.168.1.18" ; # q1 как основной DNS
    #   Domains=k8s.local  # Домен для поиска
    #   DNSOverTLS=opportunistic
    # '';
    settings.Resolve.LLMNR = "no";
    settings.Resolve.ResolveUnicastSingleLabel = "yes";
    settings.Resolve.Cache = "no-negative";
    settings.Resolve.FallbackDNS = [
      "192.168.1.1" # Роутер как первый резерв
      "1.1.1.1" # Cloudflare как внешний резерв
    ];
    settings.Resolve.Domains = [ "~. ~k8s.local" ]; # Только для k8s.local
  };
}

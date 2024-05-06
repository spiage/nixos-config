cd /etc/nixos/ && nix flake update && nixos-rebuild -v --keep-going --keep-failed switch --flake . && nix profile diff-closures --profile /nix/var/nix/profiles/system && nvd diff /run/booted-system /run/current-system
date
df -i /

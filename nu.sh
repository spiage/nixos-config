while true
do
date
nix flake update && nixos-rebuild -v -j 1 --keep-going --keep-failed build --flake . && nix profile diff-closures --profile /nix/var/nix/profiles/system && nvd diff /run/current-system ./result
date
df -i / && df -h /
sleep 600
done

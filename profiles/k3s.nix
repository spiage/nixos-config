{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    k9s
    kompose
    kubectl
    kubernetes
    kubernetes-helm
    kubernetes-metrics-server
  ];

  services.k3s = {
    enable = true;
    role = "server";
    token = "Ee1ySKGVulT61yhl2hRDgXVP33OC8R0P";
    serverAddr = "https://192.168.1.2:6443";
    extraFlags = "--write-kubeconfig-mode=644";
  };  
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 
    2049 #NFSv4
    49152 #libvirt live migration direct connect
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    9100 # found input from a7
    10250 # found input from i9
    7946 # found
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
}
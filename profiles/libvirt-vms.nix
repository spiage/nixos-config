# profiles/libvirt-vms.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  mkVM =
    {
      name,
      user,
      sshKey,
      cpus,
      memory,
      diskSize,
      osVariant ? "ubuntu24.04",
    }:
    let
      user-data = pkgs.writeText "${name}-user-data" ''
        #cloud-config
        users:
          - name: ${user}
            sudo: ALL=(ALL) NOPASSWD:ALL
            shell: /bin/bash
            ssh_authorized_keys:
              - ${sshKey}
        ssh_pwauth: false
      '';

      meta-data = pkgs.writeText "${name}-meta-data" ''
        instance-id: ${name}
        local-hostname: ${name}
      '';

      baseImage = pkgs.fetchurl {
        url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img";
        sha256 = "sha256-..."; # Обновить актуальный хеш
      };

    in
    {
      virtualisation.libvirtd.enable = true;

      systemd.services."create-vm-${name}" = {
        description = "Create VM ${name}";
        wantedBy = [ "multi-user.target" ];
        after = [
          "network.target"
          "libvirtd.service"
        ];
        script = ''
          if ! virsh list --all | grep -q ${name}; then
            virt-install \
              --name ${name} \
              --vcpus ${toString cpus} \
              --memory ${toString memory} \
              --disk path=/var/lib/libvirt/images/${name}.qcow2,backing_store=${baseImage},size=${toString diskSize} \
              --network bridge=br0,model=virtio \
              --os-variant ${osVariant} \
              --cloud-init user-data=${user-data},meta-data=${meta-data} \
              --noautoconsole \
              --import
          fi
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    };

in
{
  options.virtualMachines = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          options = {
            user = lib.mkOption { type = lib.types.str; };
            sshKey = lib.mkOption { type = lib.types.path; };
            cpus = lib.mkOption {
              type = lib.types.int;
              default = 2;
            };
            memory = lib.mkOption { type = lib.types.int; }; # в МБ
            diskSize = lib.mkOption { type = lib.types.int; }; # в ГБ
            osVariant = lib.mkOption {
              type = lib.types.str;
              default = "ubuntu24.04";
            };
          };
        }
      )
    );
  };

  config = lib.mkMerge (
    lib.mapAttrsToList (
      vmName: vmConfig:
      mkVM {
        name = vmName;
        user = vmConfig.user;
        sshKey = builtins.readFile vmConfig.sshKey;
        cpus = vmConfig.cpus;
        memory = vmConfig.memory;
        diskSize = vmConfig.diskSize;
        osVariant = vmConfig.osVariant;
      }
    ) config.virtualMachines
  );
}

{
  provider.libvirt.uri = "qemu:///system";

  resource."libvirt_volume"."nixos-iso" = {
    name = "nixos-gnome.iso";
    pool = "default";
    source = "https://releases.nixos.org/nixos/21.11/nixos-21.11.336811.0aac710801a/nixos-gnome-21.11.336811.0aac710801a-x86_64-linux.iso";
  };

  resource."libvirt_domain"."nixos" = {
    name = "nixos";
    memory = "4096";
    vcpu = 6;

    network_interface = {
      network_name = "default";
    };

    disk = {
      volume_id = "\${libvirt_volume.nixos-iso.id}";
    };

    graphics = {
      type = "spice";
      listen_type = "address";
      autoport = true;
    };
  };
}

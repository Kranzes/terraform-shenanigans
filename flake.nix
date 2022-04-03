{
  inputs = {
    terranix = { url = "github:terranix/terranix"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, terranix }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      terraform = (pkgs.terraform.withPlugins (plugins: [ plugins.libvirt ]));
      terraformConfiguration = terranix.lib.terranixConfiguration {
        inherit system;
        modules = [ ./config.nix ];
      };
    in
    {
      defaultPackage.${system} = terraformConfiguration;
      devShell.${system} = pkgs.mkShell { packages = with pkgs; [ terraform terranix.defaultPackage.${system} ]; };
      apps.${system} = {
        apply = {
          type = "app";
          program = toString (pkgs.writers.writeBash "apply" ''
            if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
            cp ${terraformConfiguration} config.tf.json \
              && ${terraform}/bin/terraform init \
              && ${terraform}/bin/terraform apply
          '');
        };
        destroy = {
          type = "app";
          program = toString (pkgs.writers.writeBash "destroy" ''
            if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
            cp ${terraformConfiguration} config.tf.json \
              && ${terraform}/bin/terraform init \
              && ${terraform}/bin/terraform destroy
          '');
        };
      };
    };
}


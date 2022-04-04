{
  inputs = {
    terranix = { url = "github:terranix/terranix"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, terranix }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      terraform = (pkgs.terraform.withPlugins (plugins: [ plugins.docker ]));
      terraformConfiguration = terranix.lib.terranixConfiguration {
        inherit system;
        modules = [
          ./providers.nix
          ./docker.nix
        ];
      };
    in
    {
      defaultPackage.${system} = terraformConfiguration;
      devShell.${system} = pkgs.mkShell { packages = with pkgs; [ terraform terranix.defaultPackage.${system} ]; };
      apps.${system} = {
        apply = {
          type = "app";
          program = toString (pkgs.writeShellScript "apply" ''
            DIR=$(mktemp -d)
            ln -s ${terraformConfiguration} $DIR/config.tf.json
            ${terraform}/bin/terraform -chdir=$DIR init
            ${terraform}/bin/terraform -chdir=$DIR apply
          '');
        };
        destroy = {
          type = "app";
          program = toString (pkgs.writeShellScript "destroy" ''
            DIR=$(mktemp -d)
            ln -s ${terraformConfiguration} $DIR/config.tf.json
            ${terraform}/bin/terraform -chdir=$DIR init
            ${terraform}/bin/terraform -chdir=$DIR destroy
          '');
        };
      };
    };
}


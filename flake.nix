{
  inputs = {
    terranix = { url = "github:terranix/terranix"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, terranix }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShell.${system} = pkgs.mkShell {
        packages = with pkgs; [ (terraform.withPlugins (plugins: [ plugins.libvirt ])) ];
      };
      defaultPackage.${system} = terranix.lib.terranixConfiguration {
        inherit system;
        modules = [ ./config.nix ];
      };
    };
}


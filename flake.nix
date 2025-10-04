{
  description = "a gleam project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${ system };
      in
      {
        devShell = with pkgs; pkgs.mkShell {
          buildInputs = [
            gleam
          ];
        };
      }
    );
}



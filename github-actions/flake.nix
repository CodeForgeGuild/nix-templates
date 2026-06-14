{
  description = "Bootstrap shared GitHub Actions workflows from CodeForgeGuild/ci-actions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bash
            curl
            gh
          ];

          shellHook = ''
            echo "GitHub Actions bootstrap shell ready"
            echo "Running workflow downloader..."
            bash ./download-workflows.sh
          '';
        };
      }
    );
}

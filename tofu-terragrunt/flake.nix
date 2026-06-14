{
  description = "IaC environment with OpenTofu and Terragrunt";

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
            opentofu
            terragrunt
            tflint
          ];
          shellHook = ''
            echo "☁️  OpenTofu & Terragrunt"
            echo "  tofu       $(tofu --version | head -n1)"
            echo "  terragrunt $(terragrunt --version)"
            echo "  tflint     $(tflint --version | head -n1)"
          '';
        };
      }
    );
}

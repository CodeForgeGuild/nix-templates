{
  description = "Go development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
            go
            golangci-lint
            pre-commit
            buf
          ];

          shellHook = ''
            echo "🚀 Go Development Environment"
            echo "  go        $(go version | cut -d' ' -f3)"
            echo "  lint      $(golangci-lint --version | head -n1)"
            echo "  buf       $(buf --version)"

            export GOPATH="$HOME/go"
            export PATH="$GOPATH/bin:$PATH"

            if [ ! -f go.mod ]; then
              echo "🚨 No go.mod found — initialising module..."
              go mod init "$(basename "$(pwd)")"
              mkdir -p cmd internal docker infra
              touch docker/Dockerfile docker-compose.yaml env.sample
            fi

            if [ ! -f .gitignore ]; then
              cat > .gitignore << 'EOF'
.env
.direnv
bin/
buf.lock
*.test
*.out
coverage.xml
golangci-lint.xml
go.work
go.work.sum
result*
EOF
            fi

            [ ! -f .env ] && [ -f env.sample ] && cp env.sample .env

            if [ -f .env ]; then
              set -a; source .env; set +a
            fi

            go mod download
            pre-commit install-hooks
          '';
        };
      }
    );
}

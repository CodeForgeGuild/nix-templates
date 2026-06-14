{
  description = "Python 3 development environment with uv";

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
            uv
            pre-commit
          ];

          shellHook = ''
            echo "🚀 Python Development Environment"
            echo "  uv         $(uv --version)"
            echo "  pre-commit $(pre-commit --version)"

            if [ ! -f pyproject.toml ]; then
              echo "🚨 No pyproject.toml found — initialising project..."
              uv init
              uv add --group dev debugpy mypy[report] lxml ruff pytest pytest-cov pre-commit

              cat >> pyproject.toml << 'EOF'

[tool.ruff]
line-length = 90
target-version = "py311"
src = ["src", "cmd"]
fix = true

[tool.ruff.lint]
fixable = ["ALL"]
select = ["E", "W", "F", "I", "C", "B", "UP", "N", "RUF", "D"]
ignore = ["E203", "E501", "B028"]

[tool.ruff.lint.pydocstyle]
convention = "google"

[tool.ruff.lint.isort]
known-first-party = ["src", "cmd"]
combine-as-imports = true

[tool.ruff.lint.per-file-ignores]
"__init__.py" = ["F401"]
"tests/*" = ["D"]

[tool.mypy]
check_untyped_defs = true
python_version = "3.11"
ignore_missing_imports = true
exclude = ["tests"]
xml_report = "mypy.xml"
packages = ["src", "cmd"]
EOF

              mkdir -p src cmd infra docker
              touch src/__init__.py cmd/__init__.py docker/Dockerfile docker-compose.yaml env.sample
            fi

            if [ ! -f .gitignore ]; then
              cat > .gitignore << 'EOF'
__pycache__/
*.py[cod]
*.so
build/
dist/
*.egg-info/
.eggs/
htmlcov/
.coverage
.coverage.*
coverage.xml
.pytest_cache/
ruff.xml
mypy.xml
.env
.venv
env/
venv/
.mypy_cache/
.pyre/
.pytype/
.direnv
.vscode/
.idea/
.DS_Store
*.log
*.db
EOF
            fi

            [ ! -f .env ] && [ -f env.sample ] && cp env.sample .env

            if [ -f .env ]; then
              set -a; source .env; set +a
            fi

            uv sync --group dev --frozen
            pre-commit install
          '';
        };
      }
    );
}

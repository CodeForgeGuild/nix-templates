# nix-templates

Nix flake templates to bootstrap new repos. Run one command, get a fully configured dev shell with tooling, pre-commit hooks, and CI workflows ready to go.

## Usage

```bash
# Initialize a repo with a template
nix flake init -t github:CodeForgeGuild/nix-templates#<template>

# Then allow direnv
direnv allow
```

## Templates

### `basic`
Minimal dev shell with git.

```bash
nix flake init -t github:CodeForgeGuild/nix-templates#basic
```

---

### `go`
Go development environment with golangci-lint, buf, and pre-commit.

On first `direnv allow` it will:
- Create `go.mod` (if missing), scaffolding `cmd/`, `internal/`, `docker/`, `infra/`
- Write a `.gitignore`
- Download Go dependencies and install pre-commit hooks

Includes GitHub Actions workflows:
- `ci.yml` — lint (golangci-lint) + tests on PRs and pushes to main
- `ci-trivy.yml` — Trivy security scan on PRs
- `ci-release.yml` — auto-semver release on PR merge (via PR labels `increment-major` / `increment-minor`)
- `deploy.yml` — build Docker image to GHCR and deploy to GCP VM on tag push

```bash
nix flake init -t github:CodeForgeGuild/nix-templates#go
```

---

### `python`
Python 3 environment with uv, ruff, mypy, and pre-commit.

On first `direnv allow` it will:
- Run `uv init` and add dev dependencies (ruff, mypy, pytest, debugpy…)
- Append ruff/mypy config to `pyproject.toml`
- Write a `.gitignore` and scaffold `src/`, `cmd/`, `docker/`, `infra/`
- Install pre-commit hooks

Includes GitHub Actions workflows:
- `ci.yml` — ruff + mypy + pytest on PRs and pushes to main
- `ci-trivy.yml` — Trivy security scan on PRs
- `ci-release.yml` — auto-semver release on PR merge
- `deploy.yml` — build Docker image to GHCR and deploy to GCP VM on tag push

```bash
nix flake init -t github:CodeForgeGuild/nix-templates#python
```

---

### `tofu-terragrunt`
Shell with OpenTofu, Terragrunt, and tflint. Use together with the `infra` template for the Terraform module files.

```bash
nix flake init -t github:CodeForgeGuild/nix-templates#tofu-terragrunt
```

---

### `infra`
OpenTofu/Terraform module skeleton targeting GCP with a GCS backend and KMS encryption.

Files: `backend.tf`, `provider.tf`, `variables.tf`, `versions.tf`, `terragrunt.hcl`.

Fill in the `<PLACEHOLDER>` values in `backend.tf` before running `tofu init`.

```bash
nix flake init -t github:CodeForgeGuild/nix-templates#infra
```

---

### `github-actions`
One-shot bootstrap that downloads shared CI workflows from [CodeForgeGuild/ci-actions](https://github.com/CodeForgeGuild/ci-actions) into `.github/workflows/` and then removes itself.

Default downloads: `ci-trivy.yml`, `ci-release.yml`.

Override via env vars before entering the shell:

```bash
# Optional overrides
export WORKFLOWS_REPO="CodeForgeGuild/ci-actions"
export WORKFLOWS_REF="v0"
export WORKFLOWS_FILES="ci-trivy.yml ci-release.yml"
export KEEP_BOOTSTRAP_FILES=1  # set to 1 to keep flake.nix/.envrc after download

nix flake init -t github:CodeForgeGuild/nix-templates#github-actions
direnv allow
```

---

### `sonar`
SonarQube project config and CI workflows.

Files:
- `sonar-project.properties` — fill in `sonar.projectKey` and optionally `sonar.organization`
- `.github/workflows/ci-sonar.yml` — SonarQube scan + Quality Gate on PRs (uses `SonarSource/sonarqube-scan-action`)
- `.github/workflows/ci-trivy.yml` — Trivy scan on PRs

Uncomment the Go or Python block inside `ci-sonar.yml` to run linting and tests before the scan.

Required secrets: `SONAR_TOKEN`, `SONAR_HOST_URL`.

```bash
nix flake init -t github:CodeForgeGuild/nix-templates#sonar
```

---

## CI Actions

Reusable workflows live in [CodeForgeGuild/ci-actions](https://github.com/CodeForgeGuild/ci-actions). The templates reference them at `@v0`.

| Workflow | Trigger |
|---|---|
| `trivy-scan.yml` | Security scan (fs + Docker image) with PR comment |
| `release.yml` | Semver tag from PR labels (`increment-major` / `increment-minor` / default patch) |
| `build-push-deploy.yml` | Build & push to GHCR, SSH deploy to GCP VM |

## Requirements

- [Nix](https://nixos.org/download) with flakes enabled
- [direnv](https://direnv.net/) with the nix-direnv hook

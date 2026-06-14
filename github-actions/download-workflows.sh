#!/usr/bin/env bash
set -euo pipefail

# Default source: CodeForgeGuild/ci-actions
# Override any of these via environment variables before entering the shell.
WORKFLOWS_REPO="${WORKFLOWS_REPO:-CodeForgeGuild/ci-actions}"
WORKFLOWS_REF="${WORKFLOWS_REF:-v0}"
# Space-separated list of workflow filenames to download.
WORKFLOWS_FILES="${WORKFLOWS_FILES:-ci-trivy.yml ci-release.yml}"
KEEP_BOOTSTRAP_FILES="${KEEP_BOOTSTRAP_FILES:-0}"
GITHUB_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"

if [ -z "$WORKFLOWS_REPO" ]; then
  echo "Skipping: set WORKFLOWS_REPO (e.g. my-org/reusable-workflows)"
  exit 0
fi

if [ -z "$WORKFLOWS_FILES" ]; then
  echo "Skipping: set WORKFLOWS_FILES (e.g. \"ci-trivy.yml ci-release.yml\")"
  exit 0
fi

mkdir -p .github/workflows

download_file() {
  local source_path="$1"
  local destination="$2"
  local source_url="https://raw.githubusercontent.com/${WORKFLOWS_REPO}/${WORKFLOWS_REF}/${source_path}"
  local api_url="https://api.github.com/repos/${WORKFLOWS_REPO}/contents/${source_path}?ref=${WORKFLOWS_REF}"

  if [ -f "$destination" ]; then
    echo "Skipping existing $destination"
    return
  fi

  echo "Downloading $(basename "$destination") ..."

  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    if ! gh api \
      -H "Accept: application/vnd.github.raw" \
      "/repos/${WORKFLOWS_REPO}/contents/${source_path}?ref=${WORKFLOWS_REF}" \
      > "$destination"; then
      echo "Failed to download ${source_path} via gh. Check repo access, branch and path." >&2
      exit 1
    fi
    return
  fi

  if [ -n "$GITHUB_TOKEN" ]; then
    if ! curl -fsSL \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H "Accept: application/vnd.github.raw" \
      "$api_url" \
      -o "$destination"; then
      echo "Failed to download ${source_path} from ${WORKFLOWS_REPO}@${WORKFLOWS_REF}" >&2
      exit 1
    fi
    return
  fi

  echo "No gh session or token — trying public URL: $source_url"
  if ! curl -fsSL "$source_url" -o "$destination"; then
    echo "Failed to download ${source_path}." >&2
    echo "If ${WORKFLOWS_REPO} is private, run 'gh auth login' or export GITHUB_TOKEN/GH_TOKEN." >&2
    exit 1
  fi
}

for file_name in $WORKFLOWS_FILES; do
  download_file ".github/workflows/${file_name}" ".github/workflows/${file_name}"
done

echo "Workflow download completed."

if [ "$KEEP_BOOTSTRAP_FILES" = "1" ]; then
  echo "Keeping bootstrap files (KEEP_BOOTSTRAP_FILES=1)"
  exit 0
fi

echo "Cleaning bootstrap files..."
rm -f flake.nix .envrc flake.lock
rm -f -- "${BASH_SOURCE[0]}"
echo "Bootstrap files removed."

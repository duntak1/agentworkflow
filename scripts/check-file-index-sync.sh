#!/usr/bin/env bash
# Gate: business code file additions/deletions/renames require docs/FILE_INDEX.md refresh.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

is_business_file() {
  local path="$1"
  case "$path" in
    docs/*|agent-workflow/*|skill/*|reference/*|dist/*|node_modules/*|.git/*|*.md) return 1 ;;
    package-lock.json|pnpm-lock.yaml|yarn.lock|Cargo.lock|go.sum) return 1 ;;
  esac
  case "$path" in
    src/*|app/*|apps/*|packages/*|frontend/*|backend/*|server/*|api/*|services/*|lib/*|shared/*|common/*|test/*|tests/*|__tests__/*|cypress/*|e2e/*) return 0 ;;
    package.json|vite.config.*|next.config.*|nuxt.config.*|tsconfig*.json|eslint.config.*|tailwind.config.*|postcss.config.*) return 0 ;;
    pom.xml|build.gradle|settings.gradle|gradle.properties|go.mod|pyproject.toml|requirements.txt|Dockerfile|docker-compose*.yml|docker-compose*.yaml) return 0 ;;
    *.ts|*.tsx|*.js|*.jsx|*.vue|*.java|*.kt|*.go|*.py|*.rs|*.cs|*.php|*.rb) return 0 ;;
  esac
  return 1
}

if ! git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  echo "skip: not a git repository"
  exit 0
fi

changes="$(git -C "$ROOT" diff --name-status --cached 2>/dev/null || true)"
if [[ -z "$changes" ]]; then
  changes="$(git -C "$ROOT" diff --name-status 2>/dev/null || true)"
fi

[[ -n "$changes" ]] || { echo "ok  no changed files"; exit 0; }

needs_index=false
file_index_changed=false
while IFS=$'\t' read -r status a b extra; do
  [[ -n "${status:-}" ]] || continue
  [[ "$a" == "docs/FILE_INDEX.md" || "$b" == "docs/FILE_INDEX.md" ]] && file_index_changed=true
  case "$status" in
    A|D|R*|C*)
      if is_business_file "$a" || { [[ -n "${b:-}" ]] && is_business_file "$b"; }; then
        needs_index=true
      fi
      ;;
  esac
done <<< "$changes"

if $needs_index && ! $file_index_changed; then
  echo "block: business code file added/deleted/renamed but docs/FILE_INDEX.md was not updated" >&2
  echo "  run: ./scripts/aw file-index" >&2
  exit 1
fi

[[ -f "${ROOT}/docs/FILE_INDEX.md" ]] || { echo "block: missing docs/FILE_INDEX.md; run ./scripts/aw file-index" >&2; exit 1; }
echo "file-index gate: ok"

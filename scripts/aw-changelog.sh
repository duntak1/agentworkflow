#!/usr/bin/env bash
# Changelog helper: add/check [Unreleased] entries for traceable commits.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw changelog add --type Added|Changed|Fixed|Removed --message "..."
  aw changelog check
  aw changelog path

Adds entries to the [Unreleased] section. This records change history; it does
not bump version fields or create git tags.
EOF
  exit "${1:-0}"
}

changelog_path() {
  if [[ -f "${ROOT}/agent-workflow/CHANGELOG.md" ]]; then
    echo "${ROOT}/agent-workflow/CHANGELOG.md"
  elif [[ -f "${ROOT}/CHANGELOG.md" ]]; then
    echo "${ROOT}/CHANGELOG.md"
  else
    echo "${ROOT}/CHANGELOG.md"
  fi
}

ensure_changelog() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    mkdir -p "$(dirname "$file")"
    cat > "$file" <<'EOF'
# Changelog

## [Unreleased]

### Added

### Changed

### Fixed

### Removed
EOF
  fi
  if ! grep -q '^## \[Unreleased\]' "$file"; then
    tmp="$(mktemp)"
    awk '
      NR == 1 {
        print
        print ""
        print "## [Unreleased]"
        print ""
        print "### Added"
        print ""
        print "### Changed"
        print ""
        print "### Fixed"
        print ""
        print "### Removed"
        print ""
        next
      }
      { print }
    ' "$file" > "$tmp"
    mv "$tmp" "$file"
  fi
}

normalize_type() {
  case "$1" in
    Added|added|add) echo "Added" ;;
    Changed|changed|change) echo "Changed" ;;
    Fixed|fixed|fix) echo "Fixed" ;;
    Removed|removed|remove) echo "Removed" ;;
    *) echo "" ;;
  esac
}

add_entry() {
  local file="$1" type="$2" message="$3" tmp
  ensure_changelog "$file"
  tmp="$(mktemp)"
  awk -v type="$type" -v message="$message" '
    BEGIN {
      in_unreleased = 0
      inserted = 0
      type_seen = 0
    }
    /^## \[Unreleased\]/ {
      in_unreleased = 1
      print
      next
    }
    in_unreleased && /^## / {
      if (!inserted) {
        if (!type_seen) {
          print ""
          print "### " type
        }
        print ""
        print "- " message
        inserted = 1
      }
      in_unreleased = 0
      print
      next
    }
    in_unreleased && $0 == "### " type {
      type_seen = 1
      print
      print ""
      print "- " message
      inserted = 1
      next
    }
    {
      print
    }
    END {
      if (in_unreleased && !inserted) {
        if (!type_seen) {
          print ""
          print "### " type
        }
        print ""
        print "- " message
      }
    }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

case "$CMD" in
  add)
    type="Changed"
    message=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --type) type="$(normalize_type "${2:-}")"; shift 2 ;;
        --message|-m) message="${2:-}"; shift 2 ;;
        -h|--help) usage 0 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$type" ]] || { echo "error: --type must be Added|Changed|Fixed|Removed" >&2; exit 1; }
    [[ -n "$message" ]] || { echo "error: --message is required" >&2; exit 1; }
    if printf '%s\n' "$message" | grep -Eiq '(api[_-]?key|token|password|passwd|secret)[[:space:]]*[:=]'; then
      echo "error: possible secret detected; do not store secrets in changelog" >&2
      exit 1
    fi
    file="$(changelog_path)"
    add_entry "$file" "$type" "$message"
    echo "updated: ${file#${ROOT}/}"
    ;;
  check)
    file="$(changelog_path)"
    if [[ ! -f "$file" ]]; then
      echo "warn: no CHANGELOG found (run: aw changelog add --type Changed --message \"...\")" >&2
      exit 0
    fi
    echo "== changelog check =="
    echo "file: ${file#${ROOT}/}"
    if grep -q '^## \[Unreleased\]' "$file"; then
      echo "ok  [Unreleased] section"
    else
      echo "missing  [Unreleased] section" >&2
      exit 1
    fi
    if awk '/^## \[Unreleased\]/{flag=1; next} /^## /{flag=0} flag && /^- /{found=1} END{exit found ? 0 : 1}' "$file"; then
      echo "ok  [Unreleased] has at least one entry"
    else
      echo "warn  [Unreleased] has no bullet entries yet"
    fi
    ;;
  path)
    changelog_path | sed "s#^${ROOT}/##"
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac

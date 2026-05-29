#!/usr/bin/env bash
# Compatibility wrapper for provider-neutral VCS lifecycle helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "warn: aw github-pr is deprecated; use aw vcs for GitHub/GitLab/Bitbucket/Gitee/GitCode/Gitea/Forgejo/GitLab CE/Gerrit/Codeup." >&2
exec "${SCRIPT_DIR}/aw-vcs.sh" "$@"

# Windows Support

agent-workflow scripts are POSIX shell scripts. On Windows, use one of:

1. **WSL2**: recommended for full compatibility.
2. **Git Bash**: supported for normal CLI usage.
3. **PowerShell**: call scripts through Git Bash or WSL, for example `bash scripts/aw status`.

Notes:

- Run from the repository root.
- Keep paths relative when possible, such as `docs/dsl/DSL_DRAFT.md`.
- If execution bits are lost after checkout, run `chmod +x scripts/aw scripts/*.sh` inside WSL/Git Bash.
- Native `.ps1` wrappers are not currently shipped.

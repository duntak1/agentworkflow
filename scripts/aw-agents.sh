#!/usr/bin/env bash
# Multi-agent collaboration protocol helper.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_aw-lib.sh
source "${SCRIPT_DIR}/_aw-lib.sh"

ROOT="$(aw_repo_root)"
TEMPLATES="$(aw_templates_dir)"
AGENTS_DIR="${ROOT}/docs/agents"
ROLES="${AGENTS_DIR}/AGENT_ROLES.md"
HANDOFFS="${AGENTS_DIR}/AGENT_HANDOFFS.md"
REVIEWS="${AGENTS_DIR}/AGENT_REVIEWS.md"
LOCKS="${AGENTS_DIR}/AGENT_LOCKS.md"
HEARTBEATS="${AGENTS_DIR}/AGENT_HEARTBEATS.md"
REGISTRY="${AGENTS_DIR}/AGENT_REGISTRY.md"
PRESETS="${AGENTS_DIR}/AGENT_PRESETS.tsv"
CMD="${1:-check}"
shift || true

usage() {
  cat <<'EOF'
Usage:
  aw agents init [--with-defaults]
  aw agents register --id "..." --name "..." --type developer|reviewer|tester|security|release|coordinator|observer --scope "..." [--allowed "..."] [--blocked "..."] [--runtime codex|claude-code|qoderwork|trae|lingma|openclaw|qclaw|...] [--provider openai|anthropic|github|cursor|aliyun|longjia|other] [--workspace path|manual] [--interface cli|desktop|web|ide|api|manual] [--sync-mode local-files|sync-center|handoff-only|manual-paste|none] [--handoff-target "..."] [--binding-status active|paused|unknown] [--notes "..."] [--update]
  aw agents register --preset communicator|businessman|pm|product-plan-review|fullstack|frontend|admin|backend|tester [--update]
  aw agents register --defaults [--update]
  aw agents bind <agent-id> [--runtime "..."] [--provider "..."] [--workspace "..."] [--interface "..."] [--sync-mode "..."] [--handoff-target "..."] [--status active|paused|unknown]
  aw agents unbind <agent-id>
  aw agents unregister <agent-id>
  aw agents list [--bindings]
  aw agents bindings
  aw agents show <agent-id>
  aw agents assign --role developer|reviewer|tester|security|release --owner "..." --scope "..." [--allowed "..."] [--blocked "..."] [--related "REQ/AT-T"]
  aw agents handoff --from "..." --to "..." --related "REQ/AT-T" --scope "..." --done "..." --todo "..." [--risk "..."] [--evidence "..."]
  aw agents review --reviewer "..." --type code|test|security|release --related "REQ/AT-T" --result pass|changes|block [--blockers "..."] [--suggestions "..."] [--evidence "..."]
  aw agents claim --agent "..." --task AT-T... --role frontend|backend|fullstack|qa|docs|ops --scope "..." --allowed "path1,path2" [--ttl-min 120]
  aw agents heartbeat --agent "..." --task AT-T... --status working|blocked|done --action "..." [--blocked "..."] [--next "..."]
  aw agents release --agent "..." --task AT-T... [--notes "..."]
  aw agents lock-check [--task AT-T...]
  aw agents gate [--strict]
  aw agents check
EOF
  exit "${1:-0}"
}

ensure_agents() {
  mkdir -p "$AGENTS_DIR"
  [[ -f "$ROLES" ]] || cp "${TEMPLATES}/agents/AGENT_ROLES.md" "$ROLES"
  [[ -f "$HANDOFFS" ]] || cp "${TEMPLATES}/agents/AGENT_HANDOFFS.md" "$HANDOFFS"
  [[ -f "$REVIEWS" ]] || cp "${TEMPLATES}/agents/AGENT_REVIEWS.md" "$REVIEWS"
  [[ -f "$LOCKS" ]] || cp "${TEMPLATES}/agents/AGENT_LOCKS.md" "$LOCKS"
  [[ -f "$HEARTBEATS" ]] || cp "${TEMPLATES}/agents/AGENT_HEARTBEATS.md" "$HEARTBEATS"
  [[ -f "$REGISTRY" ]] || cp "${TEMPLATES}/agents/AGENT_REGISTRY.md" "$REGISTRY"
  [[ -f "$PRESETS" ]] || cp "${TEMPLATES}/agents/AGENT_PRESETS.tsv" "$PRESETS"
}

insert_after_header() {
  local file="$1" row="$2" tmp
  tmp="$(mktemp)"
  awk -v row="$row" '
    /^\| 时间 \|/ {print; next}
    /^\|------/ && done==0 {print; print row; done=1; next}
    {print}
    END{if(done==0) print row}
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

valid_agent_type() {
  case "$1" in developer|reviewer|tester|security|release|coordinator|observer) return 0 ;; *) return 1 ;; esac
}

valid_runtime() {
  case "$1" in
    codex|claude-code|claude-chat|cursor|cline|windsurf|copilot|continue|generic-chat|manual|qoderwork|qoder|trae|traeide|lingma|openclaw|qclaw) return 0 ;;
    *) return 1 ;;
  esac
}

valid_provider() {
  case "$1" in openai|anthropic|github|cursor|aliyun|longjia|other) return 0 ;; *) return 1 ;; esac
}

valid_interface() {
  case "$1" in cli|desktop|web|ide|api|manual) return 0 ;; *) return 1 ;; esac
}

valid_sync_mode() {
  case "$1" in local-files|sync-center|handoff-only|manual-paste|none) return 0 ;; *) return 1 ;; esac
}

valid_binding_status() {
  case "$1" in active|paused|unknown) return 0 ;; *) return 1 ;; esac
}

agent_section_exists() {
  local agent_id="$1"
  [[ -f "$REGISTRY" ]] || return 1
  awk -v id="$agent_id" '$0 == "## Agent - " id {found=1} END{exit !found}' "$REGISTRY"
}

agent_is_active() {
  local agent_id="$1"
  [[ -f "$REGISTRY" ]] || return 1
  awk -v id="$agent_id" '
    $0 == "## Agent - " id {in_agent=1; found=1; status=""; next}
    in_agent && /^## Agent - / {in_agent=0}
    in_agent && /^- Status:/ {
      status=substr($0, index($0, ":")+1)
      gsub(/^[ \t]+|[ \t]+$/, "", status)
    }
    END{exit !(found && status == "active")}
  ' "$REGISTRY"
}

available_presets() {
  ensure_agents
  awk -F'\t' 'NR > 1 && $1 != "" {out = out (out ? ", " : "") $1} END{print out}' "$PRESETS"
}

read_preset() {
  local preset="$1"
  ensure_agents
  awk -F'\t' -v preset="$preset" '
    NR > 1 && $1 == preset {
      print $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9 "\t" $10 "\t" $11 "\t" $12 "\t" $13 "\t" $14
      found=1
      exit
    }
    END{exit !found}
  ' "$PRESETS"
}

agent_field() {
  local agent_id="$1" field="$2"
  [[ -f "$REGISTRY" ]] || return 0
  awk -v id="$agent_id" -v field="$field" '
    $0 == "## Agent - " id {in_agent=1; next}
    in_agent && /^## Agent - / {in_agent=0}
    in_agent && index($0, "- " field ":") == 1 {
      v=substr($0, index($0, ":")+1)
      gsub(/^[ \t]+|[ \t]+$/, "", v)
      print v
      exit
    }
  ' "$REGISTRY"
}

write_agent_record() {
  local agent_id="$1" name="$2" type="$3" status="$4" scope="$5" allowed="$6" blocked="$7" source="$8" notes="$9" update="${10}" runtime="${11}" provider="${12}" workspace="${13}" interface="${14}" sync_mode="${15}" handoff_target="${16}" binding_status="${17}"
  local now created tmp record
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  created="$now"
  if agent_section_exists "$agent_id"; then
    if [[ "$update" != "true" ]]; then
      echo "error: agent already registered: ${agent_id} (use --update to modify)" >&2
      exit 1
    fi
    created="$(agent_field "$agent_id" "Created at")"
    [[ -n "$created" ]] || created="$now"
    [[ "$runtime" == "unknown" ]] && runtime="$(agent_field "$agent_id" "Runtime")"
    [[ "$provider" == "other" ]] && provider="$(agent_field "$agent_id" "Provider")"
    [[ "$workspace" == "manual" ]] && workspace="$(agent_field "$agent_id" "Workspace")"
    [[ "$interface" == "manual" ]] && interface="$(agent_field "$agent_id" "Interface")"
    [[ "$sync_mode" == "none" ]] && sync_mode="$(agent_field "$agent_id" "Sync mode")"
    [[ "$handoff_target" == "docs/agents/AGENT_HANDOFFS.md" ]] && handoff_target="$(agent_field "$agent_id" "Handoff target")"
    [[ "$binding_status" == "unknown" ]] && binding_status="$(agent_field "$agent_id" "Binding status")"
  fi
  runtime="${runtime:-unknown}"
  provider="${provider:-other}"
  workspace="${workspace:-manual}"
  interface="${interface:-manual}"
  sync_mode="${sync_mode:-none}"
  handoff_target="${handoff_target:-docs/agents/AGENT_HANDOFFS.md}"
  binding_status="${binding_status:-unknown}"
  record="$(mktemp)"
  {
    echo ""
    echo "## Agent - ${agent_id}"
    echo ""
    echo "- Name: ${name}"
    echo "- Type: ${type}"
    echo "- Status: ${status}"
    echo "- Scope: ${scope}"
    echo "- Allowed paths: ${allowed}"
    echo "- Blocked paths: ${blocked}"
    echo "- Runtime: ${runtime}"
    echo "- Provider: ${provider}"
    echo "- Workspace: ${workspace}"
    echo "- Interface: ${interface}"
    echo "- Sync mode: ${sync_mode}"
    echo "- Handoff target: ${handoff_target}"
    echo "- Last seen: ${now}"
    echo "- Binding status: ${binding_status}"
    echo "- Created at: ${created}"
    echo "- Updated at: ${now}"
    echo "- Source: ${source}"
    echo "- Notes: ${notes}"
  } > "$record"
  if agent_section_exists "$agent_id"; then
    tmp="$(mktemp)"
    awk -v id="$agent_id" -v repl="$record" '
      function print_repl() {
        while ((getline line < repl) > 0) print line
        close(repl)
      }
      $0 == "## Agent - " id {
        print_repl()
        skip=1
        next
      }
      skip && /^## Agent - / {
        skip=0
      }
      !skip {print}
    ' "$REGISTRY" > "$tmp"
    mv "$tmp" "$REGISTRY"
  else
    cat "$record" >> "$REGISTRY"
  fi
  rm -f "$record"
}

register_one() {
  local agent_id="$1" name="$2" type="$3" scope="$4" allowed="$5" blocked="$6" source="$7" notes="$8" update="$9" runtime="${10}" provider="${11}" workspace="${12}" interface="${13}" sync_mode="${14}" handoff_target="${15}" binding_status="${16}"
  [[ -n "$agent_id" && -n "$name" && -n "$scope" ]] || { echo "error: --id --name --scope are required" >&2; exit 1; }
  valid_agent_type "$type" || { echo "error: --type developer|reviewer|tester|security|release|coordinator|observer is required" >&2; exit 1; }
  valid_runtime "${runtime:-unknown}" || { echo "error: invalid --runtime ${runtime}" >&2; exit 1; }
  valid_provider "${provider:-other}" || { echo "error: invalid --provider ${provider}" >&2; exit 1; }
  valid_interface "${interface:-manual}" || { echo "error: invalid --interface ${interface}" >&2; exit 1; }
  valid_sync_mode "${sync_mode:-none}" || { echo "error: invalid --sync-mode ${sync_mode}" >&2; exit 1; }
  valid_binding_status "${binding_status:-unknown}" || { echo "error: invalid --binding-status ${binding_status}" >&2; exit 1; }
  ensure_agents
  write_agent_record "$agent_id" "$name" "$type" "active" "$scope" "${allowed:-—}" "${blocked:-—}" "$source" "${notes:-—}" "$update" "${runtime:-unknown}" "${provider:-other}" "${workspace:-manual}" "${interface:-manual}" "${sync_mode:-none}" "${handoff_target:-docs/agents/AGENT_HANDOFFS.md}" "${binding_status:-unknown}"
  echo "registered: ${agent_id}"
}

list_registered_agents() {
  ensure_agents
  awk '
    /^## Agent - / {
      if (id != "") print id "\t" name "\t" type "\t" status "\t" source "\t" runtime "\t" provider "\t" workspace "\t" interface "\t" sync_mode "\t" binding_status
      id=$0; sub(/^## Agent - /, "", id)
      name=""; type=""; status=""; source=""; runtime="unknown"; provider="other"; workspace="manual"; interface="manual"; sync_mode="none"; binding_status="unknown"
      next
    }
    /^- Name:/ {name=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", name)}
    /^- Type:/ {type=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", type)}
    /^- Status:/ {status=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", status)}
    /^- Source:/ {source=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", source)}
    /^- Runtime:/ {runtime=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", runtime)}
    /^- Provider:/ {provider=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", provider)}
    /^- Workspace:/ {workspace=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", workspace)}
    /^- Interface:/ {interface=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", interface)}
    /^- Sync mode:/ {sync_mode=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", sync_mode)}
    /^- Binding status:/ {binding_status=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", binding_status)}
    END {
      if (id != "") print id "\t" name "\t" type "\t" status "\t" source "\t" runtime "\t" provider "\t" workspace "\t" interface "\t" sync_mode "\t" binding_status
    }
  ' "$REGISTRY"
}

show_registered_agent() {
  local agent_id="$1"
  ensure_agents
  awk -v id="$agent_id" '
    $0 == "## Agent - " id {show=1; found=1}
    show && /^## Agent - / && $0 != "## Agent - " id {show=0}
    show {print}
    END{exit !found}
  ' "$REGISTRY"
}

registry_format_check() {
  ensure_agents
  awk '
    function finish() {
      if (id == "") return
      if (name == "" || type == "" || status == "" || scope == "" || created == "" || updated == "" || source == "") {
        print "invalid agent record: " id > "/dev/stderr"
        err=1
      }
      if (type !~ /^(developer|reviewer|tester|security|release|coordinator|observer)$/) {
        print "invalid agent type: " id " -> " type > "/dev/stderr"
        err=1
      }
      if (status !~ /^(active|paused|retired)$/) {
        print "invalid agent status: " id " -> " status > "/dev/stderr"
        err=1
      }
      if (runtime != "" && runtime !~ /^(codex|claude-code|claude-chat|cursor|cline|windsurf|copilot|continue|generic-chat|manual|qoderwork|qoder|trae|traeide|lingma|openclaw|qclaw)$/) {
        print "invalid agent runtime: " id " -> " runtime > "/dev/stderr"
        err=1
      }
      if (binding_status != "" && binding_status !~ /^(active|paused|unknown)$/) {
        print "invalid binding status: " id " -> " binding_status > "/dev/stderr"
        err=1
      }
    }
    /^## Agent - / {
      finish()
      id=$0; sub(/^## Agent - /, "", id)
      name=type=status=scope=created=updated=source=runtime=binding_status=""
      next
    }
    /^- Name:/ {name=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", name)}
    /^- Type:/ {type=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", type)}
    /^- Status:/ {status=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", status)}
    /^- Scope:/ {scope=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", scope)}
    /^- Created at:/ {created=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", created)}
    /^- Updated at:/ {updated=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", updated)}
    /^- Source:/ {source=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", source)}
    /^- Runtime:/ {runtime=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", runtime)}
    /^- Binding status:/ {binding_status=substr($0, index($0, ":")+1); gsub(/^[ \t]+|[ \t]+$/, "", binding_status)}
    END{finish(); exit err}
  ' "$REGISTRY"
}

bind_agent() {
  local agent_id="$1" runtime="$2" provider="$3" workspace="$4" interface="$5" sync_mode="$6" handoff_target="$7" binding_status="$8"
  ensure_agents
  agent_section_exists "$agent_id" || { echo "error: agent not registered: ${agent_id}" >&2; exit 1; }
  valid_runtime "$runtime" || { echo "error: invalid --runtime ${runtime}" >&2; exit 1; }
  valid_provider "$provider" || { echo "error: invalid --provider ${provider}" >&2; exit 1; }
  valid_interface "$interface" || { echo "error: invalid --interface ${interface}" >&2; exit 1; }
  valid_sync_mode "$sync_mode" || { echo "error: invalid --sync-mode ${sync_mode}" >&2; exit 1; }
  valid_binding_status "$binding_status" || { echo "error: invalid --status ${binding_status}" >&2; exit 1; }
  local now tmp
  now="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  tmp="$(mktemp)"
  awk -v id="$agent_id" -v runtime="$runtime" -v provider="$provider" -v workspace="$workspace" -v interface="$interface" -v sync_mode="$sync_mode" -v handoff_target="$handoff_target" -v binding_status="$binding_status" -v now="$now" '
    function emit_missing() {
      if (!seen_runtime) print "- Runtime: " runtime
      if (!seen_provider) print "- Provider: " provider
      if (!seen_workspace) print "- Workspace: " workspace
      if (!seen_interface) print "- Interface: " interface
      if (!seen_sync_mode) print "- Sync mode: " sync_mode
      if (!seen_handoff) print "- Handoff target: " handoff_target
      if (!seen_last_seen) print "- Last seen: " now
      if (!seen_binding_status) print "- Binding status: " binding_status
    }
    $0 == "## Agent - " id {in_agent=1; seen_runtime=seen_provider=seen_workspace=seen_interface=seen_sync_mode=seen_handoff=seen_last_seen=seen_binding_status=0}
    in_agent && /^## Agent - / && $0 != "## Agent - " id {emit_missing(); in_agent=0}
    in_agent && /^- Runtime:/ {$0="- Runtime: " runtime; seen_runtime=1}
    in_agent && /^- Provider:/ {$0="- Provider: " provider; seen_provider=1}
    in_agent && /^- Workspace:/ {$0="- Workspace: " workspace; seen_workspace=1}
    in_agent && /^- Interface:/ {$0="- Interface: " interface; seen_interface=1}
    in_agent && /^- Sync mode:/ {$0="- Sync mode: " sync_mode; seen_sync_mode=1}
    in_agent && /^- Handoff target:/ {$0="- Handoff target: " handoff_target; seen_handoff=1}
    in_agent && /^- Last seen:/ {$0="- Last seen: " now; seen_last_seen=1}
    in_agent && /^- Binding status:/ {$0="- Binding status: " binding_status; seen_binding_status=1}
    in_agent && /^- Updated at:/ {$0="- Updated at: " now}
    {print}
    END{if(in_agent) emit_missing()}
  ' "$REGISTRY" > "$tmp"
  mv "$tmp" "$REGISTRY"
}

unregistered_agent_refs() {
  ensure_agents
  {
    awk '
      /^- Owner:/ {
        owner=substr($0, index($0, ":")+1)
        gsub(/^[ \t]+|[ \t]+$/, "", owner)
        if (owner != "") print owner
      }
    ' "$ROLES"
    awk -F'|' '
      /^\|/ && $2 !~ /Task/ && $0 !~ /\|------/ {
        agent=$3
        gsub(/^[ \t]+|[ \t]+$/, "", agent)
        if (agent != "") print agent
      }
    ' "$LOCKS"
  } | sort -u | while IFS= read -r agent_id; do
    if ! agent_is_active "$agent_id"; then
      echo "$agent_id"
    fi
  done
}

case "$CMD" in
  init)
    ensure_agents
    WITH_DEFAULTS=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --with-defaults) WITH_DEFAULTS=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    if $WITH_DEFAULTS; then
      "${SCRIPT_DIR}/aw-agents.sh" register --defaults --update >/dev/null
      echo "registered defaults: docs/agents/AGENT_REGISTRY.md"
    fi
    echo "created/ok: docs/agents/"
    ;;
  register)
    ID=""
    NAME=""
    TYPE=""
    SCOPE=""
    ALLOWED="—"
    BLOCKED="—"
    NOTES="—"
    PRESET=""
    DEFAULTS=false
    UPDATE=false
    RUNTIME="unknown"
    PROVIDER="other"
    WORKSPACE="manual"
    INTERFACE="manual"
    SYNC_MODE="none"
    HANDOFF_TARGET="docs/agents/AGENT_HANDOFFS.md"
    BINDING_STATUS="unknown"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --id) ID="${2:-}"; shift 2 ;;
        --name) NAME="${2:-}"; shift 2 ;;
        --type) TYPE="${2:-}"; shift 2 ;;
        --scope) SCOPE="${2:-}"; shift 2 ;;
        --allowed) ALLOWED="${2:-}"; shift 2 ;;
        --blocked) BLOCKED="${2:-}"; shift 2 ;;
        --runtime) RUNTIME="${2:-}"; shift 2 ;;
        --provider) PROVIDER="${2:-}"; shift 2 ;;
        --workspace) WORKSPACE="${2:-}"; shift 2 ;;
        --interface) INTERFACE="${2:-}"; shift 2 ;;
        --sync-mode) SYNC_MODE="${2:-}"; shift 2 ;;
        --handoff-target) HANDOFF_TARGET="${2:-}"; shift 2 ;;
        --binding-status) BINDING_STATUS="${2:-}"; shift 2 ;;
        --notes) NOTES="${2:-}"; shift 2 ;;
        --preset) PRESET="${2:-}"; shift 2 ;;
        --defaults) DEFAULTS=true; shift ;;
        --update) UPDATE=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    ensure_agents
    if $DEFAULTS; then
      if ! $UPDATE; then
        existing_defaults="$(
          while IFS= read -r preset_name; do
            [[ -n "$preset_name" ]] || continue
            IFS=$'\t' read -r p_id _rest < <(read_preset "$preset_name")
            if agent_section_exists "$p_id"; then
              echo "$p_id"
            fi
          done < <(awk -F'\t' 'NR > 1 && $1 != "" {print $1}' "$PRESETS")
        )"
        if [[ -n "$existing_defaults" ]]; then
          echo "error: default agents already registered (use --update to modify):" >&2
          echo "$existing_defaults" >&2
          exit 1
        fi
      fi
      while IFS= read -r preset_name; do
        [[ -n "$preset_name" ]] || continue
        IFS=$'\t' read -r p_id p_name p_type p_scope p_allowed p_blocked p_runtime p_provider p_workspace p_interface p_sync_mode p_handoff_target p_binding_status < <(read_preset "$preset_name")
        register_one "$p_id" "$p_name" "$p_type" "$p_scope" "$p_allowed" "$p_blocked" "preset" "preset=${preset_name}" "$UPDATE" "${p_runtime:-unknown}" "${p_provider:-other}" "${p_workspace:-manual}" "${p_interface:-manual}" "${p_sync_mode:-none}" "${p_handoff_target:-docs/agents/AGENT_HANDOFFS.md}" "${p_binding_status:-unknown}"
      done < <(awk -F'\t' 'NR > 1 && $1 != "" {print $1}' "$PRESETS")
      aw_refresh_engineering_index
      exit 0
    fi
    if [[ -n "$PRESET" ]]; then
      if ! preset_row="$(read_preset "$PRESET" 2>/dev/null)"; then
        echo "error: unknown preset: ${PRESET}" >&2
        echo "available presets: $(available_presets)" >&2
        exit 1
      fi
      IFS=$'\t' read -r ID NAME TYPE SCOPE ALLOWED BLOCKED P_RUNTIME P_PROVIDER P_WORKSPACE P_INTERFACE P_SYNC_MODE P_HANDOFF_TARGET P_BINDING_STATUS <<< "$preset_row"
      [[ "$RUNTIME" == "unknown" ]] && RUNTIME="${P_RUNTIME:-unknown}"
      [[ "$PROVIDER" == "other" ]] && PROVIDER="${P_PROVIDER:-other}"
      [[ "$WORKSPACE" == "manual" ]] && WORKSPACE="${P_WORKSPACE:-manual}"
      [[ "$INTERFACE" == "manual" ]] && INTERFACE="${P_INTERFACE:-manual}"
      [[ "$SYNC_MODE" == "none" ]] && SYNC_MODE="${P_SYNC_MODE:-none}"
      [[ "$HANDOFF_TARGET" == "docs/agents/AGENT_HANDOFFS.md" ]] && HANDOFF_TARGET="${P_HANDOFF_TARGET:-docs/agents/AGENT_HANDOFFS.md}"
      [[ "$BINDING_STATUS" == "unknown" ]] && BINDING_STATUS="${P_BINDING_STATUS:-unknown}"
      if [[ "$NOTES" == "—" ]]; then
        NOTES="preset=${PRESET}"
      fi
      register_one "$ID" "$NAME" "$TYPE" "$SCOPE" "$ALLOWED" "$BLOCKED" "preset" "$NOTES" "$UPDATE" "$RUNTIME" "$PROVIDER" "$WORKSPACE" "$INTERFACE" "$SYNC_MODE" "$HANDOFF_TARGET" "$BINDING_STATUS"
      aw_refresh_engineering_index
      exit 0
    fi
    register_one "$ID" "$NAME" "$TYPE" "$SCOPE" "$ALLOWED" "$BLOCKED" "custom" "$NOTES" "$UPDATE" "$RUNTIME" "$PROVIDER" "$WORKSPACE" "$INTERFACE" "$SYNC_MODE" "$HANDOFF_TARGET" "$BINDING_STATUS"
    aw_refresh_engineering_index
    ;;
  bind)
    AGENT_ID="${1:-}"
    [[ -n "$AGENT_ID" ]] || { echo "error: agent id is required" >&2; usage 1; }
    shift || true
    RUNTIME="$(agent_field "$AGENT_ID" "Runtime")"; RUNTIME="${RUNTIME:-manual}"
    PROVIDER="$(agent_field "$AGENT_ID" "Provider")"; PROVIDER="${PROVIDER:-other}"
    WORKSPACE="$(agent_field "$AGENT_ID" "Workspace")"; WORKSPACE="${WORKSPACE:-manual}"
    INTERFACE="$(agent_field "$AGENT_ID" "Interface")"; INTERFACE="${INTERFACE:-manual}"
    SYNC_MODE="$(agent_field "$AGENT_ID" "Sync mode")"; SYNC_MODE="${SYNC_MODE:-none}"
    HANDOFF_TARGET="$(agent_field "$AGENT_ID" "Handoff target")"; HANDOFF_TARGET="${HANDOFF_TARGET:-docs/agents/AGENT_HANDOFFS.md}"
    BINDING_STATUS="$(agent_field "$AGENT_ID" "Binding status")"; BINDING_STATUS="${BINDING_STATUS:-active}"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --runtime) RUNTIME="${2:-}"; shift 2 ;;
        --provider) PROVIDER="${2:-}"; shift 2 ;;
        --workspace) WORKSPACE="${2:-}"; shift 2 ;;
        --interface) INTERFACE="${2:-}"; shift 2 ;;
        --sync-mode) SYNC_MODE="${2:-}"; shift 2 ;;
        --handoff-target) HANDOFF_TARGET="${2:-}"; shift 2 ;;
        --status) BINDING_STATUS="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    bind_agent "$AGENT_ID" "$RUNTIME" "$PROVIDER" "$WORKSPACE" "$INTERFACE" "$SYNC_MODE" "$HANDOFF_TARGET" "$BINDING_STATUS"
    echo "bound: ${AGENT_ID} -> ${RUNTIME} (${BINDING_STATUS})"
    aw_refresh_engineering_index
    ;;
  unbind)
    AGENT_ID="${1:-}"
    [[ -n "$AGENT_ID" ]] || { echo "error: agent id is required" >&2; usage 1; }
    bind_agent "$AGENT_ID" "manual" "other" "manual" "manual" "none" "docs/agents/AGENT_HANDOFFS.md" "unknown"
    echo "unbound: ${AGENT_ID}"
    aw_refresh_engineering_index
    ;;
  unregister)
    AGENT_ID="${1:-}"
    [[ -n "$AGENT_ID" ]] || { echo "error: agent id is required" >&2; usage 1; }
    ensure_agents
    if ! agent_section_exists "$AGENT_ID"; then
      echo "error: agent not registered: ${AGENT_ID}" >&2
      exit 1
    fi
    NOW="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    tmp="$(mktemp)"
    awk -v id="$AGENT_ID" -v now="$NOW" '
      $0 == "## Agent - " id {in_agent=1}
      in_agent && /^## Agent - / && $0 != "## Agent - " id {in_agent=0}
      in_agent && /^- Status:/ {$0="- Status: retired"}
      in_agent && /^- Updated at:/ {$0="- Updated at: " now}
      in_agent && /^- Notes:/ {$0=$0 "；unregistered at " now}
      {print}
    ' "$REGISTRY" > "$tmp"
    mv "$tmp" "$REGISTRY"
    echo "unregistered: ${AGENT_ID} (status=retired)"
    aw_refresh_engineering_index
    ;;
  assign)
    ROLE=""
    OWNER=""
    SCOPE=""
    ALLOWED="待确认"
    BLOCKED="无关文件、未确认需求"
    RELATED="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --role) ROLE="${2:-}"; shift 2 ;;
        --owner) OWNER="${2:-}"; shift 2 ;;
        --scope) SCOPE="${2:-}"; shift 2 ;;
        --allowed) ALLOWED="${2:-}"; shift 2 ;;
        --blocked) BLOCKED="${2:-}"; shift 2 ;;
        --related) RELATED="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    case "$ROLE" in developer|reviewer|tester|security|release) ;; *) echo "error: --role developer|reviewer|tester|security|release is required" >&2; exit 1 ;; esac
    [[ -n "$OWNER" && -n "$SCOPE" ]] || { echo "error: --owner and --scope are required" >&2; exit 1; }
    ensure_agents
    {
      echo ""
      echo "## Assignment - $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
      echo ""
      echo "- Role: ${ROLE}"
      echo "- Owner: ${OWNER}"
      echo "- Related: ${RELATED}"
      echo "- Scope: ${SCOPE}"
      echo "- Allowed paths: ${ALLOWED}"
      echo "- Blocked paths: ${BLOCKED}"
    } >> "$ROLES"
    echo "assigned: ${ROLE} → ${OWNER}"
    aw_refresh_engineering_index
    ;;
  handoff)
    FROM=""
    TO=""
    RELATED="—"
    SCOPE=""
    DONE=""
    TODO=""
    RISK="—"
    EVIDENCE="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --from) FROM="${2:-}"; shift 2 ;;
        --to) TO="${2:-}"; shift 2 ;;
        --related) RELATED="${2:-}"; shift 2 ;;
        --scope) SCOPE="${2:-}"; shift 2 ;;
        --done) DONE="${2:-}"; shift 2 ;;
        --todo) TODO="${2:-}"; shift 2 ;;
        --risk) RISK="${2:-}"; shift 2 ;;
        --evidence) EVIDENCE="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$FROM" && -n "$TO" && -n "$SCOPE" && -n "$DONE" && -n "$TODO" ]] || { echo "error: --from --to --scope --done --todo are required" >&2; exit 1; }
    ensure_agents
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_after_header "$HANDOFFS" "| ${now} | ${FROM} | ${TO} | ${RELATED} | ${SCOPE} | ${DONE} | ${TODO} | ${RISK} | ${EVIDENCE} |"
    echo "logged: docs/agents/AGENT_HANDOFFS.md"
    aw_refresh_engineering_index
    ;;
  review)
    REVIEWER=""
    TYPE=""
    RELATED="—"
    RESULT=""
    BLOCKERS="—"
    SUGGESTIONS="—"
    EVIDENCE="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --reviewer) REVIEWER="${2:-}"; shift 2 ;;
        --type) TYPE="${2:-}"; shift 2 ;;
        --related) RELATED="${2:-}"; shift 2 ;;
        --result) RESULT="${2:-}"; shift 2 ;;
        --blockers) BLOCKERS="${2:-}"; shift 2 ;;
        --suggestions) SUGGESTIONS="${2:-}"; shift 2 ;;
        --evidence) EVIDENCE="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    case "$TYPE" in code|test|security|release) ;; *) echo "error: --type code|test|security|release is required" >&2; exit 1 ;; esac
    case "$RESULT" in pass|changes|block) ;; *) echo "error: --result pass|changes|block is required" >&2; exit 1 ;; esac
    [[ -n "$REVIEWER" ]] || { echo "error: --reviewer is required" >&2; exit 1; }
    ensure_agents
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_after_header "$REVIEWS" "| ${now} | ${REVIEWER} | ${TYPE} | ${RELATED} | ${RESULT} | ${BLOCKERS} | ${SUGGESTIONS} | ${EVIDENCE} |"
    echo "logged: docs/agents/AGENT_REVIEWS.md"
    aw_refresh_engineering_index
    ;;
  claim)
    AGENT=""
    TASK=""
    ROLE=""
    SCOPE=""
    ALLOWED=""
    TTL_MIN="120"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --agent) AGENT="${2:-}"; shift 2 ;;
        --task) TASK="${2:-}"; shift 2 ;;
        --role) ROLE="${2:-}"; shift 2 ;;
        --scope) SCOPE="${2:-}"; shift 2 ;;
        --allowed) ALLOWED="${2:-}"; shift 2 ;;
        --ttl-min) TTL_MIN="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$AGENT" && -n "$TASK" && -n "$ROLE" && -n "$SCOPE" && -n "$ALLOWED" ]] || { echo "error: --agent --task --role --scope --allowed are required" >&2; exit 1; }
    ensure_agents
    now_epoch="$(date +%s)"
    expires_epoch=$((now_epoch + TTL_MIN * 60))
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    expires="$(date -r "$expires_epoch" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date '+%Y-%m-%d %H:%M:%S')"
    if grep -Eq "^\|[[:space:]]*${TASK}[[:space:]]*\|" "$LOCKS" && ! grep -Eq "^\|[[:space:]]*${TASK}[[:space:]]*\|[[:space:]]*${AGENT}[[:space:]]*\|" "$LOCKS"; then
      echo "error: task already claimed by another agent: ${TASK}" >&2
      grep -E "^\|[[:space:]]*${TASK}[[:space:]]*\|" "$LOCKS" >&2 || true
      exit 1
    fi
    insert_after_header "$LOCKS" "| ${TASK} | ${AGENT} | ${ROLE} | ${SCOPE} | ${ALLOWED} | active | ${now} | ${expires} | ${now} | — |"
    echo "claimed: ${TASK} by ${AGENT}"
    aw_refresh_engineering_index
    ;;
  heartbeat)
    AGENT=""
    TASK=""
    STATUS="working"
    ACTION=""
    BLOCKED="—"
    NEXT="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --agent) AGENT="${2:-}"; shift 2 ;;
        --task) TASK="${2:-}"; shift 2 ;;
        --status) STATUS="${2:-}"; shift 2 ;;
        --action) ACTION="${2:-}"; shift 2 ;;
        --blocked) BLOCKED="${2:-}"; shift 2 ;;
        --next) NEXT="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$AGENT" && -n "$TASK" && -n "$ACTION" ]] || { echo "error: --agent --task --action are required" >&2; exit 1; }
    case "$STATUS" in working|blocked|done) ;; *) echo "error: --status working|blocked|done" >&2; exit 1 ;; esac
    ensure_agents
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    insert_after_header "$HEARTBEATS" "| ${now} | ${AGENT} | ${TASK} | ${STATUS} | ${ACTION} | ${BLOCKED} | ${NEXT} |"
    echo "heartbeat: ${AGENT} ${TASK} ${STATUS}"
    ;;
  release)
    AGENT=""
    TASK=""
    NOTES="—"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --agent) AGENT="${2:-}"; shift 2 ;;
        --task) TASK="${2:-}"; shift 2 ;;
        --notes) NOTES="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    [[ -n "$AGENT" && -n "$TASK" ]] || { echo "error: --agent --task are required" >&2; exit 1; }
    ensure_agents
    tmp="$(mktemp)"
    awk -v task="$TASK" -v agent="$AGENT" -v notes="$NOTES" '
      BEGIN{FS=OFS="|"}
      $0 ~ "^\\|" {
        t=$2; a=$3; gsub(/^[ \t]+|[ \t]+$/, "", t); gsub(/^[ \t]+|[ \t]+$/, "", a)
        if (t == task && a == agent) {
          $7=" released "
          $11=" " notes " "
        }
      }
      {print}
    ' "$LOCKS" > "$tmp"
    mv "$tmp" "$LOCKS"
    echo "released: ${TASK} by ${AGENT}"
    aw_refresh_engineering_index
    ;;
  lock-check)
    ensure_agents
    TASK_FILTER=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --task) TASK_FILTER="${2:-}"; shift 2 ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    echo "== agent lock check =="
    err=0
    now_epoch="$(date +%s)"
    active_count="$(awk -F'|' -v task="$TASK_FILTER" '
      /^\|/ && $2 !~ /Task/ && $0 !~ /\|------/ {
        t=$2; s=$7
        gsub(/^[ \t]+|[ \t]+$/, "", t); gsub(/^[ \t]+|[ \t]+$/, "", s)
        if ((task == "" || t == task) && s == "active") c++
      }
      END{print c+0}
    ' "$LOCKS")"
    if [[ -n "$TASK_FILTER" && "$active_count" -eq 0 ]]; then
      echo "block: no active agent lock for ${TASK_FILTER}" >&2
      err=1
    else
      echo "ok  active locks: ${active_count}"
    fi
    while IFS='|' read -r _ task agent role scope allowed status claimed expires heartbeat notes _rest; do
      task="$(echo "${task:-}" | xargs)"
      agent="$(echo "${agent:-}" | xargs)"
      status="$(echo "${status:-}" | xargs)"
      expires="$(echo "${expires:-}" | xargs)"
      [[ -z "$task" || "$task" == "Task" || "$task" == "------" || "$status" != "active" ]] && continue
      [[ -n "$TASK_FILTER" && "$task" != "$TASK_FILTER" ]] && continue
      exp_epoch="$(date -j -f '%Y-%m-%d %H:%M:%S' "$expires" '+%s' 2>/dev/null || echo 0)"
      if [[ "$exp_epoch" -gt 0 && "$exp_epoch" -lt "$now_epoch" ]]; then
        echo "block: expired lock ${task} by ${agent}" >&2
        err=1
      fi
    done < "$LOCKS"
    exit "$err"
    ;;
  check)
    echo "== agents check =="
    err=0
    for f in "$ROLES" "$HANDOFFS" "$REVIEWS" "$LOCKS" "$HEARTBEATS" "$REGISTRY" "$PRESETS"; do
      if [[ -f "$f" ]]; then
        echo "ok  ${f#"${ROOT}/"}"
      else
        echo "missing  ${f#"${ROOT}/"} (run: aw agents init)" >&2
        err=1
      fi
    done
    if [[ -f "$REGISTRY" ]] && ! registry_format_check; then
      err=1
    fi
    exit "$err"
    ;;
  gate)
    ensure_agents
    STRICT=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --strict) STRICT=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    echo "== agents gate =="
    err=0
    "${SCRIPT_DIR}/aw-agents.sh" check || err=1
    "${SCRIPT_DIR}/aw-agents.sh" lock-check || err=1
    if grep -Eq '^\| [^|]+ \| [^|]+ \| [^|]+ \| [^|]+ \| block \|' "$REVIEWS"; then
      echo "block: agent review has blocking result" >&2
      grep -E '^\| [^|]+ \| [^|]+ \| [^|]+ \| [^|]+ \| block \|' "$REVIEWS" >&2 || true
      exit 1
    fi
    if grep -Eq '^\| [^|]+ \| [^|]+ \| [^|]+ \| [^|]+ \| changes \|' "$REVIEWS"; then
      echo "warn  agent review requests changes" >&2
    fi
    if grep -q 'Allowed paths: 待确认' "$ROLES"; then
      echo "warn  agent assignment has unconfirmed allowed paths" >&2
    fi
    missing_agents="$(unregistered_agent_refs)"
    if [[ -n "$missing_agents" ]]; then
      if $STRICT; then
        echo "block: assignment/claim references unregistered active agents" >&2
        echo "$missing_agents" >&2
        exit 1
      fi
      echo "warn  assignment/claim references unregistered active agents" >&2
      echo "$missing_agents" >&2
    fi
    binding_issues="$(
      list_registered_agents | awk -F'\t' '
        $4 == "active" && ($6 == "" || $6 == "unknown" || $11 == "" || $11 == "unknown") {
          print $1 " runtime=" ($6 == "" ? "unknown" : $6) " binding-status=" ($11 == "" ? "unknown" : $11)
        }
      '
    )"
    if [[ -n "$binding_issues" ]]; then
      if $STRICT; then
        echo "block: active agents missing runtime/tool binding" >&2
        echo "$binding_issues" >&2
        exit 1
      fi
      echo "warn  active agents missing runtime/tool binding" >&2
      echo "$binding_issues" >&2
    fi
    conflicts="$(
      awk '
        function trim(s){gsub(/^[ \t]+|[ \t]+$/, "", s); return s}
        function norm(s){
          s=trim(s)
          if (substr(s, 1, 2) == "./") s=substr(s, 3)
          while (length(s) > 1 && substr(s, length(s), 1) == "/") s=substr(s, 1, length(s)-1)
          return s
        }
        /^- Owner:/ {owner=trim(substr($0, index($0, ":")+1))}
        /^- Allowed paths:/ {
          allowed=trim(substr($0, index($0, ":")+1))
          if (owner == "" || allowed == "" || allowed == "待确认") next
          n=split(allowed, parts, /[,;，；]/)
          for (i=1; i<=n; i++) {
            p=norm(parts[i])
            if (p == "" || p == "待确认" || p == "N/A" || p == "none") continue
            idx++
            owners[idx]=owner
            paths[idx]=p
          }
        }
        END {
          for (i=1; i<=idx; i++) {
            for (j=i+1; j<=idx; j++) {
              if (owners[i] == owners[j]) continue
              pi=paths[i]; pj=paths[j]
              if (pi == pj || index(pi "/", pj "/") == 1 || index(pj "/", pi "/") == 1) {
                print owners[i] " ↔ " owners[j] ": " pi " / " pj
              }
            }
          }
        }
      ' "$ROLES"
    )"
    if [[ -n "$conflicts" ]]; then
      if $STRICT; then
        echo "block: agent allowed paths overlap" >&2
        echo "$conflicts" >&2
        exit 1
      fi
      echo "warn  agent allowed paths overlap; coordinate handoff or rerun with --strict to block" >&2
      echo "$conflicts" >&2
      err=0
    fi
    echo "agents gate: ok"
    exit "$err"
    ;;
  list)
    ensure_agents
    SHOW_BINDINGS=false
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --bindings) SHOW_BINDINGS=true; shift ;;
        *) echo "Unknown: $1" >&2; usage 1 ;;
      esac
    done
    if $SHOW_BINDINGS; then
      echo "== registered agents + bindings =="
      printf "%-28s %-18s %-12s %-12s %-14s %s\n" "Agent ID" "Runtime" "Provider" "Interface" "Sync mode" "Binding"
      list_registered_agents | while IFS=$'\t' read -r id name type status source runtime provider workspace interface sync_mode binding_status; do
        printf "%-28s %-18s %-12s %-12s %-14s %s\n" "$id" "$runtime" "$provider" "$interface" "$sync_mode" "$binding_status"
      done
    else
      echo "== registered agents =="
      printf "%-28s %-28s %-12s %-10s %s\n" "Agent ID" "Name" "Type" "Status" "Source"
      list_registered_agents | while IFS=$'\t' read -r id name type status source _rest; do
        printf "%-28s %-28s %-12s %-10s %s\n" "$id" "$name" "$type" "$status" "$source"
      done
    fi
    ;;
  bindings)
    ensure_agents
    echo "== agent bindings =="
    printf "%-28s %-18s %-12s %-12s %-14s %s\n" "Agent ID" "Runtime" "Provider" "Interface" "Sync mode" "Workspace"
    list_registered_agents | while IFS=$'\t' read -r id name type status source runtime provider workspace interface sync_mode binding_status; do
      printf "%-28s %-18s %-12s %-12s %-14s %s\n" "$id" "$runtime" "$provider" "$interface" "$sync_mode" "$workspace"
    done
    ;;
  show)
    AGENT_ID="${1:-}"
    [[ -n "$AGENT_ID" ]] || { echo "error: agent id is required" >&2; usage 1; }
    if ! show_registered_agent "$AGENT_ID"; then
      echo "error: agent not registered: ${AGENT_ID}" >&2
      exit 1
    fi
    ;;
  -h|--help|help)
    usage 0
    ;;
  *)
    echo "Unknown: $CMD" >&2
    usage 1
    ;;
esac

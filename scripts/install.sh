#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Options:
  -a, --agent NAME   Install for a specific agent (non-interactive)
                     Valid: opencode, amazonq, gemini-cli, codex, vscode, project-local, all-global, custom
  -s, --scope SCOPE  Scope for gemini-cli/codex (local or global)
  -p, --path DIR     Custom install path (use with --agent custom)
  -h, --help         Show help

Examples:
  ./install.sh
  ./install.sh --agent opencode
  ./install.sh --agent custom --path /tmp/skills
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_SRC="${REPO_DIR}/skills"

OPENCODE_SKILLS_DIR=".opencode/skills"

TARGET_AGENT=""
CUSTOM_PATH=""
SCOPE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--agent)
      TARGET_AGENT="$2"
      shift 2
      ;;
    -s|--scope)
      SCOPE="$2"
      shift 2
      ;;
    -p|--path)
      CUSTOM_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERR] Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

header() {
  echo ""
  echo "========================================"
  echo "     NEA Flow - Installer (Unix)        "
  echo "  Spec-Driven Development for AI Agents "
  echo "========================================"
  echo ""
}

warn() { echo "[WARN] $1"; }
err() { echo "[ERR] $1" >&2; }
ok() { echo "[OK] $1"; }

test_source_tree() {
  local missing=0
  if [[ ! -d "$SKILLS_SRC" ]]; then
    err "Missing skills/ directory"
    missing=1
  fi

  if [[ ! -d "${SKILLS_SRC}/_shared" ]]; then
    err "Missing skills/_shared directory"
    missing=1
  fi

  local skill_dir
  for skill_dir in "${SKILLS_SRC}"/flow-nea-*; do
    if [[ -d "$skill_dir" ]]; then
      if [[ ! -f "${skill_dir}/SKILL.md" ]]; then
        err "Missing: $(basename "$skill_dir")/SKILL.md"
        missing=1
      fi
    fi
  done

  if [[ $missing -ne 0 ]]; then
    echo ""
    err "Source validation failed. Is this a complete clone of the repository?"
    echo "  Try: git clone https://github.com/RDuuke/sdd-nea-flow.git"
    echo ""
    exit 1
  fi
}

install_skills() {
  local target_dir="$1"
  local tool_name="$2"

  echo ""
  echo "Installing skills for ${tool_name}..."
  mkdir -p "$target_dir"

  local shared_src="${SKILLS_SRC}/_shared"
  local shared_target="${target_dir}/_shared"
  if [[ -d "$shared_src" ]]; then
    mkdir -p "$shared_target"
    local shared_count=0
    local shared_file
    for shared_file in "${shared_src}"/*.md; do
      if [[ -f "$shared_file" ]]; then
        cp "$shared_file" "$shared_target/"
        shared_count=$((shared_count + 1))
      fi
    done
    if [[ $shared_count -gt 0 ]]; then
      ok "_shared (${shared_count} convention files)"
    else
      warn "_shared directory found but no .md files to copy"
    fi
  fi

  local count=0
  local skill_dir
  for skill_dir in "${SKILLS_SRC}"/flow-nea-*; do
    if [[ -d "$skill_dir" ]]; then
      local skill_name
      skill_name="$(basename "$skill_dir")"
      local skill_file="${skill_dir}/SKILL.md"
      if [[ ! -f "$skill_file" ]]; then
        warn "Skipping ${skill_name} (SKILL.md not found in source)"
        continue
      fi
      mkdir -p "${target_dir}/${skill_name}"
      cp "$skill_file" "${target_dir}/${skill_name}/SKILL.md"
      ok "$skill_name"
      count=$((count + 1))
    fi
  done

  echo ""
  echo "  ${count} skills installed -> ${target_dir}"
}

install_amazonq_prompt() {
  local amazonq_prompts_dir="${HOME}/.aws/amazonq/prompts"
  local prompt_src="${REPO_DIR}/examples/amazonq/amazonq-instructions.md"
  local prompt_target="${amazonq_prompts_dir}/amazonq-instructions.md"

  if [[ ! -f "$prompt_src" ]]; then
    err "Missing examples/amazonq/amazon-instructions.md"
    exit 1
  fi

  mkdir -p "$amazonq_prompts_dir"
  cp "$prompt_src" "$prompt_target"

  if [[ ! -f "$prompt_target" ]]; then
    warn "No se pudo verificar el prompt de Amazon Q"
    return
  fi

  ok "amazonq prompt (amazon-instructions.md)"
}

install_gemini_prompt() {
  local gemini_dir="${HOME}/.gemini"
  local prompt_src="${REPO_DIR}/examples/gemini-cli/GEMINI.md"
  local prompt_target="${gemini_dir}/GEMINI.md"
  local marker="ORQUESTADOR NEA FLOW"

  if [[ ! -f "$prompt_src" ]]; then
    err "Missing examples/gemini-cli/GEMINI.md"
    exit 1
  fi

  mkdir -p "$gemini_dir"

  if [[ -f "$prompt_target" ]] && grep -q "$marker" "$prompt_target"; then
    warn "Prompt de Gemini CLI ya existe en GEMINI.md"
    return
  fi

  if [[ -f "$prompt_target" ]]; then
    printf "\n\n" >> "$prompt_target"
    cat "$prompt_src" >> "$prompt_target"
  else
    cp "$prompt_src" "$prompt_target"
  fi

  if [[ ! -f "$prompt_target" ]]; then
    warn "No se pudo verificar el prompt de Gemini CLI"
    return
  fi

  ok "gemini CLI prompt (GEMINI.md)"
}

install_codex_prompt() {
  local codex_dir="${HOME}/.codex"
  local prompt_src="${REPO_DIR}/examples/codex/agents.md"
  local prompt_target="${codex_dir}/agents.md"
  local marker="ORQUESTADOR NEA FLOW"

  if [[ ! -f "$prompt_src" ]]; then
    err "Missing examples/codex/agents.md"
    exit 1
  fi

  mkdir -p "$codex_dir"

  if [[ -f "$prompt_target" ]] && grep -q "$marker" "$prompt_target"; then
    warn "Prompt de Codex ya existe en agents.md"
    return
  fi

  if [[ -f "$prompt_target" ]]; then
    printf "\n\n" >> "$prompt_target"
    cat "$prompt_src" >> "$prompt_target"
  else
    cp "$prompt_src" "$prompt_target"
  fi

  if [[ ! -f "$prompt_target" ]]; then
    warn "No se pudo verificar el prompt de Codex"
    return
  fi

  ok "codex prompt (agents.md)"
}

resolve_gemini_skills_dir() {
  local scope="$1"
  if [[ "$scope" == "local" ]]; then
    echo "./.gemini/skills"
    return
  fi
  echo "${HOME}/.gemini/skills"
}

resolve_codex_skills_dir() {
  local scope="$1"
  if [[ "$scope" == "local" ]]; then
    echo "./.codex/skills"
    return
  fi
  echo "${HOME}/.codex/skills"
}

install_for_agent() {
  local agent="$1"
  case "$agent" in
    opencode)
      install_skills "$OPENCODE_SKILLS_DIR" "OpenCode"
      if [[ -f "${REPO_DIR}/examples/opencode/opencode.json" ]]; then
        mkdir -p .opencode
        cp "${REPO_DIR}/examples/opencode/opencode.json" .opencode/opencode.json
        ok ".opencode/opencode.json"
      else
        warn "Missing examples/opencode/opencode.json"
      fi
      ;;
    amazonq)
      install_skills ".amazonq/rules" "Amazon Q"
      install_amazonq_prompt
      echo ""
      warn "Skills instaladas en .amazonq/rules/"
      warn "Prompt instalado en ~/.aws/amazonq/prompts/amazon-instructions.md"
      echo "Siguiente paso: abre Amazon Q y ejecuta /flow-nea-init"
      ;;
    gemini-cli)
      if [[ -z "$SCOPE" ]]; then
        read -r -p "Scope (local/global): " SCOPE
      fi
      if [[ "$SCOPE" != "local" && "$SCOPE" != "global" ]]; then
        err "Scope invalido. Usa local o global."
        exit 1
      fi
      gemini_dir="$(resolve_gemini_skills_dir "$SCOPE")"
      install_skills "$gemini_dir" "Gemini CLI"
      install_gemini_prompt
      echo ""
      warn "Skills instaladas en ${gemini_dir}"
      warn "Prompt instalado en ~/.gemini/GEMINI.md"
      warn "Asegura GEMINI_SYSTEM_MD=1 en ~/.gemini/.env"
      echo "Siguiente paso: abre Gemini CLI y ejecuta /flow-nea-init"
      ;;
    codex)
      if [[ -z "$SCOPE" ]]; then
        read -r -p "Scope (local/global): " SCOPE
      fi
      if [[ "$SCOPE" != "local" && "$SCOPE" != "global" ]]; then
        err "Scope invalido. Usa local o global."
        exit 1
      fi
      codex_dir="$(resolve_codex_skills_dir "$SCOPE")"
      install_skills "$codex_dir" "Codex"
      install_codex_prompt
      echo ""
      warn "Skills instaladas en ${codex_dir}"
      warn "Prompt instalado en ~/.codex/agents.md"
      echo "Siguiente paso: abre Codex y ejecuta /flow-nea-init"
      ;;
    vscode)
      install_skills ".vscode/skills" "VS Code (Copilot)"
      echo ""
      echo "Next step:"
      echo "  Add the orchestrator to your .github/copilot-instructions.md"
      echo "  See: examples/vscode/copilot-instructions.md"
      warn "Skills installed in current project (.vscode/skills/)"
      ;;
    project-local)
      install_skills "./skills" "Project-local"
      echo ""
      warn "Skills installed in ./skills - relative to this project"
      ;;
    all-global)
      install_skills "$OPENCODE_SKILLS_DIR" "OpenCode"
      ;;
    custom)
      if [[ -z "$CUSTOM_PATH" ]]; then
        read -r -p "Enter target path: " CUSTOM_PATH
      fi
      if [[ -z "$CUSTOM_PATH" ]]; then
        err "No path provided"
        exit 1
      fi
      install_skills "$CUSTOM_PATH" "Custom"
      ;;
    *)
      err "Unknown agent: $agent"
      usage
      exit 1
      ;;
  esac
}

show_menu() {
  echo "Select your AI coding assistant:"
  echo ""
  echo "  1) OpenCode       (${OPENCODE_SKILLS_DIR})"
  echo "  2) Amazon Q       (.amazonq/rules)"
  echo "  3) Gemini CLI     (local o global)"
  echo "  4) Codex          (local o global)"
  echo "  5) VS Code        (.vscode/skills)"
  echo "  6) Project-local  (./skills)"
  echo "  7) All global     (OpenCode)"
  echo "  8) Custom path"
  echo ""

  read -r -p "Choice [1-8]: " choice
  case "$choice" in
    1) install_for_agent opencode ;;
    2) install_for_agent amazonq ;;
    3) install_for_agent gemini-cli ;;
    4) install_for_agent codex ;;
    5) install_for_agent vscode ;;
    6) install_for_agent project-local ;;
    7) install_for_agent all-global ;;
    8) install_for_agent custom ;;
    *)
      err "Invalid choice"
      exit 1
      ;;
  esac
}

header
test_source_tree

if [[ -n "$TARGET_AGENT" ]]; then
  install_for_agent "$TARGET_AGENT"
else
  show_menu
fi

echo ""
echo "Done! Start using NEA Flow with: /flow-nea-init"
echo "Recommended persistence backend: OpenSpec"

#!/usr/bin/env bash
set -Eeuo pipefail

trap 'log_error "Unhandled error on line $LINENO in ${FUNCNAME[0]} (exit code $?)"' ERR
trap 'cleanup' EXIT

cleanup() {
  return 0
}


usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -a, --agent NAME   Install for a specific agent (non-interactive)
                     Valid: opencode, amazonq, gemini-cli, codex, vscode, claude-code, project-local, all-global, custom
  -s, --scope SCOPE  Scope for gemini-cli/codex (local or global)
  -p, --path DIR     Custom install path (use with --agent custom)
  -h, --help         Show help

Examples:
  ./install.sh
  ./install.sh --agent opencode
  ./install.sh --agent custom --path /tmp/skills
EOF
  exit "${1:-0}"
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
      log_error "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

header() {
  printf "\n"
  printf "========================================\n"
  printf "     NEA Flow - Installer (Unix)        \n"
  printf "  Spec-Driven Development for AI Agents \n"
  printf "========================================\n"
  printf "\n"
}

_timestamp() {
  date +%H:%M:%S 2>/dev/null || printf "??:??:??"
}

log_info() {
  printf "[%s] INFO: %s\n" "$(_timestamp)" "$*" >&2
}

log_warn() {
  printf "[%s] WARN: %s\n" "$(_timestamp)" "$*" >&2
}

log_error() {
  printf "[%s] ERROR: %s\n" "$(_timestamp)" "$*" >&2
}

log_debug() {
  if [[ "${DEBUG:-0}" == "1" ]]; then
    printf "[%s] DEBUG: %s\n" "$(_timestamp)" "$*" >&2
  fi
}

check_dependencies() {
  local -a missing_deps=()
  local -a required=("cp" "mkdir" "grep" "wc" "tr" "printf" "cat" "mv" "find")

  for cmd in "${required[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      missing_deps+=("$cmd")
    fi
  done

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_error "Missing required commands: ${missing_deps[*]}"
    exit 1
  fi
  log_info "Todas las dependencias encontradas."
}

verify_checksums() {
  local checksum_file="${REPO_DIR}/checksums.sha256"
  if [[ ! -f "$checksum_file" ]]; then
    log_warn "checksums.sha256 no encontrado — omitiendo verificacion de integridad"
    return 0
  fi
  if ! command -v sha256sum &>/dev/null; then
    log_warn "sha256sum no disponible — omitiendo verificacion de integridad"
    return 0
  fi
  log_info "Verificando integridad de archivos..."
  local old_dir
  old_dir="$(pwd)"
  cd "$REPO_DIR"
  if sha256sum -c "$checksum_file" --quiet 2>/dev/null; then
    log_info "Todos los checksums verificados OK"
  else
    log_warn "Algunos checksums no coinciden. Los archivos fuente pueden haber sido modificados."
    log_warn "Esto es esperado si hiciste cambios locales a las skills."
  fi
  cd "$old_dir"
}

test_source_tree() {
  local missing=0
  if [[ ! -d "$SKILLS_SRC" ]]; then
    log_error "Missing skills/ directory"
    missing=1
  fi

  if [[ ! -d "${SKILLS_SRC}/_shared" ]]; then
    log_error "Missing skills/_shared directory"
    missing=1
  fi

  local skill_dir
  for skill_dir in "${SKILLS_SRC}"/flow-nea-*; do
    if [[ -d "$skill_dir" ]]; then
      if [[ ! -f "${skill_dir}/SKILL.md" ]]; then
        log_error "Missing: $(basename "$skill_dir")/SKILL.md"
        missing=1
      fi
    fi
  done

    if [[ $missing -ne 0 ]]; then
      printf "\n"
      log_error "Source validation failed. Is this a complete clone of the repository?"
      printf "  Try: git clone https://github.com/RDuuke/sdd-nea-flow.git\n"
      printf "\n"
      exit 1
    fi
}

install_skills() {
  local target_dir="$1"
  local tool_name="$2"

  printf "\n"
  printf "Instalando skills para %s...\n" "${tool_name}"
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
      log_info "_shared (${shared_count} convention files)"
    else
      log_warn "_shared directory found but no .md files to copy"
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
        log_warn "Skipping ${skill_name} (SKILL.md not found in source)"
        continue
      fi
      mkdir -p "${target_dir}/${skill_name}"
      cp "$skill_file" "${target_dir}/${skill_name}/SKILL.md"
      log_info "$skill_name"
      count=$((count + 1))
    fi
  done

  printf "\n"
  printf "  %s skills instaladas -> %s\n" "${count}" "${target_dir}"
}

install_amazonq_prompt() {
  local amazonq_prompts_dir="${HOME}/.aws/amazonq/prompts"
  local prompt_src="${REPO_DIR}/examples/amazonq/amazonq-instructions.md"
  local prompt_target="${amazonq_prompts_dir}/amazonq-instructions.md"

  if [[ ! -f "$prompt_src" ]]; then
    log_error "Missing examples/amazonq/amazon-instructions.md"
    exit 1
  fi

  mkdir -p "$amazonq_prompts_dir"
  cp "$prompt_src" "$prompt_target"

  if [[ ! -f "$prompt_target" ]]; then
    log_warn "No se pudo verificar el prompt de Amazon Q"
    return
  fi

  log_info "amazonq prompt (amazon-instructions.md)"
}

install_gemini_prompt() {
  local gemini_dir="${HOME}/.gemini"
  local prompt_src="${REPO_DIR}/examples/gemini-cli/GEMINI.md"
  local prompt_target="${gemini_dir}/GEMINI.md"
  local marker="ORQUESTADOR NEA FLOW"

  if [[ ! -f "$prompt_src" ]]; then
    log_error "Missing examples/gemini-cli/GEMINI.md"
    exit 1
  fi

  mkdir -p "$gemini_dir"

  if [[ -f "$prompt_target" ]] && grep -q "$marker" "$prompt_target"; then
    log_warn "Prompt de Gemini CLI ya existe en GEMINI.md"
    return
  fi

  if [[ -f "$prompt_target" ]]; then
    printf "\n\n" >> "$prompt_target"
    cat "$prompt_src" >> "$prompt_target"
  else
    cp "$prompt_src" "$prompt_target"
  fi

  if [[ ! -f "$prompt_target" ]]; then
    log_warn "No se pudo verificar el prompt de Gemini CLI"
    return
  fi

  log_info "gemini CLI prompt (GEMINI.md)"
}

install_codex_prompt() {
  local codex_dir="${HOME}/.codex"
  local prompt_src="${REPO_DIR}/examples/codex/agents.md"
  local prompt_target="${codex_dir}/agents.md"
  local marker="ORQUESTADOR NEA FLOW"

  if [[ ! -f "$prompt_src" ]]; then
    log_error "Missing examples/codex/agents.md"
    exit 1
  fi

  mkdir -p "$codex_dir"

  if [[ -f "$prompt_target" ]] && grep -q "$marker" "$prompt_target"; then
    log_warn "Prompt de Codex ya existe en agents.md"
    return
  fi

  if [[ -f "$prompt_target" ]]; then
    printf "\n\n" >> "$prompt_target"
    cat "$prompt_src" >> "$prompt_target"
  else
    cp "$prompt_src" "$prompt_target"
  fi

  if [[ ! -f "$prompt_target" ]]; then
    log_warn "No se pudo verificar el prompt de Codex"
    return
  fi

  log_info "codex prompt (agents.md)"
}

resolve_claude_code_dir() {
  local scope="$1"
  if [[ "$scope" == "local" ]]; then
    echo "./.claude"
    return
  fi
  local user_home
  user_home="$(resolve_user_home)"
  echo "${user_home}/.claude"
}

install_claude_code_prompt() {
  local scope="$1"
  local claude_md_src="${REPO_DIR}/examples/claude-code/CLAUDE.md"

  if [[ ! -f "$claude_md_src" ]]; then
    log_error "Missing examples/claude-code/CLAUDE.md"
    exit 1
  fi

  local claude_md_target
  if [[ "$scope" == "local" ]]; then
    claude_md_target="./CLAUDE.md"
  else
    local user_home
    user_home="$(resolve_user_home)"
    claude_md_target="${user_home}/.claude/CLAUDE.md"
  fi

  local marker="FLOW-NEA ORCHESTRATOR"

  if [[ -f "$claude_md_target" ]] && grep -q "$marker" "$claude_md_target"; then
    log_warn "Orchestrator instructions already exist in $(basename "$claude_md_target")"
    return
  fi

  if [[ "$scope" == "global" ]]; then
    local parent_dir
    parent_dir="$(dirname "$claude_md_target")"
    mkdir -p "$parent_dir"
  fi

  if [[ -f "$claude_md_target" ]]; then
    printf "\n\n" >> "$claude_md_target"
    cat "$claude_md_src" >> "$claude_md_target"
  else
    cp "$claude_md_src" "$claude_md_target"
  fi

  if [[ ! -f "$claude_md_target" ]]; then
    log_warn "Could not verify $(basename "$claude_md_target")"
    return
  fi

  log_info "${claude_md_target} (orchestrator instructions)"
}

install_claude_code_commands() {
  local target_dir="$1"
  local commands_src="${REPO_DIR}/examples/claude-code/commands"
  local commands_target="${target_dir}/commands"

  if [[ ! -d "$commands_src" ]]; then
    log_warn "Missing examples/claude-code/commands/"
    return
  fi

  mkdir -p "$commands_target"
  cp "${commands_src}"/*.md "$commands_target/"
  local cmd_count
  cmd_count=$(find "$commands_src" -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  log_info "${commands_target}/ (${cmd_count} commands)"
}

resolve_user_home() {
  if [[ -n "${HOME:-}" ]]; then
    echo "${HOME}"
    return
  fi
  if [[ -n "${USERPROFILE:-}" ]]; then
    echo "${USERPROFILE}"
    return
  fi
  log_error "Unable to determine the user home directory. Set HOME or USERPROFILE."
  exit 1
}

resolve_all_global_opencode_dir() {
  local user_home
  user_home="$(resolve_user_home)"
  echo "${user_home}/.opencode/skills"
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
        log_info ".opencode/opencode.json"
      else
        log_warn "Missing examples/opencode/opencode.json"
      fi
      if [[ -d "${REPO_DIR}/examples/opencode/commands" ]]; then
        mkdir -p .opencode/commands
        cp "${REPO_DIR}/examples/opencode/commands"/*.md .opencode/commands/
        log_info ".opencode/commands/ ($(ls ${REPO_DIR}/examples/opencode/commands/*.md | wc -l | tr -d ' ') commands)"
      fi
      ;;
    amazonq)
      install_skills ".amazonq/rules" "Amazon Q"
      install_amazonq_prompt
      printf "\n"
      log_warn "Skills instaladas en .amazonq/rules/"
      log_warn "Prompt instalado en ~/.aws/amazonq/prompts/amazon-instructions.md"
      printf "Siguiente paso: abre Amazon Q y ejecuta /flow-nea-init\n"
      ;;
    gemini-cli)
      if [[ -z "$SCOPE" ]]; then
        read -p "Scope (local/global): " SCOPE
      fi
      if [[ "$SCOPE" != "local" && "$SCOPE" != "global" ]]; then
        log_error "Scope invalido. Usa local o global."
        exit 1
      fi
      gemini_dir="$(resolve_gemini_skills_dir "$SCOPE")"
      install_skills "$gemini_dir" "Gemini CLI"
      install_gemini_prompt
      printf "\n"
      log_warn "Skills instaladas en ${gemini_dir}"
      log_warn "Prompt instalado en ~/.gemini/GEMINI.md"
      log_warn "Asegura GEMINI_SYSTEM_MD=1 en ~/.gemini/.env"
      printf "Siguiente paso: abre Gemini CLI y ejecuta /flow-nea-init\n"
      ;;
    codex)
      if [[ -z "$SCOPE" ]]; then
        read -p "Scope (local/global): " SCOPE
      fi
      if [[ "$SCOPE" != "local" && "$SCOPE" != "global" ]]; then
        log_error "Scope invalido. Usa local o global."
        exit 1
      fi
      codex_dir="$(resolve_codex_skills_dir "$SCOPE")"
      install_skills "$codex_dir" "Codex"
      install_codex_prompt
      printf "\n"
      log_warn "Skills instaladas en ${codex_dir}"
      log_warn "Prompt instalado en ~/.codex/agents.md"
      printf "Siguiente paso: abre Codex y ejecuta /flow-nea-init\n"
      ;;
    claude-code)
      if [[ -z "$SCOPE" ]]; then
        read -p "Scope (local/global): " SCOPE
      fi
      if [[ "$SCOPE" != "local" && "$SCOPE" != "global" ]]; then
        log_error "Scope invalido. Usa local o global."
        exit 1
      fi
      local claude_dir
      claude_dir="$(resolve_claude_code_dir "$SCOPE")"
      install_skills "${claude_dir}/skills" "Claude Code"
      install_claude_code_prompt "$SCOPE"
      install_claude_code_commands "$claude_dir"
      printf "\n"
      log_warn "Skills instaladas en ${claude_dir}/skills/"
      log_warn "Comandos instalados en ${claude_dir}/commands/"
      if [[ "$SCOPE" == "local" ]]; then
        log_warn "Instrucciones del orquestador agregadas a ./CLAUDE.md"
      else
        log_warn "Instrucciones del orquestador agregadas a ${claude_dir}/CLAUDE.md"
      fi
      printf "Siguiente paso: abre Claude Code y ejecuta /flow-nea-init\n"
      ;;
    vscode)
      install_skills ".vscode/skills" "VS Code (Copilot)"
      printf "\n"
      printf "Siguiente paso:\n"
      printf "  Agrega el orquestador a .github/copilot-instructions.md\n"
      printf "  Ver: examples/vscode/copilot-instructions.md\n"
      log_warn "Skills instaladas en el proyecto actual (.vscode/skills/)"
      ;;
    project-local)
      install_skills "./skills" "Project-local"
      printf "\n"
      log_warn "Skills instaladas en ./skills - relativo a este proyecto"
      ;;
    all-global)
      local user_home
      user_home="$(resolve_user_home)"
      local global_opencode_dir="${user_home}/.opencode"
      local global_skills_dir="${global_opencode_dir}/skills"

      install_skills "$global_skills_dir" "OpenCode (global)"

      if [[ -f "${REPO_DIR}/examples/opencode/opencode.json" ]]; then
        mkdir -p "$global_opencode_dir"
        cp "${REPO_DIR}/examples/opencode/opencode.json" "${global_opencode_dir}/opencode.json"
        log_info "${global_opencode_dir}/opencode.json"
      else
        log_warn "Missing examples/opencode/opencode.json"
      fi

      if [[ -d "${REPO_DIR}/examples/opencode/commands" ]]; then
        mkdir -p "${global_opencode_dir}/commands"
        cp "${REPO_DIR}/examples/opencode/commands"/*.md "${global_opencode_dir}/commands/"
        local cmd_count
        cmd_count=$(find "${REPO_DIR}/examples/opencode/commands" -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
        log_info "${global_opencode_dir}/commands/ (${cmd_count} commands)"
      fi

      log_warn "Skills instaladas globalmente para OpenCode en ${global_skills_dir}"
      log_warn "Assets de OpenCode en ${global_opencode_dir}"
      ;;
    custom)
      if [[ -z "$CUSTOM_PATH" ]]; then
        read -p "Enter target path: " CUSTOM_PATH
      fi
      if [[ -z "$CUSTOM_PATH" ]]; then
        log_error "No path provided"
        exit 1
      fi
      install_skills "$CUSTOM_PATH" "Custom"
      ;;
    *)
      log_error "Unknown agent: $agent"
      usage
      exit 1
      ;;
  esac
}

show_menu() {
  local all_global_dir
  all_global_dir="$(resolve_all_global_opencode_dir)"

  printf "Select your AI coding assistant:\n"
  printf "\n"
  printf "  1) OpenCode       (%s)\n" "${OPENCODE_SKILLS_DIR}"
  printf "  2) Amazon Q       (.amazonq/rules)\n"
  printf "  3) Gemini CLI     (local o global)\n"
  printf "  4) Codex          (local o global)\n"
  printf "  5) VS Code        (.vscode/skills)\n"
  printf "  6) Claude Code    (local o global)\n"
  printf "  7) Project-local  (./skills)\n"
  printf "  8) All global     (%s)\n" "${all_global_dir}"
  printf "  9) Custom path\n"
  printf "\n"

  read -p "Choice [1-9]: " choice
  case "$choice" in
    1) install_for_agent opencode ;;
    2) install_for_agent amazonq ;;
    3) install_for_agent gemini-cli ;;
    4) install_for_agent codex ;;
    5) install_for_agent vscode ;;
    6) install_for_agent claude-code ;;
    7) install_for_agent project-local ;;
    8) install_for_agent all-global ;;
    9) install_for_agent custom ;;
    *)
      log_error "Invalid choice"
      exit 1
      ;;
  esac
}

header
test_source_tree
check_dependencies
verify_checksums

if [[ -n "$TARGET_AGENT" ]]; then
  install_for_agent "$TARGET_AGENT"
else
  show_menu
fi

printf "\n"
printf "Listo! Empieza a usar NEA Flow con: /flow-nea-init\n"
printf "Backend de persistencia recomendado: OpenSpec\n"

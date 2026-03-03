#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Options:
  -a, --agent NAME   Install for a specific agent (non-interactive)
                     Valid: opencode, amazonq, vscode, project-local, all-global, custom
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--agent)
      TARGET_AGENT="$2"
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
  local prompt_src="${REPO_DIR}/examples/amazonq/amazon-instructions.md"
  local prompt_target="${amazonq_prompts_dir}/amazon-instructions.md"

  if [[ ! -f "$prompt_src" ]]; then
    err "Missing examples/amazonq/amazon-instructions.md"
    exit 1
  fi

  mkdir -p "$amazonq_prompts_dir"
  cp "$prompt_src" "$prompt_target"
  ok "amazonq prompt (amazon-instructions.md)"
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
      warn "Skills installed in .amazonq/rules/"
      warn "Prompt installed in ~/.aws/amazonq/prompts/amazon-instructions.md"
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
  echo "  3) VS Code        (.vscode/skills)"
  echo "  4) Project-local  (./skills)"
  echo "  5) All global     (OpenCode)"
  echo "  6) Custom path"
  echo ""

  read -r -p "Choice [1-6]: " choice
  case "$choice" in
    1) install_for_agent opencode ;;
    2) install_for_agent amazonq ;;
    3) install_for_agent vscode ;;
    4) install_for_agent project-local ;;
    5) install_for_agent all-global ;;
    6) install_for_agent custom ;;
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

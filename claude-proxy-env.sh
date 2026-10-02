#!/usr/bin/env bash

if [[ -n "${BASH_VERSION:-}" ]]; then
  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  SCRIPT_DIR="${${(%):-%N}:A:h}"
else
  printf 'Erreur : ce script nécessite Bash ou Zsh.\n' >&2
  return 1 2>/dev/null || exit 1
fi

if [[ -f "$SCRIPT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.env"
  set +a
fi

: "${LITELLM_MASTER_KEY:?LITELLM_MASTER_KEY doit être défini dans .env ou dans l environnement}"

export ANTHROPIC_BASE_URL="${ANTHROPIC_BASE_URL:-http://localhost:4000}"
export ANTHROPIC_AUTH_TOKEN="$LITELLM_MASTER_KEY"
unset ANTHROPIC_API_KEY

export ANTHROPIC_MODEL="openai/gpt-oss-20b"
export ANTHROPIC_DEFAULT_OPUS_MODEL="$ANTHROPIC_MODEL"
export ANTHROPIC_DEFAULT_SONNET_MODEL="$ANTHROPIC_MODEL"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="$ANTHROPIC_MODEL"
export CLAUDE_CODE_SUBAGENT_MODEL="$ANTHROPIC_MODEL"
export DISABLE_INTERLEAVED_THINKING="${DISABLE_INTERLEAVED_THINKING:-1}"

claude_model_names() {
  awk '
    /^[[:space:]]*-[[:space:]]*model_name:[[:space:]]*/ {
      sub(/^[[:space:]]*-[[:space:]]*model_name:[[:space:]]*/, "")
      sub(/[[:space:]]+#.*$/, "")
      gsub(/^["'\'']|["'\'']$/, "")
      if ($0 != "") print
    }
  ' "$SCRIPT_DIR/litellm_config.yaml"
}

_claude_model_completion() {
  local current="${COMP_WORDS[COMP_CWORD]}"
  local models

  models="$(claude_model_names)" || return 1
  COMPREPLY=( $(compgen -W "$models" -- "$current") )
}

claude-model() {
  local selected="${1:-}"
  local models

  models="$(claude_model_names)"
  if [[ -z "$models" ]]; then
    printf 'Erreur : aucun model_name trouvé dans %s/litellm_config.yaml\n' "$SCRIPT_DIR" >&2
    return 1
  fi

  if [[ $# -gt 1 ]]; then
    printf 'Usage : claude-model [model_name]\n' >&2
    return 2
  fi

  if [[ -z "$selected" ]]; then
    printf 'Modèles configurés :\n%s\n' "$models"
    printf 'Usage : claude-model <TAB> ou claude-model <model_name>\n'
    return 0
  fi

  if [[ -z "$selected" ]] || ! grep -Fqx -- "$selected" <<< "$models"; then
    printf 'Erreur : modèle absent de litellm_config.yaml : %s\n' "${selected:-<aucun>}" >&2
    return 1
  fi

  export ANTHROPIC_MODEL="$selected"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="$selected"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="$selected"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="$selected"
  export CLAUDE_CODE_SUBAGENT_MODEL="$selected"
  printf 'Modèle sélectionné : %s\n' "$selected"
}

if [[ -n "${BASH_VERSION:-}" ]]; then
  complete -F _claude_model_completion claude-model
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  _claude_model_completion_zsh() {
    local -a models
    models=("${(@f)$(claude_model_names)}")
    _describe 'model' models
  }

  autoload -Uz compinit
  compinit
  compdef _claude_model_completion_zsh claude-model
fi

printf 'Variables Claude configurées pour le proxy LiteLLM sur %s\n' "$ANTHROPIC_BASE_URL"

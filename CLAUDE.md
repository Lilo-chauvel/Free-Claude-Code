# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Please Note**: You are operating within Claude Code. Do **not** invoke arbitrary shell commands or scripts outside the toolset provided by Claude Code; instead, use the available tools (Bash, Read, Write, etc.) as permitted by the user's permissions.

## 1. Common commands

| Purpose | Command | Note |
|---------|---------|------|
| Build the Docker image for the LiteLLM proxy | `docker build -t model-ia-proxy:latest -f Dockerfile .` | Run in the repo root; the image will be used in `compose.yml`.
| Start the proxy in the background | `docker compose up -d` | This loads the container created above.
| Stop the proxy | `docker compose down` | Stops and removes the container.
| Run the convenience wrapper that starts the proxy | `./start-proxy.sh` | Equivalent to the compose commands; it also sets up the correct working directory for the Docker context.
| Set up and launch Claude Code to use the proxy | `source ./claude-proxy-env.sh && claude` | `claude-proxy-env.sh` injects `ANTHROPIC_*` env vars and sources your `.env`.
| List available models defined in `litellm_config.yaml` | `claude-model` | Prints the `model_name` entries.
| Switch the default model for the current shell | `claude-model <model_name>` | Updates `ANTHROPIC_MODEL` and its Opus/Sonnet/Haiku variants.
| Run a single test (if any) | `pytest -q <path/to/test.py>` | If the project grows test files.
| Lint the code base | `ruff check .` | Requires RUFF; linting rules are embedded in `pyproject.toml` by default.
| Format the code | `ruff format .` | Runs the auto‑formatter to keep code style consistent.

## 2. Architecture overview

- **Docker** – The repo contains a `Dockerfile` that installs `litellm` (proxy) and downloads the LiteLLM proxy image. The `compose.yml` runs that image as a container listening on `127.0.0.1:4000`.
- **Environment** – Configurable variables such as `ANTHROPIC_*` are set in `claude-proxy-env.sh`. This script reads a `.env` file for `NVIDIA_API_KEY` and `LITELLM_MASTER_KEY`, then exports the required auth and model variables used by Claude Code.
- **Configuration** – `litellm_config.yaml` declares the available `model_name` entries and the corresponding `litellm_params` mapping to the underlying LLM provider. It also contains global settings like `drop_params` and `master_key`.
- **Proxy** – The start script `start-proxy.sh` launches the Docker container. The proxy presents a standard OpenAI‑compatible endpoint to Claude Code.
- **Documentation** – `nice_readme/index.html` holds a tiny static site that explains how to use the repo.

Future Claude Code sessions can rely on this layout: configure your YAML, source `claude-proxy-env.sh`, start the proxy with VS Code or shell, then call `claude` and navigate via `claude-model`.

The repository contains no test suite or CI configuration at the moment; new tests can be added under a `tests/` directory and executed with `pytest`.

---

This completes the instructions required for a new Claude Code user.

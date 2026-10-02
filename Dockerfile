FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project --no-dev

COPY litellm_config.yaml ./

EXPOSE 4000

HEALTHCHECK --interval=10s --timeout=5s --start-period=20s --retries=6 \
  CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:4000/health/liveliness', timeout=3)"]

ENTRYPOINT ["/app/.venv/bin/litellm"]
CMD ["--config", "/app/litellm_config.yaml", "--port", "4000"]

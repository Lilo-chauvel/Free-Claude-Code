# Proxy LiteLLM pour Claude Code

Cette copie Dockerise uniquement le proxy LiteLLM. Claude Code reste installé et lancé sur la machine hôte.

## Préparation

```bash
cp .env.example .env
```

Renseignez ensuite `NVIDIA_API_KEY` et `LITELLM_MASTER_KEY` dans `.env`.

## Démarrer le proxy

```bash
./start-proxy.sh
```

Le proxy est publié uniquement sur `127.0.0.1:4000`.

## Utiliser Claude Code avec le proxy

Dans le terminal depuis lequel Claude Code doit être lancé :

```bash
source ./claude-proxy-env.sh
claude
```

Le script ne lance jamais `claude`. Il configure seulement les variables d'environnement nécessaires pour que Claude Code utilise LiteLLM et le modèle NVIDIA configuré.

## Arrêter le proxy

```bash
docker compose down
```

Les valeurs réelles de `.env` ne doivent pas être versionnées ni partagées.

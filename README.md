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

## Choisir un modèle avec la complétion du shell

Après avoir chargé l'environnement :

```bash
source ./claude-proxy-env.sh
claude-model <TAB>
```

La touche `TAB` propose uniquement les modèles déclarés par `model_name` dans
`litellm_config.yaml`, avec Bash ou Zsh. Après sélection :

```bash
claude
```

La fonction ne lance pas Claude Code. Elle met à jour le modèle utilisé par la
prochaine commande `claude`. Si vous appelez la fonction sans argument, elle
affiche la liste des modèles disponibles. Il est aussi possible de sélectionner
directement un modèle :

```bash
claude-model nvidia/nemotron-3-super-120b-a12b
```

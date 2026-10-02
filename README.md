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

---

## Paramétrage des modèles

Les modèles sont déclarés dans le fichier `litellm_config.yaml`, qui possède la structure suivante :

```yaml
model_list:
  - model_name: "<short-name>"
    litellm_params:
      model: <model-id-used-by-LiteLLM>
      api_base: <base-url>
      api_key: os.environ/<ENV_VAR>

# Options globales
litellm_settings:
  drop_params: true

general_settings:
  master_key: os.environ/LITELLM_MASTER_KEY
```

### Ajout d'un nouveau modèle

1. Ouvrez `litellm_config.yaml`.
2. Ajoutez une entrée dans `model_list` avec un `model_name` unique.
3. Remplissez `litellm_params` avec les paramètres requis par LiteLLM:
   * `model`: identifiant du modèle tel qu'accepté par LiteLLM (ex. `openai/nvidia/nemotron-3-super-120b-a12b`).
   * `api_base`: URL de base de l'API. Pour les modèles NVIDIA, c'est généralement `https://integrate.api.nvidia.com/v1`.
   * `api_key`: soit une valeur fixe, soit une référence à une variable d'environnement (`os.environ/NVIDIA_API_KEY`).
4. Enregistrez le fichier.
5. Rechargez l'environnement (ou ouvrez un nouveau terminal) :
   ```bash
   source ./claude-proxy-env.sh
   ```

Le script `claude-proxy-env.sh` lit ce fichier et expose vos modèles via la fonction `claude-model`. Vous pouvez maintenant choisir votre modèle.

### Utilisation de la fonction `claude-model`

- **Lister les modèles disponibles**:
  ```bash
  claude-model
  ```

- **Choisir un modèle**:
  ```bash
  claude-model <model_name>
  ```
  Cela met à jour la variable d'environnement `ANTHROPIC_MODEL` et celles des variantes par défaut (Opus, Sonnet, Haiku).

- **Vérifier le modèle actif**:
  ```bash
  echo "$ANTHROPIC_MODEL"
  ```

### Considérations de sécurité

- Le fichier `litellm_config.yaml` est **privé** ; il ne doit tout jamais être versionné.
- Les `api_key` sérvent souvent de variables d'environnement pour garder les clés hors du dépôt.
- Le champ `drop_params: true` indique à LiteLLM de retirer les paramètres inutiles de la requête.

---

> **Astuce** : Tapez `claude-model <TAB>` pour obtenir instantanément la liste des modèles valides.

---


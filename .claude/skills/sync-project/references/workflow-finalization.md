# Pattern: Workflow Finalization

> Pattern réutilisable pour la fin des workflows avec sync/documentation intelligente.

---

## Quand Proposer Sync/Documentation

**PROPOSER si l'un de ces critères est vrai :**

| Critère | Exemples |
|---------|----------|
| Dev significatif terminé | Story complète, feature implémentée |
| Changements structurels | Nouveaux fichiers, dossiers, workflows |
| Décisions techniques | Architecture, choix de libs, patterns |
| Problèmes résolus | Bugs fixés avec solution non triviale |
| Oneshot terminé | Toute feature oneshot complète |

**NE PAS PROPOSER si :**
- Simple exploration sans changement
- Petit fix trivial (typo, formatting)
- Échec du workflow (rien à documenter)
- User a explicitement refusé précédemment

---

## Logique de Décision

```
FIN DE WORKFLOW
    │
    ├── Analyser: Y a-t-il eu du travail significatif ?
    │   │
    │   ├── NON → Fin sans proposition
    │   │
    │   └── OUI → Continuer
    │
    ├── Mode du workflow ?
    │   │
    │   ├── SUPERVISED (default)
    │   │   └── AskUserQuestion:
    │   │       "Travail terminé. Voulez-vous synchroniser les références et/ou documenter cette session ?"
    │   │       Options:
    │   │         - "Sync + Doc (Recommandé)" → Lance les deux
    │   │         - "Sync uniquement" → Lance /sync-project
    │   │         - "Doc uniquement" → Lance /documentation
    │   │         - "Non merci" → Fin
    │   │
    │   └── AUTO (--auto)
    │       └── Décider intelligemment :
    │           - Si changements structurels → /sync-project --silent via agent
    │           - Si travail significatif → /documentation --auto via agent
    │           - Les deux si applicable
```

---

## Implémentation Mode Supervised

```markdown
## Finalisation (après dernière étape)

### Analyse du travail effectué

Évaluer si le travail mérite sync/documentation :
- Fichiers créés/modifiés : {liste}
- Décisions prises : {liste}
- Problèmes résolus : {liste}

### Si travail significatif détecté

{AskUserQuestion}
question: "Travail terminé avec succès. Voulez-vous mettre à jour les références projet et/ou documenter cette session ?"
header: "Finalisation"
options:
  - label: "Sync + Documentation (Recommandé)"
    description: "Met à jour INDEX/CLAUDE.md + documente le travail"
  - label: "Sync uniquement"
    description: "Met à jour les fichiers de référence"
  - label: "Documentation uniquement"
    description: "Documente cette session de travail"
  - label: "Terminer sans"
    description: "Le travail est terminé, pas besoin"
```

---

## Implémentation Mode Auto

```markdown
## Finalisation Auto (via Agent)

### Décision autonome

SI changements structurels (nouveaux fichiers dans .claude/skills/, docs/epics/, etc.) :
    → Lancer /sync-project --silent via Task agent (model: sonnet)

SI travail significatif (features, stories, decisions) :
    → Lancer /documentation --auto via Task agent (model: sonnet)

### Lancement Agent

{Task tool}
subagent_type: general-purpose
model: sonnet
description: "Finalization sync/doc"
prompt: |
  Execute /sync-project --silent pour mettre à jour les références projet.
  Puis execute /documentation --auto --scope=all pour documenter le travail.

  Context:
  - Fichiers modifiés: {liste}
  - Travail effectué: {résumé}

  Exécute silencieusement, pas besoin de rapport détaillé.
```

---

## Code Snippet pour Steps

### Pour étape finale (supervised)

```markdown
## Proposer Finalisation

### Analyser le travail

**Fichiers impactés:** {count} fichiers
**Type de travail:** {story|feature|fix|exploration}
**Significatif:** {OUI si > 2 fichiers ou décisions importantes}

### Si significatif

{AskUserQuestion avec options sync/doc}

### Exécuter selon choix

SI "Sync + Doc" → Invoke /sync-project puis /documentation
SI "Sync uniquement" → Invoke /sync-project
SI "Doc uniquement" → Invoke /documentation
SI "Terminer sans" → Fin du workflow
```

### Pour étape finale (auto)

```markdown
## Finalisation Auto

### Évaluation

**Changements structurels:** {OUI/NON}
**Travail significatif:** {OUI/NON}

### Exécution (si applicable)

SI changements structurels OU travail significatif:
    Lance Task agent (sonnet) pour /sync-project --silent et/ou /documentation --auto
    Ne pas attendre la fin - workflow terminé

SINON:
    Fin du workflow sans action supplémentaire
```

---

## Workflows Concernés

| Workflow | Sync probable | Doc probable | Notes |
|----------|---------------|--------------|-------|
| /create-epic | ✅ Toujours | ⚠️ Parfois | Nouveaux fichiers Epic |
| /create-story | ✅ Toujours | ❌ Rarement | Stories créées |
| /dev-story | ⚠️ Parfois | ✅ Toujours | Implémentation significative |
| /launch-epic | ⚠️ Parfois | ✅ Toujours | Travail Epic complet |
| /oneshot | ⚠️ Parfois | ✅ Toujours | Feature complète |
| /debug | ⚠️ Parfois | ⚠️ Parfois | Si fix structural ou significatif |

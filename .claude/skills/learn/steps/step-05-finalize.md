# Step 05: Finalize

> Résumé final et proposition d'archivage.

---

## Objectif

Présenter un résumé de la knowledge base créée et proposer les prochaines actions.

---

## Summary Generation

Présenter à l'utilisateur :

```markdown
## Knowledge Base Créée : {topic}

**Localisation** : `workspace/current/{topic_sanitized}/`

### Fichiers Générés

| Fichier | Contenu | Lignes |
|---------|---------|--------|
| INDEX.md | Navigation et résumé | N |
| architecture.md | Design decisions | N |
| key-files.md | Référence fichiers clés | N |
| gotchas.md | Pièges et edge cases | N |
| context.md | Contexte pour sessions | N |

### Métriques

- **Fichiers analysés** : N primary, N secondary
- **Patterns identifiés** : N
- **Gotchas documentés** : N critical, N important, N minor
- **Niveau de compréhension** : {score}% ({confidence})
- **Références vérifiées** : N/N (100%)

### Utilisation Recommandée

1. **Nouvelle conversation** : Copier le block de `context.md`
2. **Debugging** : Consulter `gotchas.md`
3. **Modification** : Lire `architecture.md` puis `key-files.md`

### Limitations Connues

{Si validation a identifié des gaps}
- {Limitation 1}
- {Limitation 2}
```

---

## Archive Proposal

Proposer via AskUserQuestion :

```yaml
AskUserQuestion:
  question: "Que voulez-vous faire avec cette knowledge base ?"
  header: "Action"
  options:
    - label: "Garder dans current/"
      description: "Laisser dans workspace/current/ pour usage immédiat"

    - label: "Archiver"
      description: "Déplacer vers workspace/archive/{topic}/ avec date"

    - label: "Promouvoir en doc"
      description: "Copier vers docs/detailed/{topic}/ (permanent)"
```

---

## Action Execution

### Option: Garder dans current/

```yaml
Action: None
Message: "Knowledge base disponible dans workspace/current/{topic_sanitized}/"
```

### Option: Archiver

```yaml
Action:
  1. Create: workspace/archive/{topic_sanitized}_{date}/
  2. Move: All files from current/ to archive/
  3. Update: INDEX.md with archive date

Message: "Archivé dans workspace/archive/{topic_sanitized}_{date}/"
```

### Option: Promouvoir en doc

```yaml
Action:
  1. Create: docs/detailed/{topic_sanitized}/
  2. Copy: All files (keep original in current/)
  3. Update: docs/detailed/README.md with new entry
  4. Propose: /sync-project pour mettre à jour INDEX.md

Message: "Promu vers docs/detailed/{topic_sanitized}/"
Note: "Suggestion: Lancer /sync-project pour mettre à jour les références"
```

---

## Final Output

```yaml
learn_session_complete:
  topic: "{topic}"
  output_location: "workspace/current/{topic_sanitized}/"
  files_created: 5
  total_lines: N

  analysis_depth: "{depth}"
  comprehension_score: N%
  validation_score: N%

  agents_used:
    haiku: 3
    sonnet: 3
    opus: 1 (orchestration)

  action_taken: "kept" | "archived" | "promoted"
  final_location: "path/to/final/"

  next_steps:
    - "Utiliser context.md pour onboarder de nouvelles conversations"
    - "Consulter gotchas.md avant modifications"
    - "Mettre à jour si le code évolue significativement"
```

---

## Closing Message

```markdown
## /learn Terminé

La knowledge base pour **{topic}** est prête.

**Pour l'utiliser** : Copie le bloc de contexte de `context.md` dans une nouvelle conversation.

**Pour maintenir** : Re-lance `/learn {topic}` si le code évolue significativement.
```

---

## End of Workflow

Le workflow `/learn` est terminé. Pas de step suivant.

# Workflows

## Developper

**`/dev-story`** — Implementer une story (TDD, 9 etapes)
- `/dev-story STORY-01-01`
- `/dev-story STORY-01-01 --mode=auto`

**`/oneshot`** — Dev rapide sans Epic/Story (< 1 jour)
- `/oneshot "Ajouter bouton logout"`
- `/oneshot "Fix validation email" --mode=auto`

**`/debug`** — Investigation bug (Constrained ReAct)
- `/debug Le bouton submit ne marche pas`
- `/debug --auto Erreur 500 sur l'API`

**`/commit`** — Commit (bloque si tests fail)
- `/commit`

---

## Creer

**`/create-epic`** — Creer Epic depuis PRD
- `/create-epic authentication`

**`/create-story`** — Decomposer Epic en Stories
- `/create-story EPIC-01`

**`/create-workflow`** — Creer/modifier workflow
- `/create-workflow mon-workflow`

**`/launch-epic`** — Lancer Epic complet
- `/launch-epic EPIC-01`
- `/launch-epic EPIC-01 --mode=autonomous`

---

## Apprendre

**`/learn`** — Comprendre feature → Doc LLM-optimized
- `/learn auth-system`
- `/learn state-management --depth=deep`
- `/learn "workout tracking" --depth=quick`

**`/explore`** — Exploration rapide codebase/docs/web
- `/explore Comment marche l'auth ?`

---

## Utilitaires

**`/documentation`** — Documenter session de travail
- `/documentation`
- `/documentation --auto`

**`/sync-project`** — Sync INDEX/README/CLAUDE.md
- `/sync-project`
- `/sync-project --silent`

**`/prompt`** — Traduire prompt en anglais LLM
- `/prompt Ajoute validation email`

---

## Git

**`/git:create-pr`** — Creer PR
- `/git:create-pr`

**`/git:fix-pr-comments`** — Fix commentaires PR
- `/git:fix-pr-comments 123`

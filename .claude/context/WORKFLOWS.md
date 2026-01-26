# Workflows

## Developper

**`/dev-story`** — Implementer une story (TDD, 9 etapes + documentation)
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

**`/mission`** — Brief client → Mission + Epics + Stories (cascade adaptative Haiku→Sonnet→Opus)
- `/mission docs/brief-client.md`
- `/mission workspace/current/devis-2026.md`

**`/create-epic`** — Creer Epic depuis PRD (mode --auto disponible)
- `/create-epic authentication`
- `/create-epic --auto` *(selectionne premier Epic non-cree)*

**`/create-story`** — Decomposer Epic en Stories (mode --auto disponible)
- `/create-story EPIC-01`
- `/create-story EPIC-01 --auto` *(generation 100% autonome)*

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

## Securite

**`/security-audit`** — Audit complet securite + qualite (OWASP, secrets, deps)
- `/security-audit`
- `/security-audit --scope=auth` *(audit cible)*

---

## Utilitaires

**`/documentation`** — Documenter session de travail
- `/documentation`
- `/documentation --auto`

**`/sync-project`** — Sync INDEX/README/CLAUDE.md
- `/sync-project`
- `/sync-project --silent`

**`/sync-template`** — Exporter config vers repo template
- `/sync-template --dry-run`
- `/sync-template --push`

**`/update-config`** — Importer config depuis template (avec CHANGELOG)
- `/update-config --dry-run`
- `/update-config --force`

**`/prompt`** — Traduire prompt en anglais LLM
- `/prompt Ajoute validation email`

---

## Git

**`/git:create-pr`** — Creer PR
- `/git:create-pr`

**`/git:fix-pr-comments`** — Fix commentaires PR
- `/git:fix-pr-comments 123`

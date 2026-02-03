# Reference: Coordination Inter-Agents (Mode DEEP)

> Guide pour la coordination entre le Chef Opus et les sub-agents en mode DEEP.

---

## Vue d'ensemble

En mode `--deep`, le Chef Opus maintient un fichier de coordination pour :
- Suivre l'etat de chaque story
- Partager les decisions entre agents
- Tracer les violations Design System
- Documenter les fichiers crees/modifies

---

## Fichier COORDINATION.md

### Emplacement

```
{scratchpad}/COORDINATION-{epic_id}.md
```

Exemple: `/private/tmp/claude-501/.../scratchpad/COORDINATION-EPIC-10.md`

### Structure

```markdown
# COORDINATION EPIC: {epic_id}

> Fichier de coordination inter-agents - Mode DEEP
> Chef Opus: Garant de la coherence et qualite
> Derniere mise a jour: {timestamp}

---

## Status Global

| Story | Status | Sub-Agent | Verification Chef | Design System | Iterations |
|-------|--------|-----------|-------------------|---------------|------------|
| S01 | ✅ DONE | Opus #1 | ✅ VERIFIED | ✅ CONFORME | 2 |
| S02 | 🔄 IN_PROGRESS | Opus #2 | ⏳ PENDING | ⏳ PENDING | - |
| S03 | ⏸️ NOT_STARTED | - | - | - | - |

**Legende:**
- ✅ DONE: Story complete et verifiee
- 🔄 IN_PROGRESS: Story en cours
- ⏸️ NOT_STARTED: Story pas encore commencee
- ❌ BLOCKED: Story bloquee (voir Notes)

---

## Decisions Partagees

### Patterns a Reutiliser

| Decision | Story Source | Applicable a | Rationale |
|----------|--------------|--------------|-----------|
| Pattern BLoC pour pages liste | S01 | S02, S03, S05 | Coherence avec architecture existante |
| Composant MediaGrid cree | S01 | S04, S06 | Reutiliser pour toutes les grilles medias |
| LynewedSheet pour tous les formulaires | S01 | Toutes | Conformite Design System |

### Conventions Etablies

- **Nommage fichiers**: `{feature}_{type}.dart` (ex: `album_page.dart`)
- **Structure dossiers**: `presentation/pages/`, `presentation/widgets/`
- **Imports**: Toujours utiliser `import '/core/design/design.dart';`

---

## Design System Compliance

### Verifications Reussies

| Story | Check | Result |
|-------|-------|--------|
| S01 | LynewedButton | ✅ 5 occurrences |
| S01 | LynewedTextField | ✅ 2 occurrences |
| S01 | LynewedColors | ✅ Pas de Colors.xxx |
| S01 | LynewedTextStyles | ✅ Pas de TextStyle direct |

### Violations Detectees et Corrigees

| Story | Violation | Fichier:Ligne | Correction | Status |
|-------|-----------|---------------|------------|--------|
| S02 | ElevatedButton | `upload_page.dart:42` | → LynewedButton | ✅ CORRIGE |
| S02 | Colors.blue | `upload_page.dart:78` | → LynewedColors.primary | ✅ CORRIGE |

---

## Fichiers Crees/Modifies

### Par Story

#### S01: {titre story}

**Crees:**
- `lib/features/photos/presentation/pages/album_page.dart`
- `lib/features/photos/presentation/widgets/media_grid.dart`
- `test/features/photos/presentation/pages/album_page_test.dart`

**Modifies:**
- `lib/features/photos/domain/entities/album.dart` (ajout champ)

#### S02: {titre story}

**Crees:**
- `lib/features/photos/presentation/pages/upload_page.dart`
- ...

---

## Notes Inter-Agents

### Informations Importantes

- [INFO] S01: Pattern MediaGrid peut etre reutilise pour S04
- [INFO] S02: Attention aux permissions camera/galerie
- [WARNING] S03 depend de S02 - ne pas commencer avant

### Problemes Rencontres

- [ISSUE] S01: Bug detecte dans image picker - corrige via /debug
- [ISSUE] S02: Test flaky sur upload - stabilise avec mock

### Questions pour Chef

- [QUESTION] S03: Doit-on supporter le format HEIC ? → OUI (valide par Chef)

---

## Progression Globale

```
Epic: {epic_id}
Stories: {done}/{total} ({percentage}%)

Progress: [██████████░░░░░░░░░░] 50%

Temps estime restant: {X} stories * ~15 min = ~{Y} min
```

---

## Checklist Finale Chef

A verifier quand TOUTES les stories sont DONE:

- [ ] Toutes stories COMPLETE et VERIFIED
- [ ] Design System 100% conforme globalement
- [ ] Coherence entre stories (pas de patterns contradictoires)
- [ ] Tous tests passent (`flutter test`)
- [ ] 0 warnings (`flutter analyze --fatal-infos`)
- [ ] Fichiers coherents (pas de duplication inutile)
- [ ] Documentation a jour

---

## Historique

| Timestamp | Action | Agent | Details |
|-----------|--------|-------|---------|
| {time} | Epic started | Chef | Mode: autonomous --deep |
| {time} | S01 delegated | Chef → Opus #1 | Instructions enrichies |
| {time} | S01 completed | Opus #1 | Status: COMPLETE |
| {time} | S01 verified | Chef | Verdict: ✅ PARFAIT |
| {time} | S02 delegated | Chef → Opus #2 | Instructions avec patterns S01 |
```

---

## Usage par le Chef Opus

### Initialisation

Au debut de l'Epic, creer le fichier:

```yaml
action: Write COORDINATION.md
content: |
  # COORDINATION EPIC: {epic_id}
  ... (template ci-dessus)
```

### Mise a jour apres chaque story

```yaml
after_story_complete:
  1. Mettre a jour Status Global
  2. Ajouter fichiers crees/modifies
  3. Documenter decisions partagees
  4. Tracer violations DS corrigees
  5. Ajouter notes importantes
  6. Mettre a jour progression
```

### Verification finale

```yaml
before_finalize:
  1. Lire COORDINATION.md
  2. Verifier coherence globale
  3. Checker tous les checkpoints DS
  4. Valider checklist finale
```

---

## Pattern d'Instructions Enrichies

Quand le Chef delegue a un sub-agent, inclure :

```yaml
enriched_instructions:
  - Decisions partagees applicables
  - Patterns a reutiliser
  - Fichiers de reference
  - Contraintes Design System
  - Notes des stories precedentes
```

Exemple:

```markdown
## Instructions Enrichies pour Sub-Agent

### Patterns a Reutiliser (de COORDINATION.md)
- MediaGrid de S01 pour les grilles
- Pattern BLoC pour la page

### Fichiers de Reference
- `lib/features/photos/presentation/pages/album_page.dart` (pattern page)
- `lib/features/photos/presentation/widgets/media_grid.dart` (grille)

### Design System (OBLIGATOIRE)
- LynewedButton pour tous les boutons
- LynewedColors pour les couleurs
- Import: `import '/core/design/design.dart';`

### Notes du Chef
- Cette story depend de S01 (utiliser les fichiers crees)
- Attention aux permissions camera
```

---

## Bonnes Pratiques

1. **Mise a jour immediate** - Mettre a jour COORDINATION.md des qu'une action est faite
2. **Decisions documentees** - Toute decision importante doit etre tracee
3. **Violations tracees** - Chaque violation DS doit etre documentee et corrigee
4. **Historique complet** - Tracer toutes les actions pour debug si necessaire
5. **Instructions enrichies** - Toujours inclure le contexte des stories precedentes

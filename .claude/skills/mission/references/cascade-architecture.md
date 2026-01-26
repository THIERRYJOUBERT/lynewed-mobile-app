# Cascade Architecture Reference

> Documentation de l'architecture cascade adaptative utilisee par /mission.

---

## Vue d'ensemble

L'architecture cascade utilise 3 tiers de modeles pour optimiser le ratio cout/qualite :

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CASCADE ADAPTATIVE                                        │
│                                                                              │
│  TIER 1: SCAN (Haiku)                                                       │
│  ─────────────────────                                                      │
│  • Modele : Haiku (cheap, fast)                                             │
│  • Nombre : 3-10 agents (adaptatif)                                         │
│  • Role : Decouverte rapide, extraction, inventaire                         │
│  • Execution : PARALLELE (tous en 1 message)                                │
│                                                                              │
│  TIER 2: ANALYZE (Sonnet)                                                   │
│  ─────────────────────                                                      │
│  • Modele : Sonnet (medium cost, deep)                                      │
│  • Nombre : 3-5 agents (adaptatif)                                          │
│  • Role : Analyse profonde, patterns, risques                               │
│  • Execution : PARALLELE (tous en 1 message)                                │
│                                                                              │
│  TIER 3: SYNTHESIZE (Opus)                                                  │
│  ─────────────────────                                                      │
│  • Modele : Opus (high cost, high quality)                                  │
│  • Nombre : 1 (agent principal)                                             │
│  • Role : Synthese, decisions strategiques, generation                      │
│  • Execution : Sequentiel (apres tiers 1 et 2)                              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Calcul adaptatif du nombre d'agents

### Tier 1 - Haiku (3-10 agents)

Le nombre d'agents Haiku depend de la taille de la codebase :

| Taille Codebase | Fichiers | Haiku Agents | Couverture |
|-----------------|----------|--------------|------------|
| Small | < 50 | 3 | Brief only |
| Medium | 50-150 | 5 | + Structure |
| Large | 150-500 | 7 | + Patterns, Deps |
| XLarge | > 500 | 10 | Full exploration |

**Agents Brief (toujours):**
1. brief-requirements
2. brief-technical
3. brief-priorities

**Agents Codebase (conditionnels):**
4. codebase-structure (>= 4 agents)
5. codebase-patterns (>= 5 agents)
6. codebase-deps (>= 6 agents)
7. codebase-tests (>= 7 agents)
8. codebase-config (>= 8 agents)
9. codebase-api (>= 9 agents)
10. codebase-models (>= 10 agents)

### Tier 2 - Sonnet (3-5 agents)

Le nombre d'agents Sonnet depend de la complexite du brief :

| Complexite Brief | Caracteres | Sonnet Agents |
|------------------|------------|---------------|
| Simple | < 2000 | 3 |
| Medium | 2000-5000 | 4 |
| Complex | > 5000 | 5 |

**Agents toujours presents:**
1. scope-analyzer
2. arch-analyzer
3. risk-analyzer

**Agents conditionnels:**
4. integration-analyzer (si existing codebase)
5. validation-analyzer (si brief complexe)

---

## Execution parallele

**CRITICAL**: Les agents d'un meme tier DOIVENT etre lances en parallele.

### Correct ✅

```
// Single message with 3 Task calls
Task 1: brief-requirements (haiku)
Task 2: brief-technical (haiku)
Task 3: brief-priorities (haiku)
// All 3 execute simultaneously
```

### Incorrect ❌

```
// Message 1
Task 1: brief-requirements (haiku)
// Wait for result
// Message 2
Task 2: brief-technical (haiku)
// Wait for result
// Message 3
Task 3: brief-priorities (haiku)
// 3x slower!
```

---

## Gestion des resultats

### Aggregation entre tiers

```yaml
tier_1_output:
  scan_results:
    brief: {...}      # Merged from 3 brief agents
    codebase: {...}   # Merged from codebase agents

tier_2_input: tier_1_output

tier_2_output:
  analysis_results:
    features_grouped: [...]
    architecture: {...}
    risks: {...}

tier_3_input: tier_1_output + tier_2_output

tier_3_output:
  mission_document: {...}  # Complete synthesized mission
```

### Gestion des echecs

Si un agent echoue :

1. **Retry** - Relancer avec scope reduit
2. **Skip** - Continuer sans (si non-critique)
3. **Document** - Noter le gap dans les resultats
4. **Max retries** - 2 par agent

---

## Estimation de cout

### Par tier

| Tier | Model | Cost Base | Agents | Cost Tier |
|------|-------|-----------|--------|-----------|
| 1 | Haiku | 1x | 3-10 | 3-10x |
| 2 | Sonnet | 5x | 3-5 | 15-25x |
| 3 | Opus | 15x | 1 | 15x |

### Total estime

| Scenario | Haiku | Sonnet | Opus | Total |
|----------|-------|--------|------|-------|
| Minimal | 3x | 15x | 15x | ~33x |
| Medium | 5x | 20x | 15x | ~40x |
| Maximum | 10x | 25x | 15x | ~50x |

**Note**: Ces estimations sont indicatives. Le cout reel depend de la longueur des prompts et reponses.

---

## Quand utiliser cette architecture

### Appropriee ✅

- Brief/devis complexe avec plusieurs fonctionnalites
- Codebase existante a explorer
- Besoin de structuration en Epics/Stories
- Mission multi-semaines

### Pas necessaire ❌

- Feature simple (< 1 jour) → /oneshot
- Epic deja defini → /create-story
- Exploration rapide → /explore
- Bug fix → /debug

---

## References

- SKILL.md principal: `/mission`
- Workflow similaire: `/learn` (utilise aussi cascade)
- Pattern source: `create-workflow/references/decision-matrix.md`

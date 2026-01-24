# Conventions {{PROJECT_NAME}} pour Subagents

> **IMPORTANT** : Ce fichier ajoute les conventions specifiques {{PROJECT_NAME}} aux best practices Anthropic.

## Principe Fondamental

**Les subagents ont TOUS les tools.** La specialisation est dans les INSTRUCTIONS, pas dans les permissions. On fait confiance aux subagents.

```yaml
# CORRECT - Pas de restriction de tools
---
name: story-01-auth
description: "Implementer Story 01 avec focus authentification"
model: opus
---

# INCORRECT - Ne jamais restreindre les tools
---
name: story-01-auth
tools: Read, Write, Edit  # NON! Pas de restrictions
---
```

## Naming Convention {{PROJECT_NAME}}

| Type | Pattern | Exemple |
|------|---------|---------|
| Epic Assistant | `epic-XX-chef` | `epic-01-chef.md` |
| Story Subagent | `story-XX-[focus]` | `story-01-auth.md` |
| Reviewer | `reviewer-[type]` | `reviewer-spec.md` |

## Structure XML Obligatoire

Suivre la structure XML Anthropic avec les sections {{PROJECT_NAME}} :

```xml
<role>
Tu es un developpeur senior specialise en [DOMAINE].
Tu implementes la Story XX de l'Epic YY.
</role>

<trak_context>
- Epic: [Nom de l'Epic]
- Story: [Titre de la Story]
- Domaine: [auth|ui|api|data|test]
</trak_context>

<tdd_cycle>
Pour CHAQUE critere d'acceptance:
1. RED: Ecrire test qui echoue
2. GREEN: Code minimal pour passer
3. REFACTOR: Nettoyer sans casser
</tdd_cycle>

<constraints>
- JAMAIS de code sans test
- JAMAIS modifier fichiers hors scope
- TOUJOURS zero warnings
- TOUJOURS commits atomiques
</constraints>

<output_format>
Rapport final:
- Ce qui a ete implemente
- Tests et resultats
- Fichiers modifies
- Decisions prises
</output_format>
```

## Focus par Domaine (Instructions, pas Permissions)

| Domaine | Focus dans les Instructions |
|---------|----------------------------|
| `auth` | Securite, validation, tokens, sessions, OWASP |
| `ui` | Widgets, layouts, responsive, animations, accessibility |
| `api` | Endpoints, serialization, error handling, retry |
| `data` | Models, repositories, Drift, migrations, integrity |
| `test` | Coverage, edge cases, mocks, integration |

## Model

**TOUJOURS `model: opus`** pour les subagents {{PROJECT_NAME}}. C'est une decision utilisateur.

## Integration avec Epic Assistant

L'Epic Assistant :
1. Lit la story et determine le focus
2. Cree le subagent avec les conventions {{PROJECT_NAME}}
3. Lance via Task tool
4. Review spec + quality
5. Valide ou relance

## Exemple Complet

```markdown
---
name: story-01-auth
description: "Implementer Story 01: Ecran de Login avec authentification email/password"
model: opus
---

<role>
Tu es un developpeur senior Flutter specialise en authentification.
Tu implementes la Story 01 de l'Epic 01 - Authentification.
</role>

<trak_context>
- Epic: EPIC-01-AUTH
- Story: Story 01 - Ecran de Login
- Focus: Authentification, validation, securite
</trak_context>

<story_requirements>
[Copier les criteres d'acceptance de la story ici]
</story_requirements>

<tdd_cycle>
Pour CHAQUE critere:
1. RED: Ecrire test qui echoue AVANT le code
2. GREEN: Code MINIMAL pour faire passer le test
3. REFACTOR: Nettoyer en gardant les tests verts
</tdd_cycle>

<constraints>
- JAMAIS de code sans test
- JAMAIS de credentials en dur
- JAMAIS modifier fichiers hors scope
- TOUJOURS valider les inputs
- TOUJOURS zero warnings
</constraints>

<output_format>
## Rapport Story 01

### Implemente
- [liste]

### Tests
- X tests, tous passent
- Couverture: XX%

### Fichiers modifies
- [liste avec chemins]

### Decisions
- [decisions prises pendant l'implementation]
</output_format>
```

# Architecture Decision Records (ADRs)

## Qu'est-ce qu'un ADR?

Un ADR (Architecture Decision Record) documente une décision architecturale importante, son contexte, les alternatives considérées, et les conséquences. L'objectif est de préserver le "pourquoi" des choix techniques pour les futurs mainteneurs.

---

## Liste des ADRs

| ID | Titre | Statut | Date |
|----|-------|--------|------|
| [ADR-001](./ADR-001-clean-architecture.md) | Adoption Clean Architecture | Accepté | 2025-01 |
| [ADR-002](./ADR-002-flutterflow-migration.md) | Migration FlutterFlow | Accepté | 2025-01 |
| [ADR-003](./ADR-003-supabase-backend.md) | Supabase comme Backend | Accepté | 2025-01 |
| [ADR-004](./ADR-004-design-system.md) | Design System Unifié | Accepté | 2025-01 |
| [ADR-005](./ADR-005-state-management.md) | Stratégie State Management | Accepté | 2025-01 |
| [ADR-006](./ADR-006-flutter-dotenv.md) | Gestion Secrets (flutter_dotenv) | Accepté | 2026-01 |

---

## Statuts

| Statut | Signification |
|--------|---------------|
| **Proposé** | En discussion, pas encore accepté |
| **Accepté** | Décision prise et en vigueur |
| **Déprécié** | N'est plus recommandé mais peut être en place |
| **Remplacé** | Remplacé par un autre ADR |

---

## Créer un nouvel ADR

1. Copier le [TEMPLATE.md](./TEMPLATE.md)
2. Nommer le fichier `ADR-XXX-titre-court.md`
3. Remplir toutes les sections
4. Soumettre en PR pour review
5. Mettre à jour cet INDEX après acceptation

---

## Références

- [ARCHITECTURE.md](../../ARCHITECTURE.md) - Architecture technique
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Guide de contribution

# ADR-003: Supabase comme Backend

**Date:** 2025-01
**Statut:** Accepté
**Décideurs:** Équipe fondatrice Lynewed

---

## Contexte

L'application Lynewed nécessite un backend robuste avec:
- **Authentification**: Email, Apple Sign-In
- **Base de données**: PostgreSQL avec données relationnelles complexes
- **Géolocalisation**: Requêtes PostGIS pour la carte
- **Temps réel**: Chat instantané, notifications live
- **Storage**: Images, documents, médias
- **Fonctions serverless**: Logique métier côté serveur

L'équipe est petite (2-3 développeurs) et a besoin d'une solution rapide à déployer sans gérer l'infrastructure.

---

## Décision

Nous avons décidé d'utiliser **Supabase** comme backend complet:

- **PostgreSQL** avec **PostGIS** pour les données et géolocalisation
- **Supabase Auth** pour l'authentification (+ Apple Sign-In)
- **Supabase Storage** pour les médias
- **Supabase Realtime** pour le chat et notifications
- **Edge Functions** (Deno/TypeScript) pour la logique serveur

**Configuration actuelle:**
- Projet: `LYNEWED-V1-APP` (ID: `hekyovgnovhfhmkpfrna`)
- Région: `eu-central-2` (Frankfurt)
- 248 utilisateurs actifs
- 16 Edge Functions déployées

---

## Conséquences

### Positives

- **Productivité**: Setup en quelques heures vs semaines
- **PostgreSQL**: Base de données robuste et éprouvée
- **PostGIS**: Requêtes géospatiales natives pour la carte
- **Realtime natif**: Chat instantané sans configuration
- **Edge Functions**: Logique serverless sans infrastructure
- **Dashboard**: Administration facile via interface web
- **RLS**: Row Level Security pour la sécurité fine

### Négatives

- **Vendor lock-in**: Dépendance à Supabase (mitigé: PostgreSQL standard)
- **Limites**: Certaines fonctionnalités avancées non disponibles
- **Coût**: Peut augmenter avec la croissance
- **Cold start**: Edge Functions ont un temps de démarrage

### Risques

- **Disponibilité**: Dépendance au service Supabase
  - Mitigation: Backups réguliers, PostgreSQL standard exportable
- **Performance**: Limites des Edge Functions
  - Mitigation: Optimisation des requêtes, caching

---

## Alternatives Considérées

### Alternative 1: Firebase

- **Description:** Backend Google (Firestore, Auth, Functions)
- **Avantages:** Très populaire, bonne documentation
- **Inconvénients:** NoSQL (Firestore), pas de PostGIS natif, vendor lock-in fort
- **Raison du rejet:** Modèle de données relationnel mieux adapté, besoin de PostGIS

### Alternative 2: Backend Custom (Node.js + PostgreSQL)

- **Description:** API REST/GraphQL custom
- **Avantages:** Contrôle total, pas de vendor lock-in
- **Inconvénients:** Temps de développement, infrastructure à gérer
- **Raison du rejet:** Équipe trop petite, besoin de rapidité

### Alternative 3: AWS Amplify

- **Description:** Backend AWS (AppSync, Cognito, Lambda)
- **Avantages:** Scalabilité AWS, nombreux services
- **Inconvénients:** Complexité, coût, courbe d'apprentissage
- **Raison du rejet:** Trop complexe pour les besoins actuels

---

## Références

- [Supabase Documentation](https://supabase.com/docs)
- [PostGIS Functions](https://postgis.net/docs/reference.html)
- [docs/api/edge-functions/overview.md](../api/edge-functions/overview.md)

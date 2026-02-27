# LYNEWED

## Dossier Technique

**Application mobile de mise en relation Mariées & Professionnels du Mariage**

---

| | |
|---|---|
| **Version** | 1.0 |
| **Date** | Février 2026 |
| **Statut** | Confidentiel |
| **Fondateur** | Thierry Joubert |
| **Contact** | contact@lynewed.com |

---

*Ce document présente l'architecture technique, les fonctionnalités et la maturité de l'application Lynewed.*

---

## Table des matières

0. [Résumé Exécutif](#0--résumé-exécutif)
1. [Contexte et Positionnement](#1--contexte-et-positionnement)
2. [Périmètre Fonctionnel](#2--périmètre-fonctionnel)
3. [Architecture Technique](#3--architecture-technique)
4. [Intégrations et Écosystème](#4--intégrations-et-écosystème)
5. [Qualité et Fiabilité](#5--qualité-et-fiabilité)
6. [Scalabilité et Évolutions](#6--scalabilité-et-évolutions)
7. [Gestion et Processus](#7--gestion-et-processus)
8. [Données et Conformité RGPD](#8--données-et-conformité-rgpd)
9. [Modèle Économique Technique](#9--modèle-économique-technique)
10. [Annexes](#annexes)

---

## 0 — Résumé Exécutif

**Lynewed** est une application mobile disponible sur **iOS et Android**, en production avec **248 utilisateurs actifs** et **49 professionnels du mariage** référencés. L'application permet aux mariées de trouver, comparer et collaborer avec des prestataires du mariage via une plateforme unique intégrant carte interactive, messagerie, appels vidéo, marketplace et outils de gestion.

### L'actif technologique en chiffres

| Indicateur | Valeur |
|------------|--------|
| Plateformes | iOS + Android (application native unique) |
| Utilisateurs actifs | 248 |
| Professionnels référencés | 49 |
| Modules fonctionnels | 19 modules indépendants |
| Tests automatisés | 5 193+ |
| Fonctions serveur | 33 Edge Functions |
| Tables base de données | 45+ (toutes sécurisées) |
| Services tiers intégrés | 8 (Stripe, Agora, Google Maps, FedEx, etc.) |
| Epics livrés (2026) | 14 sprints de développement complétés |

### Les trois forces techniques

1. **Architecture professionnelle** — L'application est construite sur une architecture modulaire (Clean Architecture) avec 19 modules fonctionnels indépendants. Chaque fonctionnalité peut évoluer sans impacter les autres.

2. **Intégrations complètes** — 8 services tiers sont intégrés : paiements sécurisés (Stripe Connect), appels vidéo (Agora), carte interactive (Google Maps), expédition (FedEx), notifications push (Firebase), emails transactionnels (Resend), géolocalisation (PostGIS) et authentification Apple.

3. **Qualité mesurée** — Plus de 5 193 tests automatisés garantissent la stabilité de chaque modification. Politique de zéro warning appliquée. Tests de conformité sécurité OWASP intégrés.

---

## 1 — Contexte et Positionnement

### Le besoin digital du marché du mariage

Le marché du mariage en France représente un écosystème de milliers de prestataires spécialisés — photographes, vidéastes, wedding planners, maquilleurs, fleuristes, traiteurs, créateurs de robes, DJ, etc. — et de centaines de milliers de couples qui organisent leur mariage chaque année.

Aujourd'hui, la mise en relation entre mariées et professionnels repose encore largement sur le bouche-à-oreille, les salons du mariage et des plateformes web généralistes peu adaptées à l'expérience mobile. Il n'existe pas de plateforme intégrée qui combine la découverte de prestataires, la communication directe, les outils de gestion du mariage et la possibilité de transactions sécurisées.

### Deux profils utilisateurs complémentaires

**La mariée** a besoin de :
- Découvrir des professionnels de confiance, filtrés par spécialité, localisation et budget
- Communiquer directement avec les prestataires (chat et vidéo)
- Organiser son mariage (agenda, budget, liste d'invités, albums photo)
- Acheter des articles de seconde main (robes, accessoires) via une marketplace sécurisée

**Le professionnel du mariage** a besoin de :
- Gagner en visibilité auprès de clients qualifiés
- Gérer ses interactions clients depuis un hub centralisé
- Recevoir des avis vérifiés pour renforcer sa réputation
- Être payé directement via l'application

### Pourquoi une application mobile native

Le choix d'une application mobile (plutôt qu'un site web) est motivé par les besoins fonctionnels du produit :

| Besoin | Justification mobile |
|--------|---------------------|
| Notifications en temps réel | Push notifications pour les messages, rappels et appels vidéo |
| Géolocalisation | Utilisation du GPS pour la carte interactive des professionnels |
| Appareil photo | Prise de photos et vidéos intégrée pour les albums de mariage |
| Expérience immersive | Navigation fluide, appels vidéo, chat en temps réel |
| Utilisation en déplacement | Les mariées consultent et comparent les prestataires en mobilité |

L'application est développée avec **Flutter**, le framework de Google, qui permet de produire une application native unique fonctionnant à la fois sur iOS et Android, réduisant les coûts de développement tout en offrant des performances natives.

---

## 2 — Périmètre Fonctionnel

### 2.1 — Fonctionnalités pour la mariée

| Fonctionnalité | Description |
|----------------|-------------|
| **Carte interactive** | Carte des professionnels avec filtres par spécialité, budget et rayon géographique. Recherche par géolocalisation avec calcul de distance en temps réel. |
| **Profils professionnels** | Fiches détaillées : portfolio photo, avis vérifiés, tarifs, spécialités, localisation. |
| **Messagerie instantanée** | Chat en temps réel avec les prestataires : texte, images, audio, pièces jointes. Conversations privées et groupes. |
| **Appels vidéo** | Consultations vidéo en direct avec les professionnels, depuis l'application. |
| **Suite de gestion du mariage** | Agenda des rendez-vous, suivi du budget, liste d'invités avec gestion des groupes. |
| **Albums photo et vidéo** | Création d'albums partagés, upload de médias par les invités et les prestataires. |
| **Invitations numériques** | Génération de QR codes et liens d'invitation pour les invités du mariage, avec suivi des réponses. |
| **Marketplace** | Achat et vente d'articles de mariage de seconde main (robes, chaussures, accessoires, décoration). Paiement sécurisé, système d'offres, livraison FedEx intégrée. |
| **Magazines photo** | Commande de magazines photo physiques personnalisés à partir des photos du mariage. Quatre formules disponibles. |
| **Avis vérifiés** | Rédaction et consultation d'avis sur les professionnels après prestation. |
| **Inspirations** | Fil de contenu éditorial : articles, "Wedding of the Week", replays de masterclasses. |

### 2.2 — Fonctionnalités pour le professionnel

| Fonctionnalité | Description |
|----------------|-------------|
| **Hub de gestion** | Tableau de bord centralisé : mariages en cours, clients, statistiques d'activité. |
| **Visibilité carte** | Profil géolocalisé sur la carte interactive, visible par toutes les mariées de la zone. |
| **Portfolio** | Galerie de photos et vidéos de réalisations, diaporama interactif. |
| **Réception d'avis** | Collecte et affichage des retours clients vérifiés. |
| **Synchronisation CRM** | Liaison bidirectionnelle avec le CRM Lynewed (back-office d'administration). |
| **Onboarding Stripe** | Inscription vendeur simplifiée pour recevoir les paiements marketplace directement. |

### 2.3 — Fonctionnalités transverses

| Fonctionnalité | Description |
|----------------|-------------|
| **Authentification** | Inscription par email ou Apple Sign In. Mot de passe sécurisé, réinitialisation par email. |
| **Notifications push** | Alertes en temps réel : nouveaux messages, demandes de contact, appels entrants, rappels. |
| **Rôle invité (Guest)** | Accès limité pour les invités du mariage : albums, groupes de discussion, informations pratiques. |
| **Support intégré** | Système de tickets et signalement accessible depuis l'application. |
| **Contenus éditoriaux** | Articles d'inspiration, "Wedding of the Week", replays vidéo. |
| **Suppression de compte** | Conformité RGPD : suppression complète des données personnelles sur demande. |

---

## 3 — Architecture Technique

### 3.1 — Vue d'ensemble de la stack

```
┌─────────────────────────────────────────────────────────────┐
│                     UTILISATEUR (iOS / Android)              │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                  APPLICATION MOBILE                          │
│           Flutter 3.32 / Dart 3.8 — Code unique             │
│                                                              │
│   19 modules fonctionnels indépendants                      │
│   Architecture en 3 couches (Clean Architecture)            │
│   Design System unifié (19 composants réutilisables)        │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│               BACKEND SERVERLESS (Supabase)                  │
│                  Hébergé en Europe (Frankfurt)                │
│                                                              │
│   PostgreSQL + PostGIS    │   Authentification               │
│   Stockage fichiers       │   Temps réel (WebSocket)         │
│   33 fonctions serveur (Edge Functions)                      │
└────────────┬────────────────────────────┬───────────────────┘
             │                            │
┌────────────▼──────────┐   ┌────────────▼───────────────────┐
│   SERVICES INTÉGRÉS   │   │   SERVICES DE LIVRAISON        │
│                        │   │                                 │
│  Stripe (paiements)   │   │  FedEx (expédition marketplace) │
│  Agora (vidéo)        │   │  Resend (emails)                │
│  Google Maps (carte)  │   │                                 │
│  Firebase (push)      │   │                                 │
└────────────────────────┘   └─────────────────────────────────┘
```

### 3.2 — Architecture applicative : Clean Architecture

L'application est construite selon le principe de **Clean Architecture**, une méthodologie d'ingénierie logicielle qui sépare strictement les responsabilités du code en couches indépendantes. Ce choix a été fait délibérément après une phase initiale de prototypage rapide avec FlutterFlow (outil low-code), qui avait atteint ses limites en termes de maintenabilité et de testabilité.

**Le principe en termes simples :**

L'application est découpée en **19 modules fonctionnels indépendants** (authentification, messagerie, carte, marketplace, etc.). Chaque module possède **3 couches** qui ne se connaissent pas mutuellement :

| Couche | Rôle | Analogie |
|--------|------|----------|
| **Interface utilisateur** | Ce que l'utilisateur voit et touche | La vitrine du magasin |
| **Logique métier** | Les règles de fonctionnement (ex : "un avis ne peut être laissé qu'après prestation") | Le règlement intérieur |
| **Accès aux données** | La communication avec le serveur Supabase | L'entrepôt en coulisses |

**Pourquoi c'est un avantage concret :**

- **Indépendance** — Modifier la messagerie n'impacte pas la carte ni les paiements. Chaque module évolue à son propre rythme.
- **Testabilité** — Chaque couche est testable isolément, d'où les 5 193 tests automatisés.
- **Évolutivité** — Ajouter un nouveau module (ex : un système de réservation) ne nécessite pas de réécrire l'existant.
- **Recrutement** — Un développeur Flutter connaissant Clean Architecture est immédiatement opérationnel sur le projet.

**Investissement réalisé :** La migration depuis le code FlutterFlow vers Clean Architecture a représenté un epic complet de 42 stories. C'est un investissement structurel qui rend aujourd'hui le développement de nouvelles fonctionnalités significativement plus rapide et plus fiable.

### 3.3 — Backend serverless : Supabase

Le backend repose entièrement sur **Supabase**, une plateforme open-source qui fournit tous les services nécessaires sans avoir à gérer de serveurs physiques :

| Composant | Technologie | Fonction |
|-----------|-------------|----------|
| **Base de données** | PostgreSQL 17 | Base relationnelle robuste, la plus utilisée au monde. Hébergement en Europe (Frankfurt, Allemagne). |
| **Extension géospatiale** | PostGIS | Requêtes géographiques pour la carte : "tous les photographes dans un rayon de 50 km". |
| **Authentification** | Supabase Auth | Gestion sécurisée des comptes utilisateurs, sessions et mots de passe. |
| **Stockage fichiers** | Supabase Storage | 9 espaces de stockage pour les photos, vidéos, documents de chat, portfolio professionnels. |
| **Temps réel** | Supabase Realtime | Connexion WebSocket pour la messagerie instantanée et les mises à jour en direct. |
| **Fonctions serveur** | Edge Functions (Deno) | 30 fonctions TypeScript exécutées côté serveur : paiements, notifications, synchronisation CRM, expédition. |
| **Sécurité données** | Row Level Security | Chaque utilisateur n'accède qu'à ses propres données, contrôlé au niveau de la base de données. |

**Pourquoi Supabase plutôt qu'une autre solution :**

Le choix de Supabase a été fait après évaluation de Firebase (Google), AWS Amplify (Amazon) et un backend custom Node.js. Supabase a été retenu pour :
- **PostgreSQL** — Base de données relationnelle (vs NoSQL pour Firebase), mieux adaptée aux données structurées de Lynewed
- **PostGIS** — Extension géospatiale native, essentielle pour la carte interactive
- **Open-source** — Pas de dépendance propriétaire, les données sont exportables à tout moment
- **Hébergement Europe** — Conformité RGPD native
- **Coût** — Modèle économique adapté aux startups (gratuit jusqu'à un certain volume, puis tarification progressive)

### 3.4 — Compatibilité des plateformes

| Plateforme | Version minimum | Couverture estimée |
|------------|----------------|-------------------|
| iOS | 15.0+ | ~98% des iPhone actifs |
| Android | 7.0+ (SDK 24) | ~95% des appareils Android actifs |

L'application est développée avec **Flutter 3.32** (framework Google), qui produit un code natif unique pour les deux plateformes. Cela signifie qu'une seule équipe de développement maintient les versions iOS et Android simultanément, divisant par deux les coûts de développement et de maintenance par rapport à deux applications natives séparées.

---

## 4 — Intégrations et Écosystème

### 4.1 — Vue d'ensemble des services intégrés

| Service | Fournisseur | Usage | Valeur apportée |
|---------|-------------|-------|-----------------|
| **Supabase** | Supabase (open-source) | Backend complet | Base de données, authentification, stockage, temps réel, fonctions serveur |
| **Stripe Connect** | Stripe (USA) | Paiements marketplace | Onboarding vendeurs, encaissement acheteurs, split de commission automatique |
| **Agora RTC** | Agora (Chine/USA) | Appels vidéo | Sessions vidéo temps réel entre mariées et professionnels |
| **Firebase FCM** | Google | Notifications push | Alertes iOS et Android, file d'attente fiable |
| **Google Maps** | Google | Carte interactive | Affichage géolocalisé des professionnels, filtres par zone |
| **Google Places** | Google | Recherche d'adresses | Autocomplétion intelligente des adresses |
| **FedEx API** | FedEx | Expédition marketplace | Calcul de frais, génération d'étiquettes, suivi de colis |
| **Resend** | Resend | Emails transactionnels | Invitations mariage, vérification de compte, réponses support |
| **Apple Sign In** | Apple | Authentification iOS | Connexion rapide sans mot de passe sur iPhone |

### 4.2 — Focus : le système de paiement (Stripe Connect)

L'intégration de **Stripe Connect** permet à Lynewed de fonctionner comme une marketplace avec des flux financiers automatisés :

**Le parcours d'un achat marketplace :**

```
1. ONBOARDING VENDEUR
   La vendeuse crée son compte Stripe depuis l'app
   → Vérification d'identité automatique par Stripe
   → Compte validé, prêt à recevoir des paiements

2. ACHAT PAR L'ACHETEUSE
   L'acheteuse paie depuis l'app (carte bancaire)
   → Le prix ne peut pas être manipulé côté client
     (enforcement serveur)

3. RÉPARTITION AUTOMATIQUE
   Stripe répartit automatiquement :
   → 90% vers la vendeuse
   → 10% de commission vers Lynewed

4. SÉCURISATION
   Chaque paiement est tracé et idempotent :
   un même paiement ne peut jamais être compté deux fois
```

**Trois flux de paiement actifs :**

| Flux | Type | Commission Lynewed |
|------|------|-------------------|
| Marketplace (robes, chaussures, accessoires) | Paiement unique | 10% |
| Magazines photo personnalisés | Paiement unique | Prix fixe serveur |
| Abonnements professionnels (CRM) | Abonnement mensuel | 100% |

### 4.3 — Focus : la logistique marketplace (FedEx)

La marketplace intègre un flux logistique complet via l'API FedEx :

```
1. CHECKOUT
   → L'API FedEx calcule les frais de port en temps réel
     (basés sur le poids, les dimensions et la destination)
   → L'acheteuse voit le prix total avant de payer

2. PAIEMENT VALIDÉ
   → Le serveur génère automatiquement une étiquette FedEx
   → Un numéro de suivi est créé

3. EXPÉDITION
   → La vendeuse télécharge l'étiquette depuis l'app
   → Elle dépose le colis en point relais FedEx

4. SUIVI
   → Le tracking est mis à jour automatiquement dans l'app
   → L'acheteuse suit son colis en temps réel
```

Le calcul des frais et la génération des étiquettes sont entièrement gérés côté serveur (Edge Functions), garantissant l'intégrité des prix et la fiabilité du processus.

---

## 5 — Qualité et Fiabilité

### 5.1 — Suite de tests automatisés

L'application est couverte par une suite de **5 193 tests automatisés** répartis sur **320 fichiers de test**. Chaque modification du code est automatiquement vérifiée par cette suite, garantissant qu'aucune régression n'est introduite.

| Type de test | Couverture | Objectif |
|-------------|------------|----------|
| **Tests unitaires** | Logique métier des 19 modules | Vérifier que chaque règle de fonctionnement est correcte |
| **Tests d'interface** | Écrans et composants visuels | Vérifier que l'affichage est conforme aux spécifications |
| **Tests de gestion d'état** | Toutes les machines d'état (Cubits) | Vérifier les transitions et les comportements réactifs |
| **Tests de sécurité** | Conformité OWASP Mobile Top 10 | Vérifier l'absence des 10 vulnérabilités mobiles les plus courantes |

**Politique de qualité stricte :**
- **Zéro warning** — Le build est bloqué si le moindre avertissement est détecté dans le code
- **Développement piloté par les tests (TDD)** — Les tests sont écrits avant le code de production
- **Review adversariale** — Chaque implémentation est challengée systématiquement avant validation

### 5.2 — Sécurité

La sécurité est traitée à chaque niveau de l'application :

| Niveau | Mesure | Description |
|--------|--------|-------------|
| **Base de données** | Row Level Security (RLS) | Les 45 tables sont protégées : un utilisateur ne peut jamais lire ni modifier les données d'un autre utilisateur, cette protection est appliquée directement au niveau du serveur de base de données. |
| **Entrées utilisateur** | Validation des saisies | Détection automatique de tentatives d'injection de code malveillant (XSS, SQL injection), de caractères invisibles malveillants et de dépassements de limites. |
| **Clés d'API** | Gestion sécurisée des secrets | Aucune clé API n'est présente dans le code source. Les secrets sont chargés à l'exécution via un fichier sécurisé non versionné. |
| **Logs** | Logger sécurisé | Les données personnelles (emails, téléphones, tokens) ne figurent jamais dans les logs de l'application. 25+ types de données sensibles sont automatiquement masqués. |
| **Communications** | HTTPS obligatoire | Toutes les communications entre l'application et les serveurs sont chiffrées. |
| **Paiements** | Enforcement serveur | Les prix sont calculés et validés côté serveur. Le client ne peut pas manipuler les montants. |
| **Conformité** | Tests OWASP Mobile Top 10 | Les 10 vulnérabilités mobiles les plus courantes (définies par l'OWASP, référence mondiale en cybersécurité) sont testées automatiquement. |

### 5.3 — Fiabilité et monitoring

| Mécanisme | Description |
|-----------|-------------|
| **Outbox pattern (notifications)** | Les notifications push sont stockées dans une file d'attente persistante avant envoi. Même si le service de notification est temporairement indisponible, aucune notification n'est perdue. Traitement automatique toutes les 30 secondes. |
| **Webhooks idempotents** | Les événements de paiement Stripe sont traités de manière idempotente : un même événement ne peut pas être traité deux fois, évitant tout risque de double-facturation. |
| **Logs serveur en temps réel** | Les logs de la base de données, de l'authentification et des fonctions serveur sont accessibles en temps réel via le tableau de bord Supabase. |
| **Audit de performance** | L'outil Supabase Advisors fournit des recommandations automatiques sur les index de base de données et les optimisations de requêtes. |

---

## 6 — Scalabilité et Évolutions

### 6.1 — Capacité de montée en charge

L'architecture de Lynewed est conçue pour grandir sans refonte :

| Composant | Mécanisme de scaling | Capacité |
|-----------|---------------------|----------|
| **Application mobile** | Code natif Flutter optimisé | Pas de limite côté client |
| **Base de données** | PostgreSQL sur Supabase (plan scalable) | Conçu pour des millions de lignes |
| **Fonctions serveur** | Edge Functions (serverless) | Scalent automatiquement selon la demande |
| **Stockage** | Supabase Storage (object storage) | Extensible à volonté |
| **Géolocalisation** | PostGIS | Optimisé pour des millions de points géographiques |
| **Temps réel** | WebSocket Supabase | Gère nativement les connexions concurrentes |

**Architecture modulaire = scaling ciblé.** Si la messagerie nécessite plus de ressources que la carte, seul le module de messagerie est optimisé, sans toucher au reste de l'application.

### 6.2 — Points de vigilance et plan de mitigation

| Point | Situation actuelle | Plan si croissance x10 | Plan si croissance x100 |
|-------|-------------------|----------------------|------------------------|
| Hébergement Supabase | Plan adapté à 248 utilisateurs | Migration vers plan Pro | Migration vers plan Enterprise ou self-hosting |
| Temps de réponse Edge Functions | Acceptable (< 1s) | Cache sur fonctions critiques | CDN + fonctions dédiées |
| Pipeline de déploiement | Manuel (développeur) | CI/CD automatisé (GitHub Actions) | Pipeline multi-environnement |
| Monitoring | Logs basiques Supabase | Intégration Sentry (erreurs) | Suite complète (Datadog ou équivalent) |
| Support multi-langue | Français/Anglais | Internationalisation (i18n) | Localisation complète |

### 6.3 — Roadmap technique identifiée

| Évolution | Description | Impact business |
|-----------|-------------|-----------------|
| **Rappels de rendez-vous** | Notifications automatiques avant chaque RDV avec un prestataire | Réduction des no-show, meilleure satisfaction |
| **CI/CD automatisé** | Pipeline de déploiement automatisé avec tests et vérifications | Releases plus rapides et plus fiables |
| **Internationalisation** | Support multilingue pour l'expansion hors France | Ouverture marchés européens et internationaux |
| **API publique** | Interface de programmation pour les partenaires | Écosystème de partenaires techniques |
| **Version web** | Application web (Flutter Web déjà intégré dans le projet) | Acquisition utilisateurs sans installation |

---

## 7 — Gestion et Processus

### 7.1 — Méthodologie de développement

Le développement suit une méthodologie rigoureuse inspirée des pratiques de l'industrie logicielle professionnelle :

| Pratique | Description |
|----------|-------------|
| **TDD (Test-Driven Development)** | Les tests sont écrits avant le code de production. Cela garantit que chaque fonctionnalité est spécifiée avant d'être implémentée. |
| **Review adversariale** | Après chaque implémentation, le code est systématiquement challengé selon une checklist de sécurité, de logique et de cohérence. |
| **Architecture Decision Records** | Chaque choix technique majeur est documenté avec son contexte, les alternatives considérées et les raisons du choix final. 6 ADR documentés. |
| **Workflow structuré en 8 étapes** | Chaque fonctionnalité suit un workflow : Analyse → Plan → Exécution TDD → Validation → Review → Correction → Test → Livraison. |
| **Documentation continue** | Spécifications produit, décisions d'architecture et suivi de projet sont documentés en continu. |

### 7.2 — Historique des livraisons (2026)

14 sprints de développement (Epics) ont été complétés depuis janvier 2026 :

| Sprint | Fonctionnalité livrée | Stories | Date |
|--------|----------------------|---------|------|
| EPIC-01 | Migration Clean Architecture (refonte complète) | 42 | Janvier 2026 |
| EPIC-02 | Suite de tests additionnels | — | Janvier 2026 |
| EPIC-04 | Documentation technique complète | — | Janvier 2026 |
| EPIC-05 | Audit et nettoyage sécurité | — | Janvier 2026 |
| EPIC-06 | Prérequis techniques (migration base de données) | 6 | Janvier 2026 |
| EPIC-07 | Système d'avis clients vérifiés | 9 | Janvier 2026 |
| EPIC-09 | Invitations numériques (QR codes, deep links) | 12 | Février 2026 |
| EPIC-10 | Photos et vidéos (albums, upload, galerie) | 8 | Février 2026 |
| EPIC-11 | Intégration Stripe complète (Connect, webhooks) | 12 | Janvier 2026 |
| EPIC-12 | Magazines photo personnalisés | 12 | Février 2026 |
| EPIC-13 | Filtres carte avancés (budget, rayon, spécialités) | 9 | Janvier 2026 |
| EPIC-14 | Marketplace complète (listings, offres, FedEx, Stripe) | 26 | Février 2026 |

**Total : 104 stories de développement complétées, dont 42 pour la migration architecturale.**

### 7.3 — Outils et infrastructure de développement

| Outil | Usage |
|-------|-------|
| **Git** | Versionnement du code source avec historique complet |
| **Supabase Dashboard** | Administration de la base de données et des fonctions serveur |
| **Stripe Dashboard** | Gestion des paiements, produits et webhooks |
| **Flutter DevTools** | Débogage et optimisation des performances |
| **Claude Code** | Assistant IA pour le développement accéléré |

---

## 8 — Données et Conformité RGPD

### 8.1 — Hébergement et localisation des données

| Aspect | Détail |
|--------|--------|
| **Hébergement principal** | Supabase — région **eu-central-2** (Frankfurt, Allemagne) |
| **Législation applicable** | Droit européen — RGPD natif |
| **Stockage des fichiers** | Même infrastructure européenne Supabase |
| **Services tiers** | Stripe (conforme RGPD), Firebase (hébergement UE configurable) |

### 8.2 — Mesures de protection des données personnelles

| Mesure | Description |
|--------|-------------|
| **Contrôle d'accès** | Row Level Security sur les 45 tables : chaque utilisateur n'accède qu'à ses propres données. Les politiques de sécurité sont appliquées au niveau du moteur de base de données, indépendamment de l'application. |
| **Suppression de compte** | Fonction serveur dédiée (`account_delete`) permettant la suppression complète et irréversible de toutes les données personnelles d'un utilisateur sur simple demande. |
| **Consentement CGV** | Acceptation des conditions générales tracée en base de données avec horodatage et version du document accepté. |
| **Mots de passe** | Jamais stockés en clair. Gestion par Supabase Auth avec hachage bcrypt. |
| **Logs applicatifs** | Logger sécurisé masquant automatiquement 25+ types de données personnelles (emails, téléphones, tokens, coordonnées GPS, informations financières). Zéro donnée personnelle dans les logs de production. |
| **Pas de tracking publicitaire** | Aucun SDK publicitaire ni cookie de tracking tiers intégré dans l'application. |
| **Apple Sign In** | Conformité avec les politiques App Store (obligation pour les apps proposant une connexion sociale). |
| **Droit à l'image** | Système de consentement intégré pour les photos partagées dans les albums de mariage. |

---

## 9 — Modèle Économique Technique

### 9.1 — Sources de revenus activées par la technologie

| Flux de revenus | Mécanisme technique | Statut | Modèle |
|-----------------|---------------------|--------|--------|
| **Commission marketplace** | Stripe Connect — split automatique à chaque vente | Actif | 10% par transaction |
| **Magazines photo** | Stripe Checkout — 4 formules à prix fixe (29€ à 89€) | Actif | Prix fixe par commande |
| **Abonnements professionnels** | Stripe Subscriptions via CRM | Actif | Abonnement mensuel |
| **Frais de port** | FedEx API — calcul et marge intégrés | Actif | Marge sur livraison |

Chaque flux de revenu est entièrement automatisé : du paiement client à la répartition des fonds, aucune intervention manuelle n'est nécessaire.

### 9.2 — Structure de coûts infrastructure

| Poste | Modèle | Caractéristique |
|-------|--------|-----------------|
| **Supabase** | Pay-as-you-grow | Coût proportionnel au nombre d'utilisateurs et au volume de données |
| **Stripe** | Commission par transaction | 1,5% + 0,25€ par paiement (Europe) |
| **Agora** | Minutes de vidéo | Premiers 10 000 minutes/mois gratuites |
| **Firebase** | Volume de notifications | Gratuit jusqu'à un volume significatif |
| **FedEx** | Par étiquette générée | Coût unitaire par envoi |
| **Resend** | Volume d'emails | 3 000 emails/mois gratuits |

**Point clé : l'infrastructure est entièrement serverless** — pas de serveurs à maintenir, pas d'équipe DevOps dédiée nécessaire. Le coût marginal par utilisateur supplémentaire est faible, et l'infrastructure scale automatiquement avec l'usage. Ce modèle est idéal pour une startup en phase de croissance.

---

## Annexes

### Annexe A — Glossaire technique

| Terme | Définition |
|-------|------------|
| **Flutter** | Framework de développement mobile créé par Google, permettant de produire une application native unique pour iOS et Android à partir d'un seul code source. |
| **Dart** | Langage de programmation utilisé par Flutter, développé par Google. |
| **Clean Architecture** | Méthodologie d'organisation du code en couches indépendantes (interface, logique métier, données), facilitant les tests et l'évolution. |
| **Supabase** | Plateforme open-source de backend-as-a-service, alternative à Firebase, basée sur PostgreSQL. |
| **PostgreSQL** | Système de gestion de base de données relationnelle open-source, le plus avancé au monde. |
| **PostGIS** | Extension de PostgreSQL pour le traitement de données géographiques (calcul de distances, zones, etc.). |
| **Edge Functions** | Fonctions serveur exécutées à la périphérie du réseau, proches de l'utilisateur, pour des temps de réponse optimaux. |
| **Row Level Security (RLS)** | Mécanisme de PostgreSQL qui restreint l'accès aux lignes d'une table selon l'identité de l'utilisateur connecté. |
| **Stripe Connect** | Service Stripe permettant à une marketplace de gérer des paiements entre acheteurs et vendeurs, avec split de commission automatique. |
| **Agora RTC** | SDK de communication en temps réel (Real-Time Communication) pour intégrer des appels vidéo et audio dans une application. |
| **Firebase Cloud Messaging (FCM)** | Service Google pour l'envoi de notifications push sur iOS et Android. |
| **Webhook** | Mécanisme de notification automatique : un service externe (Stripe, FedEx) envoie une notification au serveur Lynewed quand un événement se produit (paiement confirmé, colis expédié). |
| **API** | Interface de programmation : un contrat technique permettant à deux systèmes de communiquer entre eux de manière standardisée. |
| **Serverless** | Architecture où le développeur n'a pas à gérer de serveurs. L'infrastructure s'adapte automatiquement à la charge. |
| **TDD** | Test-Driven Development : méthodologie où les tests sont écrits avant le code, garantissant que chaque fonctionnalité est spécifiée et vérifiable. |
| **OWASP** | Open Web Application Security Project : organisation mondiale de référence en matière de sécurité des applications. Le "Top 10 Mobile" liste les 10 vulnérabilités les plus courantes des applications mobiles. |

### Annexe B — Inventaire des fonctions serveur (Edge Functions)

#### Notifications et communications

| Fonction | Description |
|----------|-------------|
| `notifications_outbox_drain` | Envoi des notifications push (cron toutes les 30 secondes) |
| `send-broadcast-notification` | Notifications broadcast depuis le panneau d'administration |
| `send-wedding-invitation` | Envoi d'invitations par email avec QR code |
| `send-verification-email` | Emails de vérification pour les professionnels |
| `send-ticket-reply` | Réponses aux tickets de support |

#### Paiements et commerce

| Fonction | Description |
|----------|-------------|
| `stripe-webhook` | Traitement des événements Stripe (25+ types d'événements) |
| `stripe-connect-webhook` | Événements des comptes vendeurs Stripe Connect |
| `stripe-connect-return` | Retour de l'onboarding vendeur Stripe |
| `create-stripe-connect-account` | Création de comptes vendeurs Stripe Connect |
| `sync-stripe-account` | Synchronisation statut des comptes Stripe |
| `marketplace-create-payment` | Création de sessions de paiement marketplace |
| `marketplace-payment-webhook` | Traitement des paiements marketplace validés |
| `marketplace-refund` | Traitement des remboursements marketplace |
| `create-magazine-checkout` | Sessions de paiement pour les magazines photo |
| `magazine-order-webhook` | Traitement des commandes magazines validées |

#### Expédition (FedEx)

| Fonction | Description |
|----------|-------------|
| `fedex-calculate-rate` | Calcul des frais de port en temps réel |
| `fedex-create-shipment` | Génération d'étiquettes et numéros de suivi |
| `fedex-track-shipment` | Suivi de colis |
| `fedex-cancel-shipment` | Annulation d'expéditions |

#### Gestion utilisateurs

| Fonction | Description |
|----------|-------------|
| `create-or-sync-user` | Synchronisation de profils professionnels depuis le CRM |
| `delete-user` | Suppression de données utilisateur |
| `account_delete` | Suppression complète de compte (RGPD) |
| `upload-professional-images` | Upload d'images pour les profils professionnels |

#### Synchronisation CRM

| Fonction | Description |
|----------|-------------|
| `sync-professional-profile` | Synchronisation individuelle d'un profil professionnel |
| `sync-professional-to-app` | Synchronisation en masse des professionnels |
| `sync-wed-articles-to-app` | Synchronisation des articles de mariage |
| `sync-wedding-article` | Synchronisation individuelle d'un article |

#### Maintenance et crons

| Fonction | Description |
|----------|-------------|
| `video_sessions_cleanup` | Nettoyage des sessions vidéo abandonnées |
| `alerts_housekeeping` | Expiration des alertes professionnelles inactives |
| `recent_locations_cleanup` | Purge de l'historique de localisation |
| `expire-marketplace-offers` | Expiration des offres marketplace après 48h |
| `expire-unshipped-transactions` | Expiration des transactions non expédiées |

### Annexe C — Dépendances techniques principales

#### Application mobile (Flutter/Dart)

| Catégorie | Packages | Versions |
|-----------|----------|----------|
| **Framework** | Flutter SDK, Dart SDK | 3.32.4, >=3.0.0 |
| **Backend** | supabase_flutter, postgrest, realtime_client, storage_client, functions_client | 2.12.0, 2.6.0, 2.7.0, 2.4.1, 2.5.0 |
| **State management** | flutter_bloc, provider, rxdart | 8.1.6, 6.1.5, 0.27.7 |
| **Injection de dépendances** | get_it | 8.0.3 |
| **Navigation** | go_router, app_links | 12.1.3, 6.3.2 |
| **Carte** | google_maps_flutter, flutter_google_places_sdk, geolocator | 2.12.2, 0.4.2, 14.0.1 |
| **Vidéo** | agora_rtc_engine | 6.3.2 |
| **Paiements** | (via Edge Functions Stripe) | Stripe npm 17.7.0 |
| **Notifications** | firebase_core, firebase_messaging | 4.4.0, 16.1.1 |
| **Médias** | cached_network_image, image_picker, video_player, flutter_image_compress, just_audio, record | 3.4.1, 1.2.1, 2.10.1, 2.0.4, 0.10.4, 6.0.0 |
| **Sécurité** | flutter_secure_storage, crypto | 10.0.0, 3.0.7 |
| **UI** | flutter_animate, google_fonts, auto_size_text, qr_flutter, mobile_scanner | 4.5.2, 6.1.0, 3.0.0, 4.1.0, 7.1.4 |
| **Auth** | sign_in_with_apple | 7.0.1 |
| **Tests** | flutter_test, bloc_test, mocktail, flutter_lints | SDK, 9.1.7, 1.0.4, 5.0.0 |

#### Fonctions serveur (Edge Functions)

| Technologie | Version |
|-------------|---------|
| Deno Runtime | v2 |
| Supabase JS | @supabase/supabase-js@2 |
| Stripe | stripe@17.7.0 |

---

*Document confidentiel — LYNEWED © 2026 — Tous droits réservés.*

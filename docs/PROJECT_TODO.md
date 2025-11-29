# PROJECT TODO - Idées & Tâches à Venir

**Document créé:** 2025-11-26  
**Last Updated:** 2025-11-29 10:50  
**Objectif:** Gestion des tâches à faire et idées d'améliorations techniques  
**Version:** v2.0 (Structure spécialisée)

---

## 🎯 Tâches Prochaines (non-précises, temps-flexible)

### ✅ PHASES 1-4 MAP COMPLÉTÉES (2025-11-28)
- ✅ Foundation (Design System, Clean Architecture)
- ✅ Filtres & Markers (FilterSheet, cercles avatar)
- ✅ Sheets & Actions (MapActionsService)
- ✅ Enums Map (simplifié 4 valeurs)
- ✅ Bugs corrigés (alertes expirées, navigation auteur)

### 🚨 Prochaines Phases Map (16-24h restantes)

**Phase 7 - Android Tests (4-6h):**
- [ ] Test permissions Android (location, notifications)
- [ ] Performance map sur différents appareils Android
- [ ] Background behavior (WidgetsBindingObserver lifecycle)
- [ ] Test rendering OpenGL vs Skia
- [ ] Validation responsive sur tailles écran variées

**Phase 8 - Documentation Finale (6-8h):**
- [ ] Documentation technique complète module map
- [ ] Guide de déploiement et monitoring
- [ ] Séparation marché indien (si nécessaire)
- [ ] Nettoyage code final et archives

**Phase 5 - Wedding System:**
- ✅ **Phase 5 base**: Tables, RPCs, WeddingCreateSheet **TERMINÉ**
- ✅ **Phase 5.1**: Amélioration Wedding UI (4-6h) **TERMINÉ**
  - ✅ Intégrer `AddressSearchWidget` dans venue field
  - ✅ Validation: event_date futur, venue_coords requis, budget_min < max
  - ✅ Erreurs inline claires
- ✅ **Phase 5.2**: Design System Cohérence (2-3h) **TERMINÉ**
  - ✅ Chips professions en noir (LynewedComponentStyles.chipTheme)
  - ✅ Tous sheets → LynewedTheme (supprimer FlutterFlowTheme)

**Phases 6-8:**
- ✅ **Phase 6**: Système Alertes (6-8h) **TERMINÉ** (2025-11-29)
  - ✅ Backend: enum `alert_type` (4 valeurs), RPCs create/update/delete/get_my_alerts
  - ✅ Frontend: AlertCreateSheet avec Design System, icônes par type
  - ✅ Dashboard: Real-time refresh via callbacks + lifecycle observers
  - ✅ Intégration MapPage: FAB pour pros ouvre AlertCreateSheet
- 🔴 **Phase 7**: Android Tests (4-6h)
- 🟡 **Phase 8**: Documentation Finale (6-8h)

**Ordre:**
```
Phase 6 (Alertes) ✅ → Phase 7 (Android) → Phase 8 (Docs)
```

### 🚨 CONTACT SYSTEM - À REVOIR COMPLÈTEMENT (Partie B)
**Contexte:** Le bouton "Contact" dans les sheets ne fonctionne pas correctement. La logique actuelle:
- Ne crée pas de chat_room automatiquement
- Envoie vers la messagerie sans contexte
- Pas de gestion du flow connection_request

**Tâches à faire:**
- [ ] Revoir la logique complète de contact Pro→Bride et Bride→Pro
- [ ] Implémenter création automatique de chat_room si inexistante
- [ ] Intégrer le système de connection_request (pending/accepted/declined)
- [ ] Gérer les différents types de contact: wishlist, weddingPin, map, alert, proToPro
- [ ] Ajouter feedback utilisateur approprié (snackbar, loading states)
- [ ] Tester tous les scénarios de contact avec les test users

### 📝 BUGS CORRIGÉS - Partie A (2025-11-28/29)

#### Session Matin (2025-11-28)
- ✅ Navigation View Profile: PublicProProfileViewWidget → ProDetailsWidget
- ✅ Erreur "Error loading profile": RPC fallback query robuste
- ✅ Icône favori visible côté Pro: paramètre showFavoriteButton
- ✅ Wedding Sheet: Suppression chevron profil bride
- ✅ Pro Sheet: Toggle Favori optimiste et réactif

#### Session Après-midi (Bugs Alertes) (2025-11-28)
- ✅ **Alertes expirées visibles sur map**: `search_map_bundle` + filtre `expires_at > now()`
- ✅ **Tap profil auteur silencieux**: Context invalidation après `Navigator.pop()` async
  - **Cause racine**: `_navigateToProProfileById` async appelé après pop → context invalide
  - **Solution**: Utiliser `actions.getProItemDetailsAction()` (même pattern que dashboard) + `this.context`
  - **Fichiers**: `map_page.dart`, `map_actions_service.dart`, `alert_details_sheet.dart`

#### Session Dashboard Refresh (2025-11-29)
- ✅ **Dashboard alerts pas rafraîchies**: Implémentation callbacks + lifecycle observers
  - **Solution**: `alertsFuture` dans model + `onAlertDeleted` callback + `WidgetsBindingObserver`
  - **Fichiers**: `dashboard_pro_model.dart`, `dashboard_pro_widget.dart`, `item_all_alert_widget.dart`

#### À revoir Partie B
- ⚠️ Contact non fonctionnel → Logique complète à implémenter

### 🚀 PERFORMANCE MAP - À INVESTIGUER
- [ ] Chargement lent des points et avatars manquants
- [ ] Optimiser RPC `get_map_bundle` (indexing?)
- [ ] Vérifier caching images (CachedNetworkImage configuration)
- [ ] Analyser latence Supabase (Cold starts?)

---

## 💡 Idées & Réflexions

### Architecture Future
- "Explorer la possibilité de migrer vers Riverpod pour le state management" - BLoC est bien mais verbeux
- "Penser à créer un système de plugins pour les features" - Architecture modulaire encore plus flexible
- "Évaluer l'idée de séparer le code métier du code UI complètement" - Pure Clean Architecture
- "Considérer l'ajout d'une couche de cache intelligente" - Pour les données fréquemment accédées

### Performance & Optimisation
- "Réfléchir à implémenter du lazy loading pour les images des profils" - Améliorerait la vitesse de chargement
- "Penser à optimiser les requêtes Supabase avec du batch processing" - Réduire le nombre d'appels
- "Explorer l'idée de précharger les données critiques en arrière-plan" - Meilleure UX
- "Considérer l'implémentation de WebSockets pour le temps réel" - Au lieu de polling

### UX & Design
- "Réfléchir à un système de thèmes (clair/sombre)" - Le design system actuel pourrait l'étendre
- "Penser à des micro-interactions subtiles" - Améliorerait le sentiment de qualité
- "Explorer l'idée d'animations de transition entre pages" - Plus moderne
- "Considérer l'ajout de feedback haptique pour les actions importantes"

---

## 🔧 Maintenance & Améliorations

### Tâches Techniques Récurrentes
- "Penser à mettre à jour les dépendances Flutter régulièrement" - Sécurité et performances
- "Faudrait prévoir des audits de code mensuels" - Maintenir la qualité
- "Réfléchir à mettre en place des tests de régression automatiques" - CI/CD pipeline
- "Penser à nettoyer le code mort chaque trimestre" - Éviter l'accumulation

### Monitoring & Observabilité
- "Évaluer l'idée d'ajouter Sentry pour le crash reporting" - Détection rapide des problèmes
- "Penser à implémenter des analytics utilisateurs" - Comprendre l'usage réel
- "Considérer l'ajout de monitoring de performance" - Temps de chargement, latence
- "Réfléchir à des alertes automatiques pour les erreurs critiques"

### Sécurité
- "Penser à faire des audits de sécurité réguliers" - Nouvelles vulnérabilités possibles
- "Évaluer l'idée d'implémenter le rate limiting côté API" - Protection contre abus
- "Considérer l'ajout de logs d'audit pour les actions sensibles" - Traçabilité
- "Réfléchir à la rotation des secrets API" - Bonne pratique sécurité

---

## 📚 Documentation & Processus

### Guides à Créer
- "Penser à créer un guide de contribution pour les futurs développeurs" - Standardisation
- "Faudrait documenter les patterns de test adoptés" - Pour maintenir la couverture
- "Réfléchir à un guide de dépannage commun" - Problèmes fréquents
- "Penser à créer des templates pour les nouveaux modules" - Accélérer le développement

### Processus à Améliorer
- "Évaluer l'idée d'implémenter des pull requests templates" - Standardiser les reviews
- "Penser à automatiser plus de tâches dans le CI/CD" - Réduire le travail manuel
- "Considérer l'ajout de checks de qualité automatiques" - Linting, test coverage, etc.
- "Réfléchir à un processus de release plus formel" - Versioning, changelog, etc.

### Standards à Définir
- "Penser à standardiser les messages d'erreur" - Cohérence UX
- "Faudrait définir des standards de nommage" - Pour tout le projet
- "Réfléchir à des standards de performance" - Temps de réponse max, etc.
- "Penser à des standards d'accessibilité" - Inclusivité

---

## 🚀 Vision Long Terme

### v2.0 - Prochaines Mois
- "Explorer l'idée d'une refonte complète du système de notifications" - Architecture actuelle problématique
- "Penser à implémenter un vrai système de cache distribué" - Redis ou similaire
- "Évaluer la possibilité de migrer vers Supabase Realtime" - Pour le temps réel
- "Considérer l'ajout de support offline" - Cache local + sync

### v3.0 - Futur
- "Réfléchir à une architecture microservices" - Si l'application grossit beaucoup
- "Penser à un système de plugins pour les features tierces" - Extensibilité
- "Explorer l'idée d'une version web" - Flutter Web adaptation
- "Considérer l'internationalisation complète" - i18n + l10n

### Nouveaux Modules Potentiels
- "Module de gestion de projets" - Pour les professionnels
- "Système de réservation en ligne" - Intégration calendriers
- "Marketplace de services" - Extension du modèle actuel
- "Module d'analytics pour les pros" - Statistiques détaillées

### Évolutions Architecture
- "Penser à une séparation complète frontend/backend" - Si besoin de scalabilité
- "Évaluer l'idée d'un design system multi-plateforme" - Web + mobile
- "Considérer l'ajout d'une couche GraphQL" - Alternative à REST
- "Réfléchir à un système d'events pour la communication inter-modules"

---

## 🔄 Processus de Travail

### Quand Consulter ce Fichier
- **Brainstorming**: Pour explorer des idées sans contraintes
- **Planning**: Pour prioriser les améliorations futures
- **Réflexion**: Pour évaluer l'impact de décisions techniques

### Style de Travail
- **Flexibilité**: Les idées peuvent évoluer ou être abandonnées
- **Non-précision**: Pas de dates fermes, juste des directions
- **Exploration**: Tester des concepts sans engagement
- **Itération**: Les idées se précisent avec le temps

### Mise à Jour des Statuts
- **[ ]** - Idée à explorer
- **[🤔]** - En réflexion active
- **[📋]** - Planifié mais pas prioritaire
- **[⏳]** - En attente de bon moment
- **[✅]** - Idée réalisée (déplacé vers PROJECT.md)

---

**Note**: Ce fichier est un espace de réflexion technique. Les idées ici ne sont pas des engagements mais des pistes à explorer quand l'opportunité se présente. La flexibilité est la clé de l'innovation.

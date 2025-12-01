# PROJECT TODO - Idées & Tâches à Venir

**Document créé:** 2025-11-26  
**Last Updated:** 2025-12-01 12:00  
**Objectif:** Gestion des tâches à faire et idées d'améliorations techniques  
**Version:** v3.0 (Post-Map)

---

## ✅ MODULE MAP - TERMINÉ (2025-12-01)

Le module Map est 100% complet. Voir rapport final: `docs/archive/MAP_REFACTORING_COMPLETE_2025-12-01.md`

| Phase | Description | Status |
|-------|-------------|--------|
| 0 | Design System | ✅ |
| 1-4 | Foundation, Filtres, Sheets, Enums | ✅ |
| 5 | Wedding System | ✅ |
| 6 | Alert System | ✅ |
| 7.1 | Sécurité Supabase | ✅ |
| 7.2 | Marché Indien | ✅ |
| 7.3 | UI/UX Final | ✅ |
| 8 | Documentation & Cleanup | ✅ |

**Durée totale:** ~50 heures | **Tests:** 63/63 passants

---

## 🎯 PRIORITÉS PROCHAINES

**Ordre suggéré des prochains chantiers:**
1. **Refactorisation Auth Module** (Clean Architecture)
2. **Refactorisation Chat Module** (Clean Architecture)
3. **Feed Pro System** (nouvelle fonctionnalité)
4. **Système Ambassadeurs** (gamification)
5. **Performance Optimizations** (cache, images)
6. **Analytics & Monitoring** (tracking utilisateur)

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

### 🚀 PERFORMANCE - À INVESTIGUER
- [ ] Chargement lent des points et avatars
- [ ] Optimiser RPCs Supabase (indexing)
- [ ] Caching images (CachedNetworkImage)
- [ ] Latence cold starts

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

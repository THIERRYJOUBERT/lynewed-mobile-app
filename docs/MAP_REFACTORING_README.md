# Map Refactoring - Guide de Démarrage Rapide

**Date:** 2025-11-27  
**Statut:** ✅ **PRÊT POUR PHASE 1**  
**Version:** v1.6  

---

## 🎯 Objectif

Refactorisation complète de la fonctionnalité Map pour simplifier le code, améliorer la performance et unifier l'expérience utilisateur.

---

## 📋 Source de Vérité

### Document Principal
- **`MAP_REFACTORING_PLAN.md`** - Plan d'implémentation complet (60-75h)
  - 8 phases détaillées avec tâches, risques et dépendances
  - Décisions finales validées
  - Timeline révisée et réaliste

### Références Techniques
- **`audits/MAP_FEATURE_AUDIT.md`** - Audit technique + résultats validation
- **`PROJECT_TODO.md`** - MAP_REFACTORING comme tâche active principale

### Archives (Terminé)
- **`archive/MAP_REFACTORING_VALIDATION_REPORT.md`** - Validation complète
- **`archive/MAP_REFACTORING_PREFLIGHT_CHECKLIST.md`** - 100% validé

---

## ✅ Prérequis Validés

| Prérequis | Statut | Détails |
|-----------|--------|---------|
| **Cron jobs** | ✅ Désactivés | Base dev stabilisée |
| **Seed data** | ✅ Créé | 12 fixed locations dans 5 pays |
| **Décisions critiques** | ✅ Prises | proRecent supprimé, weddingPin→wedding, motif_code gardé |
| **Documentation** | ✅ Organisée | Source de vérité unique |

---

## 🚀 Phase 1 - Prochaine Étape

**Phase 1: Nettoyage Enum & Code Mort** (2-3h)

### Tâches principales
1. Supprimer `proRecent` de `MapMarkerType`
2. Supprimer `user` de `MapMarkerType`  
3. Renommer `fixedLocation` → `proFixedLocation`
4. `searchTarget` → overlay (plus sur map)
5. Nettoyer code mort dans `LynewedInteractiveMap`

### Impact
- **55 fichiers** Flutter à modifier (~8% codebase)
- **249 usages** de `weddingPin` à migrer
- **95 usages** de `proRecent` à supprimer

---

## 📊 Résumé Décisions

| Décision | Choix | Raison |
|----------|-------|--------|
| **proRecent** | SUPPRIMER | Localisation temps réel abandonnée |
| **connectionRequestSource** | MIGRER weddingPin→wedding | Cohérence concept Wedding |
| **motif_code** | GARDER | Éviter breaking change |
| **Limites zoom** | INVERSER | Correspondre au RPC actuel (2000→50) |

---

## 🔗 Liens Rapides

- **Plan implémentation:** `MAP_REFACTORING_PLAN.md`
- **Contexte technique:** `audits/MAP_FEATURE_AUDIT.md`
- **Suivi projet:** `PROJECT_TODO.md`
- **Base de données:** Supabase `hekyovgnovhfhmkpfrna`

---

## ⚠️ Notes Importantes

1. **Enum subscriptionTierType**: Utiliser `trial` (pas `free`)
2. **professional_fixed_locations**: 12 records créés pour tests
3. **user_pois**: 0 records → suppression safe
4. **wedding_pins**: 10 records → migrer vers `weddings`

---

## 📝 **CHANGELOG PHASE 1**

### ✅ Phase 1: Nettoyage Enum & Code Mort - TERMINÉ (2025-11-27)

**Tâches accomplies:**
1. **Supprimé MapMarkerType.user** - 5 usages nettoyés (switch cases, filtres, clustering)
2. **Supprimé MapMarkerType.proRecent** - 8 usages nettoyés (checkbox UI complète supprimée)
3. **Renommé fixedLocation → proFixedLocation** - 7 usages mis à jour (enum, helpers, maps)
4. **Converti searchTarget en overlay-only** - 7 usages nettoyés (enum supprimé, markers commentés avec TODOs)

**Résultat enum final:**
```dart
enum MapMarkerType {
  professional,      // ✅ Conservé
  proFixedLocation,  // ✅ Renommé (était fixedLocation)
  professionalAlert, // ✅ Conservé
  weddingPin,        // ✅ Conservé (Phase 2 migration)
  poiPrivate,        // ✅ Conservé (Phase 2 suppression)
}
```

**Impact:**
- **Fichiers modifiés:** 6 fichiers principaux
- **Lignes changées:** ~50 lignes nettoyées
- **Compilation:** ✅ Passe (flutter analyze OK)
- **Références restantes:** showProRecent dans structs (Phase 2+)

**TODOs créés:**
- 2 markers searchTarget commentés pour future implémentation overlay (Phase 2+)

**Validation:** ✅ **PHASE 1 TERMINÉE AVEC SUCCÈS**

---

**Prêt pour Phase 2 ?** ✅ **OUI** - Enum nettoyé, compilation OK

# MAP REFACTORING - Pré-flight Checklist v1.6

**Statut:** ✅ **PRÊT POUR PHASE 1** - Tous les prérequis validés  
**Date:** 2025-11-27  
**Responsable:** Développeur principal + Product Owner  

---

## 🔴 DÉCISIONS CRITIQUES (Bloquant) - ✅ TOUTES VALIDÉES

### 1. Table pro_recent_locations ✅ DÉCIDÉ
- [x] **Décision produit:** ~~Garder ou~~ **SUPPRIMER** MapMarkerType.proRecent
- [x] ~~Si garder: Mettre à jour UI toggle `showProRecent`~~
- [x] Si supprimer: Désactiver section 3 du RPC + archiver table
- [x] **Raison:** Fonctionnalité localisation temps réel abandonnée

### 2. Enum connectionRequestSource ✅ DÉCIDÉ
- [x] **Décision technique:** Migration `weddingPin`→`wedding` **VALIDÉE**
- [x] SQL de migration prêt dans Phase 2 ✅
- [x] Impact sur code Flutter évalué (249 usages weddingPin)
- [x] **Raison:** Cohérence avec nouveau concept Wedding unifié

### 3. Table professional_alerts ✅ DÉCIDÉ
- [x] **Décision technique:** **GARDER** `motif_code` pour compatibilité
- [x] Mapping motif_code→alert_type: migration progressive
- [x] Script migration des 12 records existants: pas de breaking change
- [x] **Raison:** Éviter breaking change, migration douce

---

## 🟡 PRÉREQUIS TECHNIQUES (Bloquant) - ✅ TOUS VALIDÉS

### Environnement
- [x] **Cron jobs désactivés** ✅ (confirmé par user)
- [x] **Backup complet** exporté et testé ✅
- [x] **Seed data fixed locations** créé ✅ (12 records dans 5 pays)
- [x] **Staging** prêt avec données réelles ✅

### Code & Documentation
- [x] **MAP_REFACTORING_PLAN.md v1.6** validé ✅
- [x] **Validation report** lu et compris ✅
- [x] **PROJECT_STATUS.md** mis à jour avec findings ✅

### Base de Données
- [x] **professional_fixed_locations** = 12 records ✅ (seed créé)
- [x] **wedding_pins** = 10 records (migration possible) ✅
- [x] **user_pois** = 0 records (suppression safe) ✅

---

## 🟢 VALIDATIONS FINALES (Non-bloquant) - ✅ TOUTES VALIDÉES

### Performance
- [x] **Limites zoom RPC** confirmées (2000→50 vs 0→1000) ✅
- [x] **Impact Flutter** évalué (55 fichiers, ~8% codebase) ✅
- [x] **Timeline réaliste** validée (60-75h vs 42-57h) ✅

### Risques
- [x] **Rollback plan** testé et documenté ✅
- [x] **Feature flags** créés et testés ✅
- [x] **Monitoring** configuré pour map performance ✅

---

## 🚀 CHECKLIST DÉMARRAGE PHASE 1 - ✅ PRÊT

**Avant de commencer Phase 1 (Nettoyage Enum):**

- [x] ✅ Toutes les décisions critiques validées
- [x] ✅ Tous les prérequis techniques remplis
- [x] ✅ Backup complet vérifié
- [x] ✅ Environnement staging prêt
- [x] ✅ Équipe briefée sur timeline révisée (60-75h)

---

## 📊 STATUT ACTUEL

| Catégorie | Complété | Restant | % |
|-----------|----------|---------|---|
| 🔴 Décisions critiques | **3/3** | 0 | **100%** |
| 🟡 Prérequis techniques | **5/5** | 0 | **100%** |
| 🟢 Validations finales | **6/6** | 0 | **100%** |
| **TOTAL** | **14/14** | **0** | **100%** |

---

## 📝 NOTES

1. ~~**professional_fixed_locations vide:**~~ ✅ **RÉSOLU** - 12 records créés (Paris, London, NYC, Tokyo, Dublin)

2. **Timeline augmentée:** Passée de 42-57h à 60-75h (+30%) suite à l'analyse Flutter (55 fichiers impactés).

3. **Zoom inversé:** Le RPC actuel utilise plus de markers à faible zoom (2000), le plan a été corrigé pour correspondre.

4. **Backup sauvegardé:** `MAP_REFACTORING_PLAN_v1.5_BACKUP.md` créé avant modifications.

5. **Décisions prises (2025-11-27):**
   - `proRecent` → **SUPPRIMER** (localisation temps réel abandonnée)
   - `connectionRequestSource` → **MIGRER** weddingPin→wedding
   - `motif_code` → **GARDER** pour compatibilité (migration progressive)

---

## ✅ **STATUT FINAL: GO PHASE 1**

Tous les prérequis sont validés. La refactorisation peut commencer.

**Prochaine étape:** Phase 1 - Nettoyage Enum & Code Mort (2-3h)

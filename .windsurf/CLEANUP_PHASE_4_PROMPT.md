# 🧹 CLEANUP PHASE 4 - MASTER PROMPT

**Objectif:** Continuer le nettoyage du code mort avec extrême précision  
**Statut:** Phase 3 complétée (5 décembre 2025)  
**Prochaine étape:** Phase 4 - Fichiers potentiellement obsolètes  

---

## 📋 CONTEXTE ACTUEL

### Cleanup Phase 3 - COMPLÉTÉE ✅
- **Fichiers supprimés:** 17
- **Lignes supprimées:** 17,086
- **Codebase:** ~71,500 lignes (vs ~112,000 avant = -36%)
- **Flutter Analyze:** 389 issues (-26%)
- **Build:** ✅ SUCCESS
- **Commit:** `cfe5966` - refactor(cleanup): Phase 3

### Statistiques Finales (Après Phase 3)
```
Fichiers Dart: 419
Lignes de code: ~71,500
Issues Flutter Analyze: 389
Fichiers supprimés total: 57
Lignes supprimées total: 40,607
```

---

## 🎯 PHASE 4 - OBJECTIFS

### Fichiers à Vérifier (Priorité Haute)

#### 1️⃣ `compo_finaux/` - Sheets Potentiellement Obsolètes

| Dossier | Statut | Action |
|---------|--------|--------|
| `add_filter_sheet/` | ❓ À vérifier | Chercher usage dans tout le projet |
| `create_edit_alert_sheet/` | ❓ À vérifier | Chercher usage dans tout le projet |
| `create_edit_point_of_interest_sheet/` | ⚠️ Interne | Utilisé par `points_of_interest_sheet` (POI supprimé) |
| `points_of_interest_sheet/` | ⚠️ Interne | POI supprimé - À vérifier si vraiment utilisé |

**Processus pour chaque:**
```bash
# 1. Chercher usage
grep -r "AddFilterSheetWidget\|CreateEditAlertSheetWidget\|..." lib/ --include="*.dart"

# 2. Si aucun usage externe trouvé:
#    - Vérifier dans les exports (lib/index.dart)
#    - Vérifier dans les pages legacy
#    - Vérifier dans les sheets

# 3. Si vraiment inutilisé:
#    - Supprimer le dossier
#    - Mettre à jour les exports
#    - Tester build
#    - Documenter dans CLEANUP_AUDIT_V1.md
```

#### 2️⃣ `components/` - Widgets Potentiellement Obsolètes

| Fichier | Statut | Action |
|---------|--------|--------|
| `item_room_chat_*` | ❓ À vérifier | Aucune référence trouvée |
| `item_wish_list_conv_*` | ❓ À vérifier | Aucune référence trouvée |
| `select_date_*` | ⚠️ À vérifier | Utilisé par sheets supprimés? |

**Processus:**
```bash
# 1. Chercher usage exact
grep -r "ItemRoomChatWidget\|ItemWishListConvWidget\|SelectDateWidget" lib/ --include="*.dart"

# 2. Vérifier dans les exports
grep -r "item_room_chat\|item_wish_list_conv\|select_date" lib/components/index.dart

# 3. Si inutilisé:
#    - Supprimer les fichiers
#    - Mettre à jour lib/components/index.dart
#    - Tester build
```

#### 3️⃣ `lib/pages/` - Pages Legacy Potentiellement Obsolètes

**À NE PAS SUPPRIMER** (utilisées dans nav.dart):
- ✅ `MessagesBridesWidget` - Utilisé
- ✅ `MessagesProWidget` - Utilisé
- ✅ `HomeBridesWidget` - Utilisé
- ✅ `FeedBridesWidget` - Utilisé
- ✅ `DashboardProWidget` - Utilisé
- ✅ `ProDetailsWidget` - Utilisé

**À vérifier:**
```bash
# Chercher les pages qui ne sont PAS dans nav.dart
find lib/pages -name "*_widget.dart" -type f | while read f; do
  name=$(basename "$f" _widget.dart)
  if ! grep -q "$name" lib/flutter_flow/nav/nav.dart; then
    echo "POTENTIELLEMENT INUTILISÉ: $f"
  fi
done
```

#### 4️⃣ `lib/custom_code/` - Actions & Widgets Restants

**Vérifier:**
```bash
# Actions inutilisées
grep -r "export.*\.dart" lib/custom_code/actions/index.dart | while read line; do
  action=$(echo "$line" | sed "s/.*'\(.*\)'.*/\1/")
  if ! grep -r "$action" lib/ --include="*.dart" | grep -v "index.dart" | grep -q .; then
    echo "ACTION INUTILISÉE: $action"
  fi
done

# Widgets inutilisés
grep -r "export.*\.dart" lib/custom_code/widgets/index.dart | while read line; do
  widget=$(echo "$line" | sed "s/.*'\(.*\)'.*/\1/")
  if ! grep -r "$widget" lib/ --include="*.dart" | grep -v "index.dart" | grep -q .; then
    echo "WIDGET INUTILISÉ: $widget"
  fi
done
```

#### 5️⃣ `lib/flutter_flow/` - Fichiers Restants

**À vérifier:**
```bash
# Lister tous les fichiers
ls -la lib/flutter_flow/

# Chercher usage de chaque fichier
for file in lib/flutter_flow/*.dart; do
  name=$(basename "$file" .dart)
  if ! grep -r "$name" lib/ --include="*.dart" | grep -v "flutter_flow/" | grep -q .; then
    echo "POTENTIELLEMENT INUTILISÉ: $file"
  fi
done
```

---

## 🔍 PROCESSUS STRICT (EXTRÊME PRÉCISION)

### Pour CHAQUE fichier à supprimer:

**ÉTAPE 1: Vérification Exhaustive**
```bash
# 1. Chercher le nom du fichier
grep -r "filename" lib/ --include="*.dart"

# 2. Chercher le nom de la classe/fonction
grep -r "ClassName" lib/ --include="*.dart"

# 3. Chercher dans les exports
grep -r "filename\|ClassName" lib/*/index.dart

# 4. Chercher dans les commentaires
grep -r "filename\|ClassName" lib/ --include="*.dart" | grep "//"

# 5. Vérifier les imports
grep -r "import.*filename" lib/ --include="*.dart"
```

**ÉTAPE 2: Vérification des Dépendances**
```bash
# Si le fichier importe d'autres fichiers
# Vérifier que ces dépendances ne sont pas utilisées ailleurs

# Si d'autres fichiers importent ce fichier
# Vérifier que ces fichiers ne sont pas critiques
```

**ÉTAPE 3: Suppression Sécurisée**
```bash
# 1. Supprimer le fichier
rm lib/path/to/file.dart

# 2. Mettre à jour les exports
# Éditer lib/path/index.dart et supprimer la ligne d'export

# 3. Vérifier la compilation
flutter analyze

# 4. Tester le build
./scripts/build_and_run.sh

# 5. Documenter
# Ajouter à CLEANUP_AUDIT_V1.md
```

**ÉTAPE 4: Validation**
```bash
# Après chaque suppression:
flutter analyze 2>&1 | tail -3

# Vérifier que:
# - Aucune nouvelle erreur
# - Le nombre d'issues diminue ou reste stable
# - Le build réussit
```

---

## 📊 DOCUMENTATION À METTRE À JOUR

### Après chaque suppression:

1. **CLEANUP_AUDIT_V1.md**
   - Ajouter le fichier à la section appropriée
   - Documenter la raison
   - Mettre à jour les statistiques

2. **REFACTORING_REPORT_MVP_TO_V1.md**
   - Mettre à jour les chiffres finaux
   - Ajouter le commit à la liste

3. **Commit Message**
   ```
   refactor(cleanup): Phase 4 - [Description]
   
   Deleted files:
   - file1.dart (reason)
   - file2.dart (reason)
   
   Files modified:
   - lib/path/index.dart
   
   Flutter Analyze: X issues (vs Y before)
   Build: ✅ SUCCESS
   ```

---

## ⚠️ PIÈGES À ÉVITER

### ❌ NE PAS FAIRE:
1. **Ne pas supprimer sans vérification** - Toujours chercher usage exhaustivement
2. **Ne pas supprimer les pages dans nav.dart** - Elles sont utilisées par la navigation
3. **Ne pas supprimer les exports sans mettre à jour index.dart** - Causera des erreurs
4. **Ne pas committer sans tester le build** - Risque de casser la compilation
5. **Ne pas utiliser `git clean`** - Risque de perte permanente de fichiers

### ✅ À FAIRE:
1. **Toujours vérifier avec grep avant de supprimer**
2. **Toujours tester le build après suppression**
3. **Toujours documenter dans CLEANUP_AUDIT_V1.md**
4. **Toujours faire un commit par groupe logique de suppressions**
5. **Toujours attendre la validation utilisateur avant de committer**

---

## 📈 OBJECTIFS PHASE 4

| Métrique | Cible |
|----------|-------|
| **Fichiers supprimés** | 5-10 |
| **Lignes supprimées** | 5,000-10,000 |
| **Flutter Analyze issues** | 350-370 |
| **Codebase final** | ~65,000-66,500 lignes |
| **Build** | ✅ SUCCESS |

---

## 🚀 WORKFLOW PHASE 4

1. **Vérification exhaustive** des fichiers potentiellement obsolètes
2. **Suppression sécurisée** avec validation à chaque étape
3. **Tests et validation** après chaque suppression
4. **Documentation** dans CLEANUP_AUDIT_V1.md
5. **Commit sécurisé** avec message détaillé
6. **Mise à jour** du rapport de refactorisation
7. **Validation utilisateur** avant de continuer

---

## 📝 FICHIERS DE RÉFÉRENCE

- **CLEANUP_AUDIT_V1.md** - Audit complet du cleanup
- **REFACTORING_REPORT_MVP_TO_V1.md** - Rapport global
- **PROJECT.md** - État du projet
- **lib/flutter_flow/nav/nav.dart** - Routes de navigation (NE PAS SUPPRIMER)
- **lib/index.dart** - Exports principaux

---

**Prêt pour Phase 4?** ✅  
**Approche:** Extrême précision, vérification exhaustive, test après chaque suppression  
**Objectif:** Continuer le nettoyage tout en maintenant la stabilité du projet

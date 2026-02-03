# Step 03: APEX Execution DEEP (Iteration jusqu'a Perfection)

> **Purpose**: Execution TDD avec iteration JUSQU'A PERFECTION. Ne jamais terminer avec des manquements. Verification Design System explicite.

---

## DIFFERENCE AVEC MODE STANDARD

| Aspect | Standard | DEEP |
|--------|----------|------|
| **Iterations** | Max 5 puis escalade | ITERER jusqu'a perfection |
| **Design System** | Mentionne | VERIFIE explicitement |
| **Self-critique** | Review adversariale | Double review + checklist exhaustive |
| **Tolerance** | Accepte MINEUR | ZERO manquement |
| **Verification finale** | Tests + analyze | Tests + analyze + Design System check |

---

## MANDATORY RULES (MODE DEEP)

- 🎯 **PERFECTION OBLIGATOIRE** : Ne JAMAIS terminer avec des manquements
- 🔍 **DESIGN SYSTEM VERIFIE** : Chaque widget doit utiliser les composants Lynewed*
- 🔄 **ITERATION ILLIMITEE** : Continuer jusqu'a ce que TOUT soit parfait
- 🧠 **AUTO-CRITIQUE SEVERE** : Etre impitoyable avec soi-meme
- 📋 **CHECKLIST EXHAUSTIVE** : Verifier CHAQUE point avant de valider
- ⚠️ **ZERO TOLERANCE** : Pas de MINEUR accepte - tout doit etre corrige

---

## EXECUTION PROTOCOLS

- 🎯 **Goal**: Implementation PARFAITE de chaque critere
- 💾 **Output**: Code PARFAIT sans aucun manquement
- 📖 **Reference**: `.claude/rules/ui-design-system.md`
- ⚡ **Performance**: Qualite ABSOLUE prime sur vitesse

---

## CONTEXT BOUNDARIES

**Available from previous steps:**
- `{story_id}` - Story being implemented
- `{story_content}` - Parsed story with criteria
- `{patterns_found}` - Existing patterns
- `{files_impacted}` - Files analysis
- `{implementation_plan}` - TDD plan by criterion

**Produced by this step:**
- `{code_written}` - Files created/modified
- `{tests_written}` - Test files created
- `{review_results}` - Review outcome avec verification Design System
- `{design_system_compliance}` - Rapport conformite Design System

---

## EXECUTION SEQUENCE

### 0. PREPARATION DESIGN SYSTEM

**AVANT de commencer l'implementation, RELIRE:**

```yaml
design_system_rules:
  read_file: ".claude/rules/ui-design-system.md"

  memorize:
    widgets:
      - LynewedButton → jamais ElevatedButton/TextButton
      - LynewedTextField → jamais TextField
      - LynewedChip → pour chips selectionnables
      - LynewedSlider → pour sliders
      - LynewedIconButton → pour boutons icone
      - LynewedSheet → pour bottom sheets
      - LynewedSectionTitle → pour titres de sections

    styles:
      - LynewedColors → jamais Colors.xxx
      - LynewedTextStyles → jamais TextStyle direct
      - LynewedSpacing → pour espacements

    import: "import '/core/design/design.dart';"

    espacements:
      - Inter-section: 30px
      - Label → Contenu: 10px
      - Items dans liste: 8-12px
      - Padding horizontal page: 20px
```

### 1. TDD CYCLE PAR CRITERE (ENRICHI)

Pour CHAQUE critere d'acceptance:

#### 1.1 RED Phase (Test First)

**Ecrire le test qui definit le comportement attendu.**

```dart
// test/features/{feature}/{component}_test.dart
group('[Criterion ID] - [Description]', () {
  test('should [expected behavior from Gherkin]', () {
    // Given - Setup matching criterion
    // When - Action from criterion
    // Then - Assertion from criterion
  });
});
```

**Executer pour confirmer l'echec:**

```bash
flutter test --no-pub test/path/specific_test.dart
```

#### 1.2 GREEN Phase (Implementation avec Design System)

**Implementer le code MINIMAL mais avec Design System:**

```dart
// lib/features/{feature}/presentation/pages/{page}.dart
import '/core/design/design.dart';  // OBLIGATOIRE

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ✅ CORRECT: Utiliser LynewedButton
          LynewedButton(
            label: 'Action',
            onPressed: () {},
          ),

          // ❌ INTERDIT: Ne jamais utiliser
          // ElevatedButton(...)
          // TextButton(...)

          // ✅ CORRECT: Utiliser LynewedTextField
          LynewedTextField(
            label: 'Input',
            controller: _controller,
          ),

          // ✅ CORRECT: Utiliser LynewedColors
          Container(
            color: LynewedColors.primary,  // ✅
            // color: Colors.blue,  // ❌ INTERDIT
          ),

          // ✅ CORRECT: Utiliser LynewedTextStyles
          Text(
            'Title',
            style: LynewedTextStyles.titleMedium,  // ✅
            // style: TextStyle(fontSize: 20),  // ❌ INTERDIT
          ),
        ],
      ),
    );
  }
}
```

**Executer pour confirmer le succes:**

```bash
flutter test --no-pub test/path/specific_test.dart
```

#### 1.3 REFACTOR Phase (Clean Code + Design System Check)

**Ameliorer le code ET verifier le Design System:**

```yaml
refactor_checklist:
  - [ ] Patterns existants reutilises
  - [ ] Duplication eliminee
  - [ ] Nommage conforme au projet
  - [ ] Design System 100% respecte
  - [ ] Imports corrects
```

**Executer pour confirmer:**

```bash
flutter test --no-pub test/path/specific_test.dart
flutter analyze lib/features/{feature}/
```

### 2. VALIDATE APPROFONDI

**CRITICAL**: Validation technique AVANT review.

#### 2.1 Tests

```bash
flutter test --no-pub
```

**Expected**: 0 failures

#### 2.2 Analyze

```bash
flutter analyze --fatal-infos
```

**Expected**: 0 issues

#### 2.3 Design System Verification (NOUVEAU)

**Chercher les violations:**

```bash
# Violations boutons
grep -rn "ElevatedButton\|TextButton\|OutlinedButton" lib/features/{feature}/ || echo "✅ Aucune violation bouton"

# Violations TextField
grep -rn "TextField(" lib/features/{feature}/ || echo "✅ Aucune violation TextField"

# Violations couleurs
grep -rn "Colors\." lib/features/{feature}/ | grep -v "LynewedColors" || echo "✅ Aucune violation couleur"

# Violations TextStyle direct
grep -rn "TextStyle(" lib/features/{feature}/ | grep -v "copyWith" || echo "✅ Aucune violation TextStyle"
```

**Si violations trouvees:**
- CORRIGER IMMEDIATEMENT
- Ne PAS passer a l'etape suivante

### 3. EXAMINE APPROFONDI (Review Adversariale SEVERE)

**CHANGEMENT DE ROLE OBLIGATOIRE**

Tu es maintenant un **Reviewer IMPITOYABLE** dont le but est de trouver TOUS les problemes.

#### 3.1 Checklist Exhaustive par Critere

Pour CHAQUE critere d'acceptance:

**Conformite Gherkin:**
- [ ] Implementation correspond EXACTEMENT au Gherkin
- [ ] Pas de scope creep (features non demandees)
- [ ] Pas de comportement manquant

**Design System (CRITIQUE):**
- [ ] TOUS les boutons utilisent LynewedButton
- [ ] TOUS les inputs utilisent LynewedTextField
- [ ] TOUTES les couleurs utilisent LynewedColors
- [ ] TOUS les styles texte utilisent LynewedTextStyles
- [ ] TOUTES les sheets utilisent LynewedSheet
- [ ] Import `design.dart` present
- [ ] Espacements respectes (30px inter-section, 10px label→contenu)

**Securite:**
- [ ] Pas d'injection possible
- [ ] Pas de donnees sensibles exposees
- [ ] Validation des inputs

**Logique:**
- [ ] Edge cases geres
- [ ] Pas de race conditions
- [ ] Pas d'erreurs silencieuses

**Tests:**
- [ ] Test couvre TOUS les aspects du Gherkin
- [ ] Cas limites testes
- [ ] Comportement d'erreur teste

#### 3.2 Self-Critique SEVERE

**Questions a se poser:**

```yaml
self_critique:
  design_system:
    - "Ai-je verifie CHAQUE widget pour le Design System ?"
    - "Ai-je cherche des Colors.xxx dans le code ?"
    - "Ai-je cherche des TextStyle() directs ?"
    - "Ai-je verifie les imports ?"

  completeness:
    - "TOUS les criteres Gherkin sont-ils implementes ?"
    - "Ai-je oublie un cas d'usage ?"
    - "Les tests couvrent-ils vraiment tout ?"

  quality:
    - "Ce code est-il PARFAIT ?"
    - "Serais-je fier de ce code ?"
    - "Un reviewer senior trouverait-il des problemes ?"
```

#### 3.3 Verdict

**APPROUVER seulement si:**
- ✅ TOUS les criteres Gherkin implementes
- ✅ Design System 100% respecte
- ✅ Tests couvrent tout
- ✅ 0 issues analyze
- ✅ Aucune violation trouvee
- ✅ Self-critique passe

**Si MOINDRE probleme:**
- REJETER
- Lister les problemes
- Corriger
- Re-review

### 4. RESOLVE + ITERATION (JUSQU'A PERFECTION)

**Boucle d'iteration:**

```
┌────────────────────────────────────────────────────────────────────────────┐
│                    BOUCLE PERFECTION                                        │
│                                                                             │
│  EXAMINE ──► Probleme trouve ? ──► OUI ──► CORRIGER                         │
│      ↑                                         │                            │
│      │                                         ↓                            │
│      └──────────── RE-VALIDATE ◄───────── CORRECTIONS                       │
│                         │                                                   │
│                         ↓                                                   │
│                 Probleme trouve ? ──► NON ──► PARFAIT ✅                    │
│                                                                             │
│  CONTINUER JUSQU'A PERFECTION - PAS DE LIMITE D'ITERATIONS                 │
└────────────────────────────────────────────────────────────────────────────┘
```

**Pour chaque probleme trouve:**

1. **Identifier precisement:**
   - Fichier + ligne
   - Nature du probleme
   - Correction necessaire

2. **Corriger:**
   - Appliquer la correction
   - Ecrire test si necessaire

3. **Re-valider:**
   - Re-run tests
   - Re-run analyze
   - Re-run Design System check

4. **Re-examiner:**
   - Review adversariale complete
   - Self-critique

**Continuer jusqu'a 0 probleme trouve.**

### 5. RAPPORT FINAL DETAILLE

**Generer un rapport complet:**

```markdown
# Rapport Execution DEEP - {story_id}

## Status: COMPLETE

## Criteres d'Acceptance

| AC | Description | Impl | Test | Design System |
|----|-------------|------|------|---------------|
| AC1 | [desc] | ✅ | ✅ | ✅ |
| AC2 | [desc] | ✅ | ✅ | ✅ |

## Design System Compliance

### Verification Automatique
- Boutons Lynewed*: ✅ {X} occurrences trouvees
- TextField Lynewed: ✅ {Y} occurrences
- LynewedColors: ✅ Pas de Colors.xxx
- LynewedTextStyles: ✅ Pas de TextStyle direct
- Import design.dart: ✅ Present dans tous les fichiers

### Verification Manuelle
- [ ] Espacements corrects (30px/10px)
- [ ] Patterns references respectes
- [ ] Coherence avec ecrans existants

## Fichiers

### Crees
- `lib/features/{feature}/...`: [description]

### Modifies
- `lib/features/{feature}/...`: [description]

## Tests

- Nombre: {X} tests
- Status: ✅ PASS
- Couverture AC: {X}/{X} (100%)

## Iterations Review

- Iteration 1: {X} problemes → corriges
- Iteration 2: {Y} problemes → corriges
- Iteration N: 0 problemes → PARFAIT

## Self-Critique Finale

- [ ] Tous AC implementes
- [ ] Design System 100% respecte
- [ ] Tests couvrent tout
- [ ] 0 warnings analyze
- [ ] Code PARFAIT

## Verdict: ✅ PARFAIT - Ready for verification
```

---

## AUTO-VALIDATION DEEP

**Avant de terminer, verifier:**

✅ TOUS les criteres d'acceptance implementes
✅ TOUS les tests passent
✅ 0 warnings analyze
✅ Design System 100% respecte (verification automatique + manuelle)
✅ Review adversariale APPROUVE
✅ Self-critique SEVERE passe
✅ Rapport detaille genere
✅ ZERO manquement, ZERO probleme

**Si MOINDRE echec:**
- NE PAS terminer
- Corriger
- Re-valider
- Continuer jusqu'a perfection

---

## SUCCESS METRICS

✅ Implementation PARFAITE
✅ Design System 100% conforme
✅ Tests complets et passants
✅ 0 issues analyze
✅ Review adversariale APPROUVE
✅ Self-critique SEVERE validee
✅ Rapport complet genere

## FAILURE MODES

❌ Probleme non corrige → CONTINUER a iterer
❌ Design System viole → CORRIGER avant tout
❌ Test manquant → ECRIRE le test
❌ Critere oublie → IMPLEMENTER
❌ Self-critique echoue → RE-EXAMINER

**EN MODE DEEP, IL N'Y A PAS D'ECHEC - SEULEMENT DES ITERATIONS SUPPLEMENTAIRES**

---

## NEXT STEP

Quand PARFAIT atteint, load `steps/step-04-verify.md`

<critical>
MODE DEEP = PERFECTION OBLIGATOIRE
Design System STRICTEMENT verifie (.claude/rules/ui-design-system.md)
ITERER jusqu'a 0 probleme - pas de limite
Self-critique SEVERE et IMPITOYABLE
JAMAIS terminer avec des manquements
Rapport DETAILLE obligatoire
</critical>

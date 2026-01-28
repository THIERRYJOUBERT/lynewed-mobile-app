# Story S-02: Audit Validation Inputs Utilisateur

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | S-02 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P1 - HAUTE |
| **Estimation** | 3h |
| **Statut** | COMPLETE |

---

## Description

En tant que **security engineer**, je veux auditer toute la validation des inputs utilisateur afin de **prevenir les injections et corruptions de donnees**.

---

## Contexte

L'application collecte des inputs utilisateur a plusieurs endroits:
- Formulaires d'inscription/connexion
- Messages chat
- Recherche (Google Places)
- Profils (nom, bio, etc.)
- Creation de weddings/events

### Points d'Entree Identifies

| Zone | Fichiers | Risque |
|------|----------|--------|
| Auth | `lib/pages/auth/*.dart` | Injection email/password |
| Chat | `lib/features/chat/presentation/widgets/message_composer.dart` | XSS, injection |
| Profile | `lib/pages/bride/edit_profile_brides/` | Injection bio/nom |
| Search | `lib/compo_finaux/address_search/` | Injection recherche |
| Wedding | `lib/features/my_wedding/presentation/sheets/` | Injection nom/notes |

---

## Criteres d'Acceptance

- [x] Audit de tous les TextEditingController et inputs
- [x] Rapport des inputs non valides/non sanitizes
- [x] Implementation validation pour tous les inputs critiques
- [x] Tests pour cas limites (XSS, SQL-like, unicode malicieux)
- [x] Documentation des patterns de validation

---

## Checklist Securite

### Audit Inputs
- [ ] Lister tous les `TextEditingController` dans le codebase
- [ ] Verifier presence de validation sur chaque input
- [ ] Identifier inputs qui vont vers Supabase sans sanitization
- [ ] Verifier longueur max sur inputs text

### Validation a Implementer
- [ ] Email: regex + longueur max
- [ ] Password: longueur min/max + complexite
- [ ] Nom/Prenom: caracteres autorises + longueur
- [ ] Bio/Description: longueur max + strip HTML
- [ ] Messages chat: longueur max + sanitization
- [ ] Recherche: longueur max + caracteres speciaux

### Tests
- [ ] Input vide
- [ ] Input avec caracteres speciaux `<script>alert('xss')</script>`
- [ ] Input avec SQL-like `'; DROP TABLE users; --`
- [ ] Input tres long (>10000 chars)
- [ ] Input avec unicode malicieux

---

## Implementation

### Pattern de Validation Recommande

```dart
class InputValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email requis';
    if (value.length > 254) return 'Email trop long';
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) return 'Email invalide';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Nom requis';
    if (value.length > 100) return 'Nom trop long (max 100)';
    // Autoriser lettres, espaces, tirets, apostrophes
    final nameRegex = RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$");
    if (!nameRegex.hasMatch(value)) return 'Caracteres non autorises';
    return null;
  }

  static String sanitizeForDisplay(String input) {
    // Echapper HTML basique
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }
}
```

### Fichiers a Auditer

1. `lib/pages/auth/sign_up_email_page/sign_up_email_page_widget.dart`
2. `lib/pages/auth/sign_in_email_page/sign_in_email_page_widget.dart`
3. `lib/features/chat/presentation/widgets/message_composer.dart`
4. `lib/pages/bride/edit_profile_brides/edit_profile_brides_widget.dart`
5. `lib/compo_finaux/address_search/address_search_widget.dart`
6. `lib/features/my_wedding/presentation/sheets/*.dart`

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| XSS stocke | HAUTE | Sanitization systematique + CSP |
| Injection Supabase | HAUTE | RLS + validation cote serveur |
| DoS via input long | MOYENNE | Limites de longueur strictes |

---

## Definition of Done

- [x] Tous les inputs audites
- [x] Validation implementee sur inputs critiques
- [x] Tests de regression passent
- [x] Documentation des validators creee
- [ ] PR reviewee et mergee

---

## Implementation Notes (2026-01-24)

### Files Created
- `lib/core/utils/input_validators.dart` - Centralized input validation class
- `test/core/utils/input_validators_test.dart` - 74 unit tests

### Files Modified
- `lib/pages/auth/sign_up_email_page/sign_up_email_page_model.dart` - Added validators
- `lib/pages/auth/sign_in_email_page/sign_in_email_page_model.dart` - Added validators
- `lib/pages/bride/edit_profile_brides/edit_profile_brides_model.dart` - Added validators
- `lib/features/chat/presentation/widgets/message_composer.dart` - Added validation before send
- `lib/features/my_wedding/presentation/sheets/add_guest_sheet.dart` - Added validators
- `lib/features/my_wedding/presentation/sheets/add_event_sheet.dart` - Added validators
- `lib/features/my_wedding/presentation/sheets/wedding_edit_sheet.dart` - Added validators

### Validation Implemented
| Input Type | Max Length | Checks |
|------------|------------|--------|
| Email | 254 | RFC 5321 format |
| Password | 8-128 | Uppercase, lowercase, digit |
| Name | 100 | Unicode letters, spaces, hyphens, apostrophes; XSS/SQL/Unicode checks |
| Bio | 500 | HTML tag detection |
| Message | 2000 | Length only |
| Phone | 20 | Digits, +, -, (), spaces |
| Search | 200 | Length only |

### Security Features
- XSS prevention via HTML tag detection and sanitization
- SQL injection pattern detection
- Malicious unicode character detection (invisible formatting characters)
- DoS prevention via length limits on all inputs
- Performance: All validators complete <100ms even for 10000+ char inputs

### Design Decisions
- Zero-width joiner (U+200D) is allowed for emoji sequences
- Message validation does NOT check HTML/SQL (Flutter Text widgets don't execute)
- Phone validation is lenient to support international formats

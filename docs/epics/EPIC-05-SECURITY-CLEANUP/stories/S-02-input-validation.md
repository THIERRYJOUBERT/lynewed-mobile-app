# Story S-02: Audit Validation Inputs Utilisateur

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | S-02 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P1 - HAUTE |
| **Estimation** | 3h |
| **Statut** | NOT_STARTED |

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

- [ ] Audit de tous les TextEditingController et inputs
- [ ] Rapport des inputs non valides/non sanitizes
- [ ] Implementation validation pour tous les inputs critiques
- [ ] Tests pour cas limites (XSS, SQL-like, unicode malicieux)
- [ ] Documentation des patterns de validation

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

- [ ] Tous les inputs audites
- [ ] Validation implementee sur inputs critiques
- [ ] Tests de regression passent
- [ ] Documentation des validators creee
- [ ] PR reviewee et mergee

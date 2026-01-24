# Story S-05: Checklist OWASP Mobile Top 10

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | S-05 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P2 - MOYENNE |
| **Estimation** | 4h |
| **Statut** | NOT_STARTED |

---

## Description

En tant que **security engineer**, je veux verifier la conformite OWASP Mobile Top 10 2024 afin de **garantir que l'application suit les best practices securite mobile**.

---

## Contexte

L'OWASP Mobile Top 10 definit les 10 risques securite les plus critiques pour les applications mobiles. Cette checklist permet de valider systematiquement la securite de Lynewed.

---

## Checklist OWASP Mobile Top 10 (2024)

### M1: Improper Credential Usage

**Risque**: Credentials mal stockees ou transmises

| Check | Statut | Notes |
|-------|--------|-------|
| Credentials stockees dans flutter_secure_storage | [ ] | Verifier auth_util.dart |
| Pas de credentials en dur | [ ] | Voir S-01 |
| HTTPS pour toutes les communications | [ ] | Supabase force HTTPS |
| Certificate pinning | [ ] | Non implemente? |

**Actions:**
- [ ] Verifier storage des credentials
- [ ] Implementer certificate pinning (optionnel)

---

### M2: Inadequate Supply Chain Security

**Risque**: Dependances vulnerables

| Check | Statut | Notes |
|-------|--------|-------|
| Dependances a jour | [ ] | Verifier pubspec.yaml |
| Pas de packages deprecated | [ ] | flutter pub outdated |
| Verification integrite packages | [ ] | pubspec.lock commite |

**Actions:**
- [ ] `flutter pub outdated` - lister updates
- [ ] Scanner vulnerabilites connues
- [ ] Mettre a jour packages critiques

---

### M3: Insecure Authentication/Authorization

**Risque**: Failles dans auth/authz

| Check | Statut | Notes |
|-------|--------|-------|
| Auth forte (password policy) | [ ] | Verifier signup |
| Session management secure | [ ] | Voir S-03 |
| Token expiration | [ ] | JWT Supabase |
| Role-based access (bride vs pro) | [ ] | Verifier RLS |

**Actions:**
- [ ] Audit complet auth (S-03)
- [ ] Verifier distinction bride/pro

---

### M4: Insufficient Input/Output Validation

**Risque**: Injection, XSS

| Check | Statut | Notes |
|-------|--------|-------|
| Validation inputs | [ ] | Voir S-02 |
| Sanitization outputs | [ ] | Verifier affichage |
| Parameterized queries | [ ] | Supabase client |

**Actions:**
- [ ] Audit validation (S-02)
- [ ] Verifier sanitization affichage messages

---

### M5: Insecure Communication

**Risque**: Man-in-the-middle, eavesdropping

| Check | Statut | Notes |
|-------|--------|-------|
| TLS 1.2+ | [ ] | Supabase/Firebase |
| No mixed content | [ ] | Pas HTTP en dur |
| Certificate validation | [ ] | Default Flutter |

**Actions:**
- [ ] Grep pour `http://` (non-HTTPS)
- [ ] Verifier config Firebase

---

### M6: Inadequate Privacy Controls

**Risque**: Donnees personnelles exposees

| Check | Statut | Notes |
|-------|--------|-------|
| Minimisation donnees | [ ] | Collecter uniquement necessaire |
| Consentement utilisateur | [ ] | Terms of Service |
| Droit a l'effacement | [ ] | Delete account |
| Logs sans PII | [ ] | Voir S-04 |

**Actions:**
- [ ] Verifier delete account efface tout
- [ ] Audit logs (S-04)

---

### M7: Insufficient Binary Protections

**Risque**: Reverse engineering, tampering

| Check | Statut | Notes |
|-------|--------|-------|
| Code obfuscation | [ ] | --obfuscate flag |
| Anti-tampering | [ ] | Non implemente |
| Root/jailbreak detection | [ ] | Non implemente |

**Actions:**
- [ ] Activer obfuscation dans build release
- [ ] Evaluer besoin root detection

**Build avec obfuscation:**
```bash
flutter build apk --obfuscate --split-debug-info=build/debug-info
flutter build ios --obfuscate --split-debug-info=build/debug-info
```

---

### M8: Security Misconfiguration

**Risque**: Debug mode en prod, permissions excessives

| Check | Statut | Notes |
|-------|--------|-------|
| Debug mode off en production | [ ] | kReleaseMode |
| Permissions minimales | [ ] | Verifier Info.plist/Manifest |
| Backup disabled | [ ] | android:allowBackup |
| WebView secure | [ ] | JS disabled si possible |

**Actions:**
- [ ] Verifier kDebugMode gates
- [ ] Audit permissions demandees
- [ ] Verifier android:allowBackup="false"

---

### M9: Insecure Data Storage

**Risque**: Donnees sensibles sur device non protegees

| Check | Statut | Notes |
|-------|--------|-------|
| Encryption at rest | [ ] | flutter_secure_storage |
| Pas de SharedPreferences pour secrets | [ ] | Verifier |
| Cache securise | [ ] | flutter_cache_manager |
| Clipboard cleared | [ ] | Apres copie sensible |

**Actions:**
- [ ] Grep SharedPreferences usage
- [ ] Verifier ce qui est cache localement

---

### M10: Insufficient Cryptography

**Risque**: Crypto faible ou mal implementee

| Check | Statut | Notes |
|-------|--------|-------|
| Algorithmes standards | [ ] | AES-256, RSA-2048+ |
| Pas de crypto custom | [ ] | Utiliser libraries |
| Keys non hardcodees | [ ] | Voir S-01 |
| Random secure | [ ] | Dart Random.secure() |

**Actions:**
- [ ] Verifier usage package crypto
- [ ] Pas de MD5/SHA1 pour securite

---

## Resume Findings

| Category | Status | Priority |
|----------|--------|----------|
| M1 - Credentials | [ ] TODO | HAUTE |
| M2 - Supply Chain | [ ] TODO | MOYENNE |
| M3 - Auth | [ ] TODO | HAUTE |
| M4 - Validation | [ ] TODO | HAUTE |
| M5 - Communication | [ ] TODO | MOYENNE |
| M6 - Privacy | [ ] TODO | HAUTE |
| M7 - Binary | [ ] TODO | BASSE |
| M8 - Misconfiguration | [ ] TODO | MOYENNE |
| M9 - Storage | [ ] TODO | HAUTE |
| M10 - Crypto | [ ] TODO | BASSE |

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Non-conformite OWASP | HAUTE | Checklist systematique |
| Failles non detectees | CRITIQUE | Audit externe? |

---

## Definition of Done

- [ ] Checklist OWASP completee
- [ ] Tous les checks documentes (pass/fail/NA)
- [ ] Issues critiques remontees comme stories
- [ ] Rapport OWASP sauvegarde
- [ ] PR avec fixes mineurs merged

# 🔐 AUTH FEATURE AUDIT

> **Date**: 2025-12-05  
> **Objectif**: Comprendre l'état actuel du module Auth et planifier le refactoring  
> **Estimation**: 5-8h

---

## 📁 STRUCTURE ACTUELLE

### Pages Auth (`lib/pages/auth/`)

| Page | Fichier | Usage | État |
|------|---------|-------|------|
| **AuthWelcomePage** | `auth_welcome_page/` | Page d'accueil avec choix Login/SignUp | ✅ Fonctionnel |
| **SignInEmailPage** | `sign_in_email_page/` | Login Bride par email | ✅ Fonctionnel |
| **SignInEmailPagePro** | `sign_in_email_page_pro/` | Login Pro par email | ✅ Fonctionnel |
| **SignUpEmailPage** | `sign_up_email_page/` | Inscription Bride | ✅ Fonctionnel |
| **SetPasswordPagePro** | `set_password_page_pro/` | Première connexion Pro (set password) | ✅ Fonctionnel |
| **ForgotPasswordPage** | `forgot_password_page/` | Demande reset password | ⚠️ À vérifier |
| **ResetPasswordNewPage** | `reset_password_new_page/` | Nouveau password après reset | ✅ Fonctionnel |
| **StartupGate** | `startup_gate/` | Router initial après login | ✅ Fonctionnel |

### Onboarding (`lib/pages/onboarding/`)

| Page | Usage | État |
|------|-------|------|
| **OnboardingBridesWizard** | Wizard complet pour nouvelles Brides | ✅ Fonctionnel |

### Auth Utils (`lib/auth/`)

| Fichier | Usage |
|---------|-------|
| `auth_manager.dart` | Gestionnaire auth abstrait |
| `base_auth_user_provider.dart` | Provider utilisateur de base |
| `supabase_auth/auth_util.dart` | Utilitaires Supabase Auth |
| `supabase_auth/email_auth.dart` | Auth par email |
| `supabase_auth/supabase_auth_manager.dart` | Manager Supabase spécifique |

---

## 🔍 ANALYSE DES FLOWS ACTUELS

### Flow Bride (Utilisateur final)

```
AuthWelcomePage
    ├── "Log in" → SignInEmailPage → StartupGate → HomeBrides
    └── "Sign in" → SignUpEmailPage → StartupGate → OnboardingBridesWizard → HomeBrides
```

**Observations:**
- ✅ Flow complet et fonctionnel
- ✅ Onboarding wizard pour nouvelles inscriptions
- ⚠️ "Sign in" devrait être "Sign up" (confusion UX)
- ⚠️ Utilise `FlutterFlowTheme` au lieu de `LynewedTheme`

### Flow Pro (Professionnel)

```
AuthWelcomePage
    └── "I'M A VENDOR" → Dialog → SignInEmailPagePro
                              ├── Login direct → StartupGate → DashboardPro
                              ├── "Set my password" → SetPasswordPagePro
                              └── "Forgot password?" → ForgotPasswordPage
```

**Observations:**
- ✅ Login Pro fonctionnel
- ✅ Set password pour première connexion (compte créé via CRM)
- ⚠️ "Forgot password" présent mais devrait être géré CRM
- ⚠️ Pas de page d'inscription Pro (intentionnel - via site web)
- ⚠️ Dialog "Professional Access" un peu abrupt

### StartupGate (Router)

```dart
// Logique actuelle:
1. Vérifier deeplink reset-password → ResetPasswordNewPage
2. Si loggedIn:
   - Charger sessionData
   - Si Bride + (pas de nom OU pas de locale OU TOS non accepté) → OnboardingBridesWizard
   - Sinon Bride → HomeBrides
   - Sinon Pro → DashboardPro
3. Si non loggedIn → AuthWelcomePage
```

**Observations:**
- ✅ Gestion deeplinks reset password
- ✅ Redirection selon rôle
- ✅ Onboarding conditionnel pour Brides
- ⚠️ Pas d'onboarding Pro (normal - profil créé via CRM)

---

## 🎯 TÂCHES DE REFACTORING

### 2.1 Pages Auth Unifiées

| Tâche | Priorité | Effort |
|-------|----------|--------|
| ~~Supprimer "reset password" côté pro~~ | ❌ **ANNULÉ** - Nécessaire pour première connexion | - |
| Corriger label "Sign in" → "Sign up" sur AuthWelcomePage | 🟢 Facile | 5min |
| Améliorer Dialog "Professional Access" | 🟡 Moyen | 30min |
| Vérifier que "Forgot password" Pro redirige vers site | 🟡 Moyen | 30min |

### 2.2 Onboarding Progressif

| Tâche | Priorité | Effort |
|-------|----------|--------|
| Demander permissions au bon moment | 🟡 Moyen | 2h |
| Vérifier flow OnboardingBridesWizard | 🟢 Facile | 30min |
| Pas d'onboarding Pro nécessaire (CRM) | ✅ Déjà fait | - |

### 2.3 Design System v3

| Tâche | Priorité | Effort |
|-------|----------|--------|
| AuthWelcomePage → LynewedTheme | 🟡 Moyen | 1h |
| SignInEmailPage → LynewedTheme | 🟡 Moyen | 1h |
| SignInEmailPagePro → LynewedTheme | 🟡 Moyen | 1h |
| SignUpEmailPage → LynewedTheme | 🟡 Moyen | 1h |
| SetPasswordPagePro → LynewedTheme | 🟡 Moyen | 30min |
| ForgotPasswordPage → LynewedTheme | 🟡 Moyen | 30min |
| ResetPasswordNewPage → LynewedTheme | 🟡 Moyen | 30min |

---

## 📋 PLAN D'EXÉCUTION RECOMMANDÉ

### Phase 2.1 - Quick Fixes (30min)
1. Corriger "Sign in" → "Sign up" sur AuthWelcomePage
2. Vérifier comportement "Forgot password" Pro

### Phase 2.2 - Design System Migration (4-5h)
1. Créer constantes communes (images, textes)
2. Migrer AuthWelcomePage vers LynewedTheme
3. Migrer SignInEmailPage vers LynewedTheme
4. Migrer SignInEmailPagePro vers LynewedTheme
5. Migrer SignUpEmailPage vers LynewedTheme
6. Migrer pages secondaires (SetPassword, Forgot, Reset)

### Phase 2.3 - Permissions & UX (1-2h)
1. Vérifier demandes permissions dans OnboardingBridesWizard
2. S'assurer que les permissions sont demandées au bon moment
3. Tester flow complet Bride et Pro

---

## ⚠️ POINTS D'ATTENTION

### Ce qu'il NE FAUT PAS changer
- ❌ Flow Pro sans inscription (intentionnel - via CRM/site)
- ❌ SetPasswordPagePro (nécessaire pour première connexion)
- ❌ Logique StartupGate (fonctionne bien)

### Ce qu'il FAUT améliorer
- ✅ Labels UX (Sign in vs Sign up)
- ✅ Design System unifié
- ✅ Cohérence visuelle entre pages

### Dépendances
- `lib/core/design/design.dart` - Design System
- `lib/flutter_flow/flutter_flow_theme.dart` - À remplacer progressivement

---

## 🔗 FICHIERS CLÉS

```
lib/pages/auth/
├── auth_welcome_page/
│   ├── auth_welcome_page_model.dart
│   └── auth_welcome_page_widget.dart      ← Point d'entrée
├── sign_in_email_page/
│   └── sign_in_email_page_widget.dart     ← Login Bride
├── sign_in_email_page_pro/
│   └── sign_in_email_page_pro_widget.dart ← Login Pro
├── sign_up_email_page/
│   └── sign_up_email_page_widget.dart     ← Register Bride
├── set_password_page_pro/
│   └── set_password_page_pro_widget.dart  ← First login Pro
├── forgot_password_page/
│   └── forgot_password_page_widget.dart   ← Reset request
├── reset_password_new_page/
│   └── reset_password_new_page_widget.dart ← New password
└── startup_gate/
    └── startup_gate_widget.dart           ← Router
```

---

## ✅ VALIDATION

Après refactoring, vérifier:
- [ ] Login Bride fonctionne
- [ ] Register Bride fonctionne + redirige vers Onboarding
- [ ] Login Pro fonctionne
- [ ] Set Password Pro fonctionne (première connexion)
- [ ] Forgot Password envoie email
- [ ] Reset Password via deeplink fonctionne
- [ ] Design System v3 appliqué sur toutes les pages
- [ ] Permissions demandées au bon moment

---

**Estimation finale**: 5-6h de travail effectif

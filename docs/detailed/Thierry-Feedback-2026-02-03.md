# Feedback Thierry - 3 Février 2026

> Extraction complète des demandes issues des mails et WhatsApp de Thierry.
> Document de référence pour planifier les prochaines actions.

---

## 📊 Vue d'Ensemble

| Catégorie | Nombre | Priorité |
|-----------|--------|----------|
| Quick Fixes urgents (App) | 2 | 🔴 URGENT |
| Bugs CRM (Tom) | 2 | 🔴 URGENT (pas nous) |
| Mise à jour Epic-12 | 1 | 🟠 IMPORTANT |
| Nouvelles features | 3 | 🟡 À DISCUTER |
| Infos/Clarifications | 4 | 🔵 INFO |

---

## 🔴 QUICK FIXES URGENTS (App Mobile - Léo)

### 1. Filtre prix minimum à 0 pour certaines catégories

**Source** : Mail "prix magazine + filters"

**Problème** : Le filtre de prix sur la carte commence à 5000€, mais beaucoup de vendors (content creators, makeup artists, etc.) ont des tarifs inférieurs.

**Catégories concernées** :
- Content Creator
- Makeup Artist
- Flower
- Stationery
- Hair Dresser

> "Pour les content creator, make up artist, flower et stationery en fin de compte toutes les catégories à part (photographer, filmmaker, photo et movie, venues, bridal designer) il faut leur mettre en place leur prix commençant dans la tranche 0 to 5000"

**Action requise** :
- Modifier le slider de prix pour ces catégories : min = 0 au lieu de 5000
- Les catégories **Photographer, Filmmaker, Photo & Movie, Venues, Bridal Designer** gardent min = 5000

**Fichier probable** : `lib/features/map/presentation/widgets/filter_sheet.dart`

**Temps estimé** : 30 min - 1h

---

### 2. Option pour cacher le montant sur profil (Stationery)

**Source** : Mail "Filtres"

**Problème** : Une ambassadrice Stationery à NYC (102K followers) ne veut pas afficher de tranche de prix car "ça va de 0 à beaucoup".

> "Est ce qu'on peut pour stationnery ne pas mettre de montant qui s'affiche sur son profil ? car elle dit que ca va de 0 à beaucoup... et c'est une grosse ambassadrice à new york a 102 000 followers"

**Action requise** (2 options) :
1. **Option simple** : Ne pas afficher le prix pour la catégorie Stationery (hardcodé)
2. **Option flexible** : Ajouter un toggle "Hide pricing" dans le profil pro (plus de travail)

**Temps estimé** : 30 min (option 1) ou 1-2h (option 2)

---

## 🔴 BUGS CRM (Tom - Pas nous)

### 3. Pros avec abonnement annulé encore visibles sur la map

**Source** : Mail "bugs"

**Problème** : Des professionnels dont l'abonnement Stripe a été annulé apparaissent encore sur la carte.

**Exemples cités** :
- **Mezinoi Haiduc** (Paris) - Abonnement annulé le 21 janv. 2026 à 11:36
- **Aida Lopes del Castillo** - Même situation
- **Ina** - Présente sur la map mais pas dans Stripe

> "il faut s'assurer qu'un mec qui paye pas n'ai plus accès à l'app et au crm et qu'il ne soit pas sur la map aussi. Ca doit s'effacer automatiquement."

**Action requise** : Tom doit vérifier la logique de synchronisation Stripe → visibilité map/CRM

---

### 4. Webhooks Stripe en erreur sur le CRM

**Source** : Mail "Fwd: Problèmes de livraison de webhooks Stripe"

**Problème** : Stripe signale des problèmes de livraison de webhooks vers `https://pjcorrkwafjskmzmimon.supabase.co` (projet CRM).

**Action requise** : Tom doit investiguer les webhooks du CRM

---

## 🟠 MISE À JOUR EPIC-12 (Magazines)

### 5. Nouveaux prix magazines confirmés (4 formats)

**Source** : Mail "prix magazine + filters"

**Ancienne version** : 1 seul prix ($49 / ~49€)

**Nouvelle version** : 4 produits avec tailles et prix différents

| Format | Taille | Spreads | Prix TTC (hors livraison) |
|--------|--------|---------|---------------------------|
| **GUEST EDITION** | 21×30 cm | 20 | **27 €** |
| **ICONIC** | 21×30 cm | 40 | **54 €** |
| **MEMORY** | 21×30 cm | 60 | **64,80 €** |
| **COLLECTOR** | 25×32 cm | 60 | **85 €** |

> "j'ai recu les prix des magazines avec une multitude de taille et prix mais on va partir sur ces 4 produits pour commencer et faire simple, c'est le prix ttc hors livraison que fedex calculera."

**Impact sur Epic-12** :
- **S09 (Preview)** : Ajouter sélection du format avant checkout
- **S10 (Checkout)** : Prix dynamique selon format sélectionné
- **Stripe** : Créer 4 produits au lieu de 1

**Produits Stripe à créer** :
```
1. Lynewed Magazine - GUEST EDITION (27€ = 2700 cents)
2. Lynewed Magazine - ICONIC (54€ = 5400 cents)
3. Lynewed Magazine - MEMORY (64.80€ = 6480 cents)
4. Lynewed Magazine - COLLECTOR (85€ = 8500 cents)
```

---

## 🟡 NOUVELLES FEATURES (À discuter avec Thierry)

### 6. Notification Ultimate pour nouveaux weddings

**Source** : Mail "prix magazine + filters"

**Demande** : Les pros Ultimate doivent être notifiés quand une bride crée un wedding près d'eux (ou dans le même pays).

> "ya t'il possibilité d'ajouter une fonction/notification sur écran smartphone en prio et dans l'app pour que l'ultimate soit averti quand une brides créé un point wed ? près de lui ? dans le meme pays?"

**Contexte business** :
- Seuls les Ultimate peuvent contacter les brides (pas les Premium)
- Cette feature inciterait les pros à prendre l'Ultimate

**Logique proposée** :
1. Bride crée/publie un wedding avec localisation
2. Edge Function détecte les pros Ultimate dans un rayon X km (ou même pays)
3. Push notification envoyée aux pros Ultimate concernés

**Questions à clarifier** :
- Rayon de notification ? (km ou pays entier ?)
- Fréquence max de notifs ? (éviter spam si 100 brides s'inscrivent le même jour)

**Complexité estimée** : M (1-2 jours)

---

### 7. Multi-sélection de spécialités (2 catégories par pro)

**Source** : WhatsApp

**Demande** : Permettre à un pro de sélectionner 2 spécialités au lieu d'une seule.

> "il faudrait presque enlever de l'app et du crm l'option photo/video et permettre à un user dans le dropdown de la selection de sa spé dans le crm quand il remplit sa fiche de choisir 2 spé, photographer et aussi filmmaker. Toutes les équipes le demandent"

**Exemples d'usage** :
- Photographer + Filmmaker (très demandé)
- Makeup Artist + Hair Dresser

**Impact** :
- Modifier structure DB (`category` string → array ?)
- Modifier UI onboarding CRM (Tom)
- Modifier filtres carte (App)
- Modifier affichage profil

**Complexité estimée** : M-L (peut impacter beaucoup de code)

**⚠️ Attention** : Changement structurel important, bien réfléchir avant d'implémenter.

---

### 8. Supprimer l'option "Photo/Video" du dropdown

**Source** : WhatsApp

**Demande** : Supprimer la catégorie combinée "Photo/Video" et plutôt permettre la multi-sélection (point 7).

> "il faudrait presque enlever de l'app et du crm l'option photo/video"

**Lié au point 7** - Si on permet 2 spécialités, cette catégorie hybride n'a plus de sens.

---

## 🔵 INFORMATIONS / CLARIFICATIONS

### 9. Centralisation des commandes magazines

**Source** : Mail "Important"

**Question de Thierry** : Où apparaissent les sélections photos pour les commandes de magazines ?

> "Les photos sélectionnées par la brides via l'app. Partagées ensuite aux guests et sélectionnées par les guests (toujours pour des commandes de magazines). Où apparaissent les selections ensuite ? Pour que je sois en mesure de mon côté de passer commande au fournisseur ?"

**Réponse** :
- Stockées dans Supabase : `magazine_selections` → `magazine_order_items`
- Paiements visibles dans Stripe Dashboard
- Admin Panel : Tom devra créer une vue dans le CRM

**Action** : Tom doit prévoir une page admin pour voir les commandes magazines avec :
- Liste des commandes avec statuts
- Photos sélectionnées + liens storage
- Adresse livraison
- Actions : Mark as Production, Mark as Shipped, Add Tracking

---

### 10. Demande de captures écran

**Source** : Mail "capture ecran"

**Demande** : Thierry veut des captures écran pour communiquer sur les réseaux.

> "As tu 2 captures écran ? marketplace robe ? photo guest ?"

**Action** : Fournir des maquettes/screenshots de :
- Interface marketplace robes
- Interface galerie photo guests

---

### 11. Call de validation fin de semaine

**Source** : WhatsApp

> "Si on peut faire un call avant fin de semaine pour tout fixer.. en fin de semaine avant de pusher l'app officiellement sur les stores on pourra checker avant que tout fonctionne parfaitement"

**Action** : Planifier un call avant la release

---

### 12. Photos de robes fournies par Thierry

**Source** : Mail "capture ecran"

> "voici photos de robes, les miennes si tu veux mettre"

**Action** : Utiliser ces photos pour les maquettes/tests marketplace

---

## 📋 PLAN D'ACTION RECOMMANDÉ

### Phase 1 : Quick Fixes (< 1 jour) - AVANT RELEASE

| # | Tâche | Temps | Owner |
|---|-------|-------|-------|
| 1 | Filtre prix min 0 pour catégories spécifiques | 1h | Léo |
| 2 | Option cacher prix Stationery | 30min-1h | Léo |
| 3 | Informer Tom des bugs CRM | 5min | Léo → Tom |

### Phase 2 : Mise à jour Epic-12 (< 0.5 jour)

| # | Tâche | Temps | Owner |
|---|-------|-------|-------|
| 4 | Documenter les 4 formats magazines dans Epic | 30min | Léo |
| 5 | Créer les 4 produits Stripe | 15min | Léo (MCP Stripe) |
| 6 | Ajuster S09 et S10 pour sélection format | Doc | Léo |

### Phase 3 : Décisions avec Thierry (Call)

| # | Sujet | Décision attendue |
|---|-------|-------------------|
| 7 | Notification Ultimate | Confirmer specs (rayon, fréquence) |
| 8 | Multi-spécialités | Confirmer si V1 ou V2 |
| 9 | Screenshots | Valider les maquettes |

---

## 📎 Sources

| Mail | Date | Objet principal |
|------|------|-----------------|
| "Modifs" | 03/02/2026 | Filtres prix, vidéos content creators |
| "prix magazine + filters" | 03/02/2026 | Prix magazines, filtres, notifs Ultimate |
| "Important" | 03/02/2026 | Centralisation commandes admin |
| "bugs" | 03/02/2026 | Bugs abonnements map |
| "Filtres" | 03/02/2026 | Cacher prix Stationery |
| "Fwd: Webhooks Stripe" | 02/02/2026 | Webhooks CRM en erreur |
| "capture ecran" | 03/02/2026 | Screenshots + photos robes |
| WhatsApp | 03/02/2026 | Multi-spécialités, call validation |

---

## ✅ Checklist avant release

- [ ] Quick fix : Filtre prix min 0
- [ ] Quick fix : Option cacher prix Stationery
- [ ] Tom : Bugs abonnements/webhooks CRM
- [ ] Call validation avec Thierry
- [ ] Screenshots fournis à Thierry

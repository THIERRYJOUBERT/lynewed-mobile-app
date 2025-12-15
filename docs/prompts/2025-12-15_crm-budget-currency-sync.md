# 🎯 MISSION: Ajouter la devise (currency) lors de la saisie du budget pro dans le CRM

## 👤 ASSISTANT SPECIALTY
Tu es un développeur **CRM Supabase** expert en:
- Supabase (database, edge functions, triggers)
- Synchronisation de données entre bases CRM et APP
- Gestion des devises et budgets

---

## 📚 CONTEXT

### Situation Actuelle
Dans l'application mobile LYNEWED, les **brides** peuvent filtrer les professionnels par **budget** et **devise**. Cependant, la colonne `currency` dans `professional_details` n'est **jamais remplie** quand un pro définit son budget via le CRM.

**Résultat:** Les pros n'apparaissent pas dans les résultats filtrés par budget car la conversion de devise échoue (currency = NULL).

### Ce qui a été fait côté APP (projet `hekyovgnovhfhmkpfrna`)
1. ✅ **RPC `search_map_bundle`** mise à jour pour utiliser `budget_min`, `budget_max`, `currency` (au lieu de `budget_min_eur`/`budget_max_eur`)
2. ✅ **Fonction `get_currency_rate(text)`** créée pour la conversion de devises côté SQL
3. ✅ **Edge function `sync-professional-to-app`** synchronise déjà `currency` depuis le CRM → APP
4. ✅ **Données existantes** corrigées manuellement (30 pros → EUR, 1 pro → USD basé sur leurs préférences)

### Ce qui manque côté CRM
Quand un pro saisit sa **range tarifaire** (budget_min/budget_max), il doit **aussi sélectionner la devise** et cette valeur doit être enregistrée dans `professional_details.currency`.

---

## 🔧 TÂCHE À RÉALISER

### 1. Modifier le formulaire de saisie du budget
Quand un pro définit son budget (budget_min, budget_max), ajouter un **sélecteur de devise** obligatoire.

**Devises supportées:**
```
EUR, USD, GBP, CHF, INR, AED, SAR, JPY, CNY, KRW, SGD, HKD, THB, MYR, IDR, PHP, VND, PKR, BDT, LKR, ILS, TRY, QAR, KWD, BHD, OMR, CAD, MXN, BRL, ARS, CLP, COP, PEN, SEK, NOK, DKK, PLN, CZK, HUF, RON, BGN, HRK, RUB, UAH, AUD, NZD, ZAR, EGP, NGN, KES, MAD, TND
```

### 2. Enregistrer la devise dans `professional_details.currency`
Lors de la sauvegarde du budget, mettre à jour:
- `budget_min` (int4)
- `budget_max` (int4)
- `currency` (text) ← **NOUVEAU - obligatoire si budget défini**

### 3. (Optionnel) Mettre à jour `budget_min_eur` et `budget_max_eur`
Pour ne pas casser d'éventuelles logiques résiduelles, tu peux aussi calculer et stocker les valeurs converties en EUR:

```sql
-- Taux de conversion (1 EUR = X devise)
-- Exemple: Si currency = 'USD' et budget_min = 1000
-- budget_min_eur = 1000 / 1.08 ≈ 926
```

**Taux de référence (Décembre 2024):**
| Devise | Taux (1 EUR =) |
|--------|----------------|
| EUR | 1.0 |
| USD | 1.08 |
| GBP | 0.86 |
| INR | 90.0 |
| CHF | 0.94 |
| ... | (voir fonction `get_currency_rate` ci-dessous) |

---

## 📁 RÉFÉRENCES

### Edge Function de sync (déjà en place)
L'edge function `sync-professional-to-app` sur le projet APP (`hekyovgnovhfhmkpfrna`) synchronise déjà le champ `currency`:

```typescript
// Dans sync-professional-to-app/index.ts (ligne ~101)
const dataToSync: ProfessionalData = {
  // ...
  budget_min: professionalData.budget_min,
  budget_max: professionalData.budget_max,
  currency: professionalData.currency,  // ← Déjà synchronisé
  // ...
};
```

**→ Pas besoin de modifier l'edge function.** Il suffit que le CRM remplisse `currency` correctement.

### Fonction de taux de change (côté APP)
```sql
-- Fonction get_currency_rate(text) sur hekyovgnovhfhmkpfrna
-- Retourne le taux de change depuis EUR

CREATE OR REPLACE FUNCTION public.get_currency_rate(p_currency text)
RETURNS numeric
LANGUAGE plpgsql
IMMUTABLE
AS $function$
BEGIN
  RETURN CASE UPPER(COALESCE(p_currency, 'EUR'))
    WHEN 'EUR' THEN 1.0
    WHEN 'USD' THEN 1.08
    WHEN 'GBP' THEN 0.86
    WHEN 'CHF' THEN 0.94
    WHEN 'INR' THEN 90.0
    WHEN 'AED' THEN 3.97
    WHEN 'SAR' THEN 4.05
    WHEN 'JPY' THEN 162.0
    WHEN 'CNY' THEN 7.80
    WHEN 'KRW' THEN 1420.0
    WHEN 'SGD' THEN 1.45
    WHEN 'HKD' THEN 8.45
    WHEN 'THB' THEN 38.0
    WHEN 'MYR' THEN 5.10
    WHEN 'IDR' THEN 17000.0
    WHEN 'PHP' THEN 60.0
    WHEN 'VND' THEN 26500.0
    WHEN 'PKR' THEN 302.0
    WHEN 'BDT' THEN 119.0
    WHEN 'LKR' THEN 350.0
    WHEN 'ILS' THEN 4.0
    WHEN 'TRY' THEN 35.0
    WHEN 'QAR' THEN 3.93
    WHEN 'KWD' THEN 0.33
    WHEN 'BHD' THEN 0.41
    WHEN 'OMR' THEN 0.42
    WHEN 'CAD' THEN 1.47
    WHEN 'MXN' THEN 18.5
    WHEN 'BRL' THEN 5.30
    WHEN 'ARS' THEN 980.0
    WHEN 'CLP' THEN 960.0
    WHEN 'COP' THEN 4300.0
    WHEN 'PEN' THEN 4.05
    WHEN 'SEK' THEN 11.3
    WHEN 'NOK' THEN 11.6
    WHEN 'DKK' THEN 7.46
    WHEN 'PLN' THEN 4.32
    WHEN 'CZK' THEN 25.3
    WHEN 'HUF' THEN 395.0
    WHEN 'RON' THEN 4.97
    WHEN 'BGN' THEN 1.96
    WHEN 'HRK' THEN 7.53
    WHEN 'RUB' THEN 98.0
    WHEN 'UAH' THEN 40.0
    WHEN 'AUD' THEN 1.65
    WHEN 'NZD' THEN 1.78
    WHEN 'ZAR' THEN 19.5
    WHEN 'EGP' THEN 33.5
    WHEN 'NGN' THEN 870.0
    WHEN 'KES' THEN 165.0
    WHEN 'MAD' THEN 10.8
    WHEN 'TND' THEN 3.35
    ELSE 1.0
  END;
END;
$function$;
```

---

## ✅ CRITÈRES D'ACCEPTATION

- [ ] Le formulaire de budget dans le CRM inclut un sélecteur de devise
- [ ] La devise est **obligatoire** si budget_min ou budget_max est défini
- [ ] La colonne `professional_details.currency` est mise à jour lors de la sauvegarde
- [ ] Après sync vers l'APP, les pros apparaissent correctement dans les filtres par budget
- [ ] (Optionnel) Les colonnes `budget_min_eur`/`budget_max_eur` sont calculées pour rétrocompatibilité

---

## 🧪 TEST

1. Dans le CRM, modifier un pro et définir:
   - `budget_min`: 5000
   - `budget_max`: 10000
   - `currency`: USD

2. Déclencher la sync vers l'APP

3. Dans l'APP mobile (côté bride):
   - Ouvrir la map
   - Appliquer un filtre budget (ex: 4000-12000 EUR)
   - Le pro avec budget USD devrait apparaître (5000 USD ≈ 4630 EUR)

---

## 📞 CONTACT

Pour toute question sur la logique côté APP, contacter l'équipe mobile.

**Projet APP Supabase:** `hekyovgnovhfhmkpfrna`

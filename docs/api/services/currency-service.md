# CurrencyService

**Location:** `lib/core/services/currency_service.dart`

---

## Description

Service de conversion de devises avec taux de change statiques. Utilisé pour afficher les budgets dans la devise préférée de l'utilisateur et configurer les sliders de budget.

---

## Singleton Pattern

```dart
// Accès via singleton
final service = CurrencyService();

// Ou via instance
CurrencyService.instance
```

---

## Méthodes Principales

### `convert()`

Convertit un montant d'une devise à une autre.

**Paramètres:**
- `amount` (double): Montant à convertir
- `from` (String): Code devise source (ex: 'EUR')
- `to` (String): Code devise cible (ex: 'USD')

**Retour:** `double?` - null si devise non supportée

**Exemple:**
```dart
final service = CurrencyService();

// EUR → USD
final usd = service.convert(1000, from: 'EUR', to: 'USD');
print(usd); // ~1080.0

// USD → INR
final inr = service.convert(100, from: 'USD', to: 'INR');
print(inr); // ~8333.0
```

---

### `convertRounded()`

Convertit et arrondit à un nombre "joli" pour l'affichage.

**Exemple:**
```dart
final service = CurrencyService();

// Arrondit selon la magnitude
final amount = service.convertRounded(15000, from: 'EUR', to: 'INR');
print(amount); // 1350000 (arrondi à 50K près pour grands montants)
```

---

### `formatBudgetRange()`

Formate une plage de budget avec conversion optionnelle.

**Paramètres:**
- `budgetMin`, `budgetMax` (int?): Plage de budget
- `sourceCurrency` (String): Devise originale
- `displayCurrency` (String): Devise d'affichage

**Retour:** `String` - ex: "1k - 5k €" ou "≈ 90k - 450k ₹"

**Exemple:**
```dart
final service = CurrencyService();

// Sans conversion
final display1 = service.formatBudgetRange(
  budgetMin: 1000,
  budgetMax: 5000,
  sourceCurrency: 'EUR',
  displayCurrency: 'EUR',
);
print(display1); // "1k - 5k €"

// Avec conversion
final display2 = service.formatBudgetRange(
  budgetMin: 1000,
  budgetMax: 5000,
  sourceCurrency: 'EUR',
  displayCurrency: 'INR',
);
print(display2); // "≈ 90k - 450k ₹"
```

---

### `getMaxBudgetForCurrency()`

Retourne le budget maximum pour le slider dans une devise.

**Exemple:**
```dart
final service = CurrencyService();

print(service.getMaxBudgetForCurrency('EUR')); // 50000.0
print(service.getMaxBudgetForCurrency('INR')); // 5000000.0
print(service.getMaxBudgetForCurrency('USD')); // 55000.0
```

---

### `getStepForCurrency()`

Retourne le pas du slider pour une devise.

**Exemple:**
```dart
final service = CurrencyService();

print(service.getStepForCurrency('EUR')); // 1000.0
print(service.getStepForCurrency('INR')); // 50000.0
```

---

### `formatBudgetValue()`

Formate une valeur pour les labels du slider.

**Exemple:**
```dart
final service = CurrencyService();

print(service.formatBudgetValue(1500000, 'INR')); // "1.5M ₹"
print(service.formatBudgetValue(25000, 'EUR')); // "25K €"
```

---

### `isSupported()`

Vérifie si une devise est supportée.

**Exemple:**
```dart
final service = CurrencyService();

print(service.isSupported('EUR')); // true
print(service.isSupported('XYZ')); // false
```

---

## Devises Supportées

40+ devises avec taux relatifs à EUR:

| Devise | Taux (1 EUR =) |
|--------|----------------|
| USD | 1.08 |
| GBP | 0.86 |
| INR | 90.0 |
| CHF | 0.94 |
| AED | 3.97 |
| JPY | 162.0 |
| ... | ... |

---

## Utilisation dans un Widget

```dart
class BudgetFilterWidget extends StatelessWidget {
  final String userCurrency;

  @override
  Widget build(BuildContext context) {
    final service = CurrencyService();
    final maxBudget = service.getMaxBudgetForCurrency(userCurrency);
    final step = service.getStepForCurrency(userCurrency);

    return RangeSlider(
      min: 0,
      max: maxBudget,
      divisions: (maxBudget / step).round(),
      values: RangeValues(minValue, maxValue),
      onChanged: (values) {
        // ...
      },
      labels: RangeLabels(
        service.formatBudgetValue(minValue, userCurrency),
        service.formatBudgetValue(maxValue, userCurrency),
      ),
    );
  }
}
```

---

## Notes

- Les taux sont statiques (décembre 2024)
- Pour production, intégrer une API de taux en temps réel
- EUR est la devise de référence interne
- Le préfixe "≈" indique une conversion approximative

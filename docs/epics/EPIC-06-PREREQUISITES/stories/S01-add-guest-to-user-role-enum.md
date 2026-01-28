# Story S01: Add 'guest' to userRole Enum

## Description
En tant que **systeme**, je veux **ajouter la valeur 'guest' a l'enum userRole dans Postgres et Dart**, afin de **permettre la creation de comptes invites pour les futures features Guest (APP-03, APP-04, APP-06)**.

## Criteres d'Acceptance (Gherkin)

- [ ] Given the current userRole enum contains only ['bride', 'professional'] When the migration add_guest_role is applied Then the userRole enum should contain ['bride', 'professional', 'guest'] And existing profiles should remain unchanged
- [ ] Given the UserRole enum in Dart When a user has role 'guest' in the database Then UserRole.fromString('guest') should return UserRole.guest And UserRole.guest.value should return 'guest'
- [ ] Given existing users with role 'bride' or 'professional' When the migration is applied Then all existing users should retain their original role And authentication should work normally
- [ ] Given the UserRole enum in Dart When testing serialization Then UserRole.guest.toJson() should return 'guest' And UserRole.fromJson('guest') should return UserRole.guest

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128000001_add_guest_role.sql`

### A Modifier
- `lib/features/auth/domain/entities/user_role.dart` - Add guest value to enum
- `test/features/auth/domain/entities/user_role_test.dart` - Add tests for guest role

## Notes Techniques

**Migration SQL:**
```sql
-- ATTENTION: Executer en periode de faible trafic (3h-5h)
ALTER TYPE "public"."userRole" ADD VALUE IF NOT EXISTS 'guest';

-- Verification
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum
    WHERE enumlabel = 'guest'
    AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'userRole')
  ) THEN
    RAISE EXCEPTION 'Migration failed: guest value not added to userRole enum';
  END IF;
END $$;
```

**Dart UserRole update:**
```dart
enum UserRole {
  bride,
  professional,
  admin,
  guest;  // NEW

  String get value => name;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => throw ArgumentError('Unknown role: $value'),
    );
  }
}
```

**IMPORTANT:** Le rollback d'un enum Postgres est complexe. Une fois la migration appliquee, il faut recreer le type complet pour supprimer une valeur. Verifier qu'aucun profile n'utilise 'guest' avant tout rollback.

## Definition of Done

- [ ] Migration SQL appliquee avec succes sur branche de dev Supabase
- [ ] Enum Postgres contient 'guest' (verifie via MCP)
- [ ] Entite Dart UserRole mise a jour avec guest
- [ ] Tests unitaires UserRole passent (fromString, value, serialization)
- [ ] `flutter analyze --fatal-infos` passe
- [ ] Aucune regression sur les roles existants (bride, professional)

## Estimation

**Points** : 2
**Complexite** : Faible
**Risque** : Moyen (migration enum irreversible)

## Dependances

- Aucune (story fondatrice)

## Stories Dependantes

- S02: Ajouter colonnes invitation a weddings
- S05: Ajouter colonnes invitation a wedding_guests

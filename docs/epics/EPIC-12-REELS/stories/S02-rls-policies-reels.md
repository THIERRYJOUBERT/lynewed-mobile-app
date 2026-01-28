# Story S02: Add RLS Policies for Reels Table

## Description
En tant que **developpeur backend**, je veux **ajouter les RLS policies pour la table reels**, afin de **securiser l'acces aux donnees selon le role de l'utilisateur (guest/bride)**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: RLS policies for reels table

  Scenario: User can manage own reels
    Given a user with user_id 'user-123'
    When they create a reel with user_id 'user-123'
    Then the insert should succeed
    And they should be able to SELECT that reel
    And they should be able to UPDATE that reel
    And they should be able to DELETE that reel

  Scenario: User cannot INSERT reel for another user
    Given a user with user_id 'user-123'
    When they try to INSERT a reel with user_id 'user-456'
    Then the insert should fail due to RLS policy

  Scenario: User cannot access other user's reels
    Given user-A has created a reel
    When user-B tries to SELECT that reel
    Then they should receive 0 rows

  Scenario: Bride can view all reels from her wedding
    Given a bride owns wedding 'wedding-456'
    And guest-A has created a reel for wedding-456
    When the bride queries reels for wedding-456
    Then she should see guest-A's reel
    And the reel should be read-only (SELECT only)

  Scenario: Bride cannot modify other user's reels
    Given a bride owns wedding 'wedding-456'
    And guest-A has created a reel 'reel-789' for wedding-456
    When the bride tries to UPDATE reel-789
    Then the update should fail (policy violation)
    When the bride tries to DELETE reel-789
    Then the delete should fail (policy violation)

  Scenario: Guest cannot view other guest's reels
    Given guest-A and guest-B are in the same wedding 'wedding-456'
    And guest-A has created a reel
    When guest-B queries reels for wedding-456
    Then guest-B should NOT see guest-A's reel

  Scenario: Service role bypasses RLS
    Given the service_role key is used
    When querying all reels
    Then all reels should be returned (for Edge Functions)
    And service_role can INSERT/UPDATE/DELETE any reel
```

## Fichiers Concernes

### A Creer
- `supabase/migrations/20260128001202_add_reels_rls_policies.sql`

### A Modifier
- None

## Notes Techniques

### Migration SQL
```sql
-- Migration: 20260128001202_add_reels_rls_policies
-- Description: Add RLS policies for reels table (Section D.4)
-- Epic: EPIC-12-REELS
-- Story: S02

-- Policy 1: User can manage their own reels (CRUD)
CREATE POLICY "User manages own reels"
ON reels FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Policy 2: Bride can view all reels from her wedding (SELECT only)
-- Note: This is additive with policy 1 (bride can manage own + view others)
CREATE POLICY "Bride views wedding reels"
ON reels FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM weddings w
    WHERE w.id = reels.wedding_id
    AND w.bride_profile_id = auth.uid()
  )
);

-- Comments
COMMENT ON POLICY "User manages own reels" ON reels IS
  'Users can CRUD their own reels only';
COMMENT ON POLICY "Bride views wedding reels" ON reels IS
  'Bride can view (not modify) all reels from her wedding (guests included)';
```

### Rollback SQL
```sql
-- Rollback: 20260128001202_add_reels_rls_policies

DROP POLICY IF EXISTS "Bride views wedding reels" ON reels;
DROP POLICY IF EXISTS "User manages own reels" ON reels;
```

### Policy Matrix

| User Type | Own Reels | Other Guest Reels | Bride's Reels |
|-----------|-----------|-------------------|---------------|
| Guest     | CRUD      | No access         | No access     |
| Bride     | CRUD      | SELECT only       | CRUD          |
| Service   | CRUD all  | CRUD all          | CRUD all      |

### Test Queries
```sql
-- Test 1: User can see own reels
SET request.jwt.claims TO '{"sub": "user-123"}';
SELECT * FROM reels WHERE user_id = 'user-123'; -- Should return rows

-- Test 2: User cannot see other's reels
SET request.jwt.claims TO '{"sub": "user-456"}';
SELECT * FROM reels WHERE user_id = 'user-123'; -- Should return 0 rows

-- Test 3: Bride can see all wedding reels
-- (requires bride_profile_id match in weddings table)
SET request.jwt.claims TO '{"sub": "bride-id"}';
SELECT * FROM reels WHERE wedding_id = 'wedding-456'; -- Should return all
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] Migration applied successfully
- [ ] "User manages own reels" policy created
- [ ] "Bride views wedding reels" policy created
- [ ] Test: User CRUD own reels works
- [ ] Test: User cannot access other's reels
- [ ] Test: Bride can SELECT all wedding reels
- [ ] Test: Bride cannot UPDATE/DELETE other's reels
- [ ] Test: Guest cannot see other guest's reels
- [ ] `flutter analyze --fatal-infos` passe (N/A - DB only)

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Moyen (security-critical)

## Dependances
- S01: Reels table must exist

## Stories Dependantes
- S06: Edge Function (uses service_role to bypass RLS)
- S10: Download feature (respects RLS)

# Story S05: CGVU Acceptance Modal + Table

## Description
En tant que **utilisateur**, je veux **accepter les conditions d'utilisation des reels avant ma premiere creation**, afin de **confirmer mon consentement legal pour l'utilisation de mes videos**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: CGVU acceptance modal for reels

  Scenario: First time creating a reel shows modal
    Given a user who has never created a reel
    When they tap "Create reel" after video selection
    Then the CGVU modal should appear
    And it should display 4 mandatory checkboxes

  Scenario: 4 checkboxes content
    Given the CGVU modal is displayed
    Then it should contain exactly 4 checkboxes:
      | # | Label (FR)                                                            |
      | 1 | J'accepte les conditions d'utilisation du service de generation       |
      | 2 | Je certifie etre proprietaire ou avoir les droits sur toutes les videos |
      | 3 | J'autorise Lynewed a generer un montage video a partir de mes contenus |
      | 4 | Je suis responsable de la diffusion du reel genere                    |

  Scenario: All checkboxes required
    Given the CGVU modal is displayed
    When user checks only 3 of 4 checkboxes
    Then "Continuer" button should remain disabled
    And button should show "Accepter tout pour continuer"

    When user checks all 4 checkboxes
    Then "Continuer" button should become enabled

  Scenario: Acceptance is logged with metadata
    Given the user has checked all 4 checkboxes
    When they tap "Continuer"
    Then a record should be inserted in cgvu_acceptances with:
      | field         | value                    |
      | user_id       | current user ID          |
      | cgvu_type     | 'reel'                   |
      | cgvu_version  | '1.0'                    |
      | ip_address    | user's IP address        |
      | user_agent    | app user agent string    |
      | device_info   | {os, version, device}    |
      | accepted_at   | current timestamp        |
    And the modal should close
    And reel creation should proceed

  Scenario: Modal not shown after acceptance
    Given a user who has accepted CGVU version '1.0' for reels
    When they create another reel
    Then the CGVU modal should NOT appear
    And they should proceed directly to processing

  Scenario: Modal shown again for new version
    Given CGVU version changes from '1.0' to '1.1'
    And a user who accepted version '1.0'
    When they create a new reel
    Then the CGVU modal should appear again
    And it should mention "Updated terms (version 1.1)"

  Scenario: Cancel modal
    Given the CGVU modal is displayed
    When user taps "Annuler" or closes modal
    Then the modal should close
    And no acceptance should be recorded
    And reel creation should be cancelled

  Scenario: Create cgvu_acceptances table if not exists
    Given the database
    When the migration is applied
    Then table cgvu_acceptances should exist
    And it should have unique constraint on (user_id, cgvu_type, cgvu_version)
```

## Fichiers Concernes

### A Creer
- `lib/features/reels/presentation/widgets/reel_cgvu_modal.dart`
- `lib/features/reels/domain/usecases/check_cgvu_acceptance.dart`
- `lib/features/reels/domain/usecases/record_cgvu_acceptance.dart`
- `lib/features/reels/data/repositories/cgvu_repository_impl.dart`
- `lib/features/reels/domain/repositories/cgvu_repository.dart`
- `lib/features/reels/domain/entities/cgvu_acceptance.dart`
- `lib/core/services/device_info_service.dart` - Get device info for logging
- `supabase/migrations/20260128001205_create_cgvu_acceptances.sql`
- `test/features/reels/presentation/widgets/reel_cgvu_modal_test.dart`
- `test/features/reels/domain/usecases/check_cgvu_acceptance_test.dart`

### A Modifier
- `lib/features/reels/presentation/pages/video_selection_page.dart` - Add CGVU check before create

## Notes Techniques

### Current CGVU Version
```dart
// lib/features/reels/domain/usecases/check_cgvu_acceptance.dart

/// Current version of reel CGVU
/// IMPORTANT: Increment when CGVU text changes
const String CURRENT_REEL_CGVU_VERSION = '1.0';

class CheckCgvuAcceptanceUseCase {
  final CgvuRepository _repository;

  CheckCgvuAcceptanceUseCase(this._repository);

  /// Returns true if user needs to accept CGVU (not accepted OR version mismatch)
  Future<bool> needsAcceptance(String userId) async {
    final acceptance = await _repository.getLatestAcceptance(
      userId: userId,
      cgvuType: 'reel',
    );

    // No acceptance found = needs to accept
    if (acceptance == null) return true;

    // Version mismatch = needs to re-accept
    if (acceptance.cgvuVersion != CURRENT_REEL_CGVU_VERSION) {
      return true;
    }

    return false;
  }
}
```

### Record Acceptance Use Case
```dart
// lib/features/reels/domain/usecases/record_cgvu_acceptance.dart

class RecordCgvuAcceptanceUseCase {
  final CgvuRepository _repository;
  final DeviceInfoService _deviceInfoService;

  RecordCgvuAcceptanceUseCase(this._repository, this._deviceInfoService);

  Future<void> execute(String userId) async {
    final deviceInfo = await _deviceInfoService.getDeviceInfo();
    final ipAddress = await _deviceInfoService.getIpAddress();

    await _repository.recordAcceptance(
      CgvuAcceptance(
        userId: userId,
        cgvuType: 'reel',
        cgvuVersion: CURRENT_REEL_CGVU_VERSION,
        ipAddress: ipAddress,
        userAgent: deviceInfo.userAgent,
        deviceInfo: {
          'os': deviceInfo.os,
          'version': deviceInfo.osVersion,
          'device': deviceInfo.deviceModel,
          'app_version': deviceInfo.appVersion,
        },
      ),
    );
  }
}
```

### CGVU Modal Widget
```dart
// lib/features/reels/presentation/widgets/reel_cgvu_modal.dart

class ReelCgvuModal extends StatefulWidget {
  final VoidCallback onAccepted;
  final VoidCallback onCancelled;

  const ReelCgvuModal({
    required this.onAccepted,
    required this.onCancelled,
  });

  @override
  State<ReelCgvuModal> createState() => _ReelCgvuModalState();
}

class _ReelCgvuModalState extends State<ReelCgvuModal> {
  final _checks = [false, false, false, false];

  static const _checkboxTexts = [
    "J'accepte les conditions d'utilisation du service de generation de reels",
    "Je certifie etre proprietaire ou avoir les droits necessaires sur toutes les videos selectionnees",
    "J'autorise Lynewed a generer un montage video automatise a partir de mes contenus",
    "Je suis seul(e) responsable de la diffusion du reel genere sur les reseaux sociaux ou autres plateformes",
  ];

  bool get _allChecked => _checks.every((c) => c);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Conditions d\'utilisation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Avant de creer votre reel, veuillez accepter les conditions suivantes :',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (index) => CheckboxListTile(
              value: _checks[index],
              onChanged: (v) => setState(() => _checks[index] = v ?? false),
              title: Text(_checkboxTexts[index]),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancelled,
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _allChecked ? widget.onAccepted : null,
          child: Text(_allChecked ? 'Continuer' : 'Accepter tout pour continuer'),
        ),
      ],
    );
  }
}
```

### Migration SQL
```sql
-- Migration: 20260128001205_create_cgvu_acceptances
-- Description: Create shared CGVU acceptances table
-- Epic: EPIC-12-REELS
-- Story: S05

CREATE TABLE IF NOT EXISTS cgvu_acceptances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  cgvu_type VARCHAR(50) NOT NULL,
  cgvu_version VARCHAR(20) NOT NULL,
  ip_address VARCHAR(50),
  user_agent TEXT,
  device_info JSONB,
  accepted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- One acceptance per type per version per user
  UNIQUE(user_id, cgvu_type, cgvu_version)
);

-- Index for checking acceptance
CREATE INDEX idx_cgvu_acceptances_user_type
  ON cgvu_acceptances(user_id, cgvu_type);

-- Enable RLS
ALTER TABLE cgvu_acceptances ENABLE ROW LEVEL SECURITY;

-- Policy: User can view own acceptances
CREATE POLICY "User views own acceptances"
ON cgvu_acceptances FOR SELECT
TO authenticated
USING (user_id = auth.uid());

-- Policy: User can insert own acceptances
CREATE POLICY "User creates own acceptances"
ON cgvu_acceptances FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

-- Comments
COMMENT ON TABLE cgvu_acceptances IS 'CGVU acceptance audit log - shared across features (reels, marketplace)';
COMMENT ON COLUMN cgvu_acceptances.cgvu_type IS 'Feature type: reel, marketplace, etc.';
COMMENT ON COLUMN cgvu_acceptances.cgvu_version IS 'Version of CGVU accepted (e.g., 1.0, 1.1)';
```

### Rollback SQL
```sql
-- Rollback: 20260128001205_create_cgvu_acceptances

DROP POLICY IF EXISTS "User creates own acceptances" ON cgvu_acceptances;
DROP POLICY IF EXISTS "User views own acceptances" ON cgvu_acceptances;
DROP INDEX IF EXISTS idx_cgvu_acceptances_user_type;
DROP TABLE IF EXISTS cgvu_acceptances;
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] Tests unitaires CheckCgvuAcceptanceUseCase
- [ ] Tests unitaires RecordCgvuAcceptanceUseCase
- [ ] Tests widget ReelCgvuModal
- [ ] cgvu_acceptances table created
- [ ] RLS policies applied
- [ ] Modal displays 4 checkboxes correctly
- [ ] All checkboxes required for continue
- [ ] Acceptance recorded with metadata
- [ ] Version tracking works (new version triggers modal)
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 3
**Complexite** : Faible
**Risque** : Faible (legal compliance)

## Dependances
- None (independent story)

## Stories Dependantes
- S06: Edge Function (checks CGVU acceptance before processing)

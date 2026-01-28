# Story S08: Implement CGVU marketplace seller

## Description
En tant que vendeur, je veux accepter les CGVU avant de publier ma premiere annonce, afin de comprendre mes obligations legales et que l'acceptation soit tracee.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a seller who has never accepted marketplace CGVU When they try to publish a listing Then CGVU modal should be displayed And checkbox should be disabled until scrolled to bottom And publish should be blocked until accepted
- [ ] Given a seller accepting CGVU When they check the box and confirm Then cgvu_acceptances should contain user_id, cgvu_type='marketplace_seller', cgvu_version='1.0', ip_address, user_agent, device_info, accepted_at
- [ ] Given a seller who already accepted CGVU When they publish a new listing Then no CGVU modal should appear And listing should be published directly
- [ ] Given the CGVU modal When user has not scrolled to bottom Then the checkbox should be visually disabled (greyed out)
- [ ] Given the CGVU modal When user scrolls to the bottom Then the checkbox should become enabled

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/widgets/cgvu_seller_modal.dart` - Modal widget
- `lib/features/marketplace/data/datasources/cgvu_remote_datasource.dart` - API calls
- `lib/features/marketplace/data/repositories/cgvu_repository_impl.dart` - Repository
- `lib/features/marketplace/domain/repositories/cgvu_repository.dart` - Interface
- `lib/features/marketplace/domain/usecases/check_cgvu_acceptance.dart` - Use case
- `lib/features/marketplace/domain/usecases/accept_cgvu.dart` - Use case
- `supabase/migrations/20260128100008_create_cgvu_acceptances.sql` - Table (si pas deja dans EPIC-11)

### A Modifier
- `lib/features/marketplace/presentation/pages/create_listing_page.dart` - Integrate CGVU check

## Notes Techniques

### Table cgvu_acceptances
```sql
CREATE TABLE cgvu_acceptances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) NOT NULL,
  cgvu_type VARCHAR(50) NOT NULL,  -- 'marketplace_seller', 'marketplace_buyer'
  cgvu_version VARCHAR(20) NOT NULL,  -- '1.0'
  ip_address VARCHAR(50),
  user_agent TEXT,
  device_info JSONB,
  accepted_at TIMESTAMP DEFAULT NOW() NOT NULL,

  UNIQUE(user_id, cgvu_type, cgvu_version)
);
```

### Edge Function pour logging IP
```typescript
// Edge function to log CGVU acceptance with IP
Deno.serve(async (req) => {
  const { user_id, cgvu_type, cgvu_version, user_agent, device_info } = await req.json();

  const ip_address = req.headers.get('x-forwarded-for') ||
                     req.headers.get('x-real-ip') ||
                     'unknown';

  await supabase.from('cgvu_acceptances').insert({
    user_id, cgvu_type, cgvu_version, ip_address, user_agent, device_info
  });

  return new Response(JSON.stringify({ success: true }));
});
```

### Flutter Widget Pattern
```dart
class CgvuSellerModal extends StatefulWidget {
  final VoidCallback onAccepted;

  // Use ScrollController to detect scroll to bottom
  // Enable checkbox only when _hasScrolledToBottom = true
  // Call Edge Function on accept with device info
}
```

### Device Info a collecter
```dart
final deviceInfo = {
  'platform': Platform.operatingSystem,
  'version': Platform.operatingSystemVersion,
  'appVersion': packageInfo.version,
  'buildNumber': packageInfo.buildNumber,
};
```

## Definition of Done
- [ ] Table cgvu_acceptances creee (ou verifiee si EPIC-11)
- [ ] Modal avec scroll detection
- [ ] Checkbox disabled until scrolled
- [ ] Logging complet (IP, user_agent, device)
- [ ] Cache local pour eviter checks repetes
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (compliance legale)

## Dependances
- Aucune dependance technique bloquante
- Texte CGVU doit etre fourni par equipe legale

## Stories Dependantes
- S09 (CGVU buyer - meme table)
- S14 (create listing form - integre check CGVU)

# Story S11: Edge Function FedEx Rate API

## Description
En tant qu'acheteuse, je veux voir les frais de port en temps reel, afin de connaitre le cout total avant d'acheter.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a listing in New York And a buyer address in Los Angeles When calculating shipping rate Then response should include service_type, rate_cents, estimated_days for multiple options (Ground, Express)
- [ ] Given a listing in Paris, France And a buyer address in New York, USA When calculating shipping rate Then response should include international options And customs fees should be indicated
- [ ] Given an invalid destination address When calculating shipping rate Then error should indicate invalid address And suggest corrections if available
- [ ] Given valid from/to addresses When calling the Rate API Then both addresses should be validated first via Address Validation API
- [ ] Given a successful rate calculation Then rates should be returned sorted by price (cheapest first)

## Fichiers Concernes

### A Creer
- `supabase/functions/fedex-calculate-rate/index.ts` - Edge Function principale
- `supabase/functions/_shared/fedex-client.ts` - Client FedEx reutilisable
- `lib/features/marketplace/data/datasources/fedex_remote_datasource.dart` - API calls
- `lib/features/marketplace/domain/entities/shipping_rate.dart` - Entity
- `lib/features/marketplace/domain/usecases/calculate_shipping_rate.dart` - Use case

### A Modifier
- Aucun

## Notes Techniques

### Prerequisites (AVANT implementation)

1. **Compte FedEx Developer** : https://developer.fedex.com/
2. **APIs requises** : Address Validation, Rate
3. **Credentials** a stocker dans Supabase Secrets:
   - `FEDEX_CLIENT_ID`
   - `FEDEX_CLIENT_SECRET`
   - `FEDEX_ACCOUNT_NUMBER`
   - `FEDEX_ENV` ('sandbox' ou 'production')

### Edge Function Structure
```typescript
import { FedExClient } from '../_shared/fedex-client.ts';

const fedex = new FedExClient({
  clientId: Deno.env.get('FEDEX_CLIENT_ID')!,
  clientSecret: Deno.env.get('FEDEX_CLIENT_SECRET')!,
  accountNumber: Deno.env.get('FEDEX_ACCOUNT_NUMBER')!,
  environment: Deno.env.get('FEDEX_ENV') || 'sandbox',
});

Deno.serve(async (req) => {
  const { from_address, to_address, package_weight_kg, package_dimensions_cm } = await req.json();

  // 1. Validate addresses
  const [fromValidation, toValidation] = await Promise.all([
    fedex.validateAddress(from_address),
    fedex.validateAddress(to_address),
  ]);

  if (!fromValidation.valid || !toValidation.valid) {
    return new Response(JSON.stringify({
      error: 'invalid_address',
      from_suggestions: fromValidation.suggestions,
      to_suggestions: toValidation.suggestions,
    }), { status: 400 });
  }

  // 2. Get rates
  const rates = await fedex.getRates({
    shipper: from_address,
    recipient: to_address,
    packageDetails: { weight, dimensions },
  });

  // 3. Format response
  return new Response(JSON.stringify({
    rates: rates.map(r => ({
      service_type: r.serviceType,
      service_name: r.serviceName,
      rate_cents: Math.round(r.totalCharges * 100),
      currency: 'USD',
      estimated_delivery: r.deliveryTimestamp,
      estimated_days: r.transitTime,
    }))
  }));
});
```

### FedEx Client (shared)
```typescript
// supabase/functions/_shared/fedex-client.ts
export class FedExClient {
  private accessToken: string | null = null;
  private tokenExpiry: Date | null = null;

  async getToken(): Promise<string> {
    // OAuth2 client credentials flow
  }

  async validateAddress(address: Address): Promise<ValidationResult> {
    // POST /address/v1/addresses/resolve
  }

  async getRates(params: RateParams): Promise<Rate[]> {
    // POST /rate/v1/rates/quotes
  }
}
```

### Address Format
```typescript
interface Address {
  streetLines: string[];
  city: string;
  stateOrProvinceCode?: string;
  postalCode: string;
  countryCode: string; // ISO 2-letter
}
```

### Package Details (defaults for wedding dress)
```typescript
// Default package for wedding dress
const defaultPackage = {
  weight: { units: 'KG', value: 3 },
  dimensions: {
    units: 'CM',
    length: 60,
    width: 40,
    height: 20,
  },
};
```

## Definition of Done
- [ ] FedEx credentials configures dans Supabase
- [ ] Edge Function deployee
- [ ] Address Validation fonctionne
- [ ] Rate API retourne tarifs corrects
- [ ] Tests en mode sandbox
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (API externe, quotas)

## Dependances
- Configuration FedEx Developer Account
- Supabase Secrets configures

## Stories Dependantes
- S12 (FedEx Ship API - utilise meme client)
- S20 (flow achat - calcul frais port)

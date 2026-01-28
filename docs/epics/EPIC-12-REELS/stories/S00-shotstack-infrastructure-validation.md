# Story S00: Validate Shotstack Infrastructure

## Description
En tant que **developpeur**, je veux **valider que l'infrastructure Shotstack est operationnelle**, afin de **garantir que le video processing fonctionnera en production avant de commencer le developpement**.

## Criteres d'Acceptance (Gherkin)

```gherkin
Feature: Shotstack Infrastructure Validation

  Scenario: API key is configured
    Given the Supabase Edge Function environment
    When I check for SHOTSTACK_API_KEY
    Then the variable should be set
    And it should be a valid API key format

  Scenario: Shotstack API is reachable
    Given a valid SHOTSTACK_API_KEY
    When I make a test request to Shotstack API
    Then the response should be successful (200)
    And the API version should be "v1"

  Scenario: Test render completes successfully
    Given the Shotstack API connection is working
    When I submit a minimal test render (2 video clips, 5s each)
    Then the render should be queued
    And the render should complete within 2 minutes
    And the output URL should be accessible

  Scenario: Cost estimation is accurate
    Given a test render of 1 minute
    When the render completes
    Then the cost should be approximately $0.05
    And this should be logged for validation

  Scenario: Staging vs Production environment
    Given SHOTSTACK_ENV variable
    When set to "stage"
    Then renders should use sandbox (free, watermarked)
    When set to "v1"
    Then renders should use production (paid, clean)

  Scenario: Error handling for invalid API key
    Given an invalid SHOTSTACK_API_KEY
    When I make a request to Shotstack
    Then I should receive a 401 Unauthorized
    And the error message should be clear
```

## Fichiers Concernes

### A Creer
- `supabase/functions/_shared/shotstack_client.ts` - Shared Shotstack client
- `supabase/functions/test-shotstack/index.ts` - Test Edge Function
- `docs/infrastructure/SHOTSTACK_SETUP.md` - Setup documentation

### A Modifier
- `.env.example` - Add SHOTSTACK_API_KEY and SHOTSTACK_ENV variables
- `supabase/config.toml` - Add environment variables section

## Notes Techniques

### Shotstack Client Configuration
```typescript
// supabase/functions/_shared/shotstack_client.ts

interface ShotstackConfig {
  apiKey: string;
  environment: 'stage' | 'v1';
}

const SHOTSTACK_BASE_URL = {
  stage: 'https://api.shotstack.io/stage',
  v1: 'https://api.shotstack.io/v1',
};

export function createShotstackClient(config: ShotstackConfig) {
  const baseUrl = SHOTSTACK_BASE_URL[config.environment];

  return {
    async submitRender(edit: ShotstackEdit): Promise<RenderResponse> {
      const response = await fetch(`${baseUrl}/render`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': config.apiKey,
        },
        body: JSON.stringify(edit),
      });

      if (!response.ok) {
        throw new Error(`Shotstack error: ${response.status}`);
      }

      return response.json();
    },

    async getRenderStatus(renderId: string): Promise<RenderStatus> {
      const response = await fetch(`${baseUrl}/render/${renderId}`, {
        headers: { 'x-api-key': config.apiKey },
      });
      return response.json();
    },
  };
}
```

### Test Render Payload
```typescript
const testEdit = {
  timeline: {
    tracks: [{
      clips: [
        { asset: { type: 'video', src: 'https://...' }, start: 0, length: 5 },
        { asset: { type: 'video', src: 'https://...' }, start: 5, length: 5 },
      ],
    }],
  },
  output: {
    format: 'mp4',
    resolution: 'sd', // Use SD for test to reduce cost
  },
};
```

### Environment Variables
```bash
# Required in Supabase Edge Function secrets
SHOTSTACK_API_KEY=your_api_key_here
SHOTSTACK_ENV=stage  # 'stage' for testing, 'v1' for production
```

## Definition of Done
- [ ] Criteres d'acceptance valides
- [ ] SHOTSTACK_API_KEY configured in Supabase secrets
- [ ] Test Edge Function deployed and working
- [ ] Test render successful (stage environment)
- [ ] Cost validated (~$0.05/min)
- [ ] Documentation written (SHOTSTACK_SETUP.md)
- [ ] `flutter analyze --fatal-infos` passe (N/A - backend only)

## Estimation
**Points** : 2
**Complexite** : Faible
**Risque** : Moyen (external dependency)

## Dependances
- None (first story)

## Stories Dependantes
- S01: Create reels table (can start in parallel)
- S06: Edge Function generate-reel (BLOCKED until this completes)

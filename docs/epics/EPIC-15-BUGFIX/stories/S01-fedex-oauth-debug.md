# S01 - Debug + Fix FedEx OAuth

> **Epic** : EPIC-15-BUGFIX
> **Domaine** : INFRA
> **Complexite** : S (Small) - 2 story points
> **Source** : BUG-02
> **Dependances** : Aucune
> **Bloque** : S06 (frais dynamiques), S07 (tracking cron)
> **Status** : DONE

---

## User Story

**As a** marketplace seller,
**I want** FedEx OAuth to work correctly so the shipping label Edge Function authenticates successfully,
**So that** I can generate FedEx shipping labels for sold items and ship them to buyers.

---

## Contexte Technique

### Probleme

L'appel FedEx OAuth retourne `NOT.AUTHORIZED.ERROR`. La generation d'etiquette et le calcul de frais echouent systematiquement.

### Causes probables (par ordre de probabilite)

1. **Secrets Supabase non configures** : Les credentials existent dans `.env.fedex` (local) mais n'ont probablement jamais ete poussees dans les secrets Supabase Edge Functions.
2. **Credentials sandbox expirees** : Les credentials sandbox FedEx expirent periodiquement et doivent etre regenerees sur le Developer Portal.
3. **Compte sandbox desactive** : Le projet FedEx "Lynewed Marketplace Mobile" a ete suspendu ou supprime.

### Edge Functions concernees

| Function | Fichier client | Utilise OAuth |
|----------|---------------|---------------|
| `fedex-create-shipment` | `supabase/functions/fedex-create-shipment/fedex-client.ts` | Oui (L14-22) |
| `fedex-calculate-rate` | `supabase/functions/fedex-calculate-rate/fedex-client.ts` | Oui (L84-107) |
| `fedex-track-shipment` | `supabase/functions/fedex-track-shipment/fedex-client.ts` | Oui (L12-18) |
| `fedex-cancel-shipment` | `supabase/functions/fedex-cancel-shipment/index.ts` (inline) | Oui (L28-46) |

### Credentials de reference (`.env.fedex`)

Fichier local `.env.fedex` (racine projet, gitignored):

```
FEDEX_CLIENT_ID=l7915167202dbc400c9c338d7bbf591bc0
FEDEX_CLIENT_SECRET=3be7c39d9ab1402eba0a867430edfcf6
FEDEX_ACCOUNT_NUMBER=740561073
FEDEX_API_URL=https://apis-sandbox.fedex.com
```

**Mapping vers secrets Supabase** (utilisés par Edge Functions):

| Fichier local `.env.fedex` | Secret Supabase | Note |
|-----------------------------|----------------|------|
| `FEDEX_CLIENT_ID` | `FEDEX_CLIENT_ID` | Identique |
| `FEDEX_CLIENT_SECRET` | `FEDEX_CLIENT_SECRET` | Identique |
| `FEDEX_ACCOUNT_NUMBER` | `FEDEX_ACCOUNT_NUMBER` | Identique |
| `FEDEX_API_URL` | `FEDEX_ENV` | Transformation : `sandbox` ou `production` (pas URL) |

**IMPORTANT** : Les Edge Functions utilisent `FEDEX_ENV` (valeur `sandbox` ou `production`) et construisent l'URL à partir de cette valeur. Le fichier local `.env.fedex` contient l'URL complète pour référence uniquement.

### Architecture OAuth actuelle (3 copies)

Chaque Edge Function embarque sa propre copie de `FedExClient` avec la meme methode `getToken()` :

```typescript
private async getToken(): Promise<string> {
  // Cache token si non expire (55 min)
  const response = await fetch(`${this.baseUrl}/oauth/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'client_credentials',
      client_id: this.config.clientId,
      client_secret: this.config.clientSecret,
    }),
  });
  if (!response.ok) throw new Error(`FedEx OAuth failed: ${await response.text()}`);
  // ...
}
```

**Observation** : L'error handling OAuth est brut (`throw new Error` avec le texte brut de la reponse). Les erreurs FedEx sont des JSON structures avec `errors[].code` et `errors[].message` qui ne sont pas parses.

---

## Criteres d'Acceptation

### AC-1 : Diagnostic des secrets Supabase

```gherkin
Given les Edge Functions FedEx sont deployees sur Supabase
When je verifie les secrets Supabase via Supabase CLI (commande: supabase secrets list)
Then les secrets FEDEX_CLIENT_ID, FEDEX_CLIENT_SECRET, FEDEX_ACCOUNT_NUMBER, et FEDEX_ENV sont presents
And FEDEX_ENV vaut "sandbox" (pas l'URL complete)
And les autres valeurs correspondent aux credentials sandbox documentees dans .env.fedex
```

**Note technique** : Il n'existe pas de commande MCP pour lister les secrets Supabase. La seule méthode fiable est `supabase secrets list --project-ref hekyovgnovhfhmkpfrna` (nécessite Supabase CLI installé et authentifié).

### AC-2 : OAuth token obtenu avec succes

```gherkin
Given les secrets FedEx sont correctement configures dans Supabase
When l'Edge Function fait un POST vers https://apis-sandbox.fedex.com/oauth/token
  avec grant_type=client_credentials et les bonnes credentials
Then la reponse HTTP est 200
And le body contient un access_token non-vide
And le body contient un expires_in superieur a 0
```

### AC-3 : Generation d'etiquette fonctionnelle

```gherkin
Given l'OAuth FedEx fonctionne (AC-2 valide)
And une transaction marketplace existe en statut 'paid' avec des adresses valides
When le vendeur appelle fedex-create-shipment avec le transaction_id et un service_type
Then la reponse contient un tracking_number non-vide
And la reponse contient un label_url pointant vers un PDF dans Supabase Storage
And la transaction passe en statut 'label_created'
```

### AC-4 : Error handling ameliore

```gherkin
Given les credentials FedEx sont incorrectes ou expirees
When l'Edge Function tente l'OAuth
Then l'erreur retournee contient le code FedEx specifique (ex: NOT.AUTHORIZED.ERROR)
And l'erreur retournee contient le message descriptif FedEx
And le log console inclut le body complet de la reponse FedEx pour debug
And la reponse HTTP au client est un JSON structure { error: string, code?: string }
```

### AC-5 : Calcul de tarif fonctionnel

```gherkin
Given l'OAuth FedEx fonctionne (AC-2 valide)
When j'appelle fedex-calculate-rate avec des adresses US valides et un poids
Then la reponse contient au moins un tarif avec service_type, rate_cents, et currency
And le tarif est un nombre positif en cents
```

---

## Plan d'Implementation

### Phase 1 : Tester credentials locales (15 min) ⚠️ NOUVEAU - FAIRE EN PREMIER

1. **Tester OAuth avec credentials locales** (curl direct sandbox) :
   ```bash
   curl -X POST https://apis-sandbox.fedex.com/oauth/token \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "grant_type=client_credentials&client_id=l7915167202dbc400c9c338d7bbf591bc0&client_secret=3be7c39d9ab1402eba0a867430edfcf6"
   ```

   **Attendu** : HTTP 200 + `{"access_token":"...", "expires_in":3600}`

2. **Si 401/403** : Credentials expirées ou invalides → Regenerer sur https://developer.fedex.com/api/en-us/catalog.html

3. **Si 200** : Credentials valides → Passer à Phase 2

**IMPORTANT** : Ne JAMAIS configurer les secrets Supabase AVANT d'avoir testé les credentials locales. Si le test curl échoue, aucune configuration Supabase ne résoudra le problème.

### Phase 2 : Diagnostic secrets Supabase (15 min)

4. **Verifier les secrets Supabase** via CLI (pas MCP) :
   ```bash
   # Authentification (une fois)
   supabase login

   # Lister les secrets du projet
   supabase secrets list --project-ref hekyovgnovhfhmkpfrna
   ```

   **Attendu** : 4 secrets présents (FEDEX_CLIENT_ID, FEDEX_CLIENT_SECRET, FEDEX_ACCOUNT_NUMBER, FEDEX_ENV)

5. **Vérifier les logs Edge Functions** pour voir les erreurs OAuth :
   ```
   # Via Supabase MCP
   get_logs(type: 'edge-function', search: 'FedEx OAuth failed')
   ```

### Phase 3 : Fix secrets si absents (15 min)

6. **Configurer les secrets Supabase** (si absents ou invalides) :
   ```bash
   # Via Supabase CLI (pas MCP - aucun outil MCP ne permet de set les secrets)
   supabase secrets set FEDEX_CLIENT_ID=l7915167202dbc400c9c338d7bbf591bc0 --project-ref hekyovgnovhfhmkpfrna
   supabase secrets set FEDEX_CLIENT_SECRET=3be7c39d9ab1402eba0a867430edfcf6 --project-ref hekyovgnovhfhmkpfrna
   supabase secrets set FEDEX_ACCOUNT_NUMBER=740561073 --project-ref hekyovgnovhfhmkpfrna
   supabase secrets set FEDEX_ENV=sandbox --project-ref hekyovgnovhfhmkpfrna
   ```

   **IMPORTANT** : Utiliser `FEDEX_ENV=sandbox` (valeur `sandbox`), pas `FEDEX_API_URL=https://...`

### Phase 4 : Ameliorer error handling (30 min)

7. **Parser les erreurs FedEx** dans `getToken()` des 4 Edge Functions :
   - `fedex-create-shipment/fedex-client.ts`
   - `fedex-calculate-rate/fedex-client.ts`
   - `fedex-track-shipment/fedex-client.ts`
   - `fedex-cancel-shipment/index.ts` (inline FedExClient L28-46)

   **Modifications** :
   - Tenter `response.json()` au lieu de `response.text()`
   - Extraire `errors[0].code` et `errors[0].message`
   - Logger le body complet pour debug
   - Retourner un message structure au client

### Phase 5 : Validation (15 min)

8. **Redeployer** les 4 Edge Functions via Supabase MCP :
   ```
   deploy_edge_function(name: 'fedex-create-shipment')
   deploy_edge_function(name: 'fedex-calculate-rate')
   deploy_edge_function(name: 'fedex-track-shipment')
   deploy_edge_function(name: 'fedex-cancel-shipment')
   ```

9. **Tester** chaque function via invocation directe

---

## Commandes de Diagnostic

### 1. Test OAuth direct (FAIRE EN PREMIER)

```bash
# Tester credentials locales AVANT toute configuration Supabase
curl -s -X POST https://apis-sandbox.fedex.com/oauth/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=l7915167202dbc400c9c338d7bbf591bc0&client_secret=3be7c39d9ab1402eba0a867430edfcf6" \
  | python3 -m json.tool
```

**Attendu si valide** :
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "scope": "..."
}
```

### 2. Verifier les secrets Supabase (CLI - pas MCP)

```bash
# Lister les secrets (nécessite supabase login)
supabase secrets list --project-ref hekyovgnovhfhmkpfrna
```

**IMPORTANT** : Il n'existe pas de commande MCP pour lister ou définir les secrets. Seul le CLI Supabase fonctionne.

### 3. Verifier les logs Edge Functions (MCP)

```
mcp__supabase__get_logs:
  project_id: hekyovgnovhfhmkpfrna
  type: edge-function
  search: "FedEx OAuth failed"
```

### 4. Lister les Edge Functions deployees (MCP)

```
mcp__supabase__list_edge_functions:
  project_id: hekyovgnovhfhmkpfrna
```

---

## Fichiers Impactes

| Fichier | Modification |
|---------|-------------|
| `supabase/functions/fedex-create-shipment/fedex-client.ts` | Error handling OAuth ameliore (methode `getToken()`) |
| `supabase/functions/fedex-calculate-rate/fedex-client.ts` | Error handling OAuth ameliore (methode `getToken()`) |
| `supabase/functions/fedex-track-shipment/fedex-client.ts` | Error handling OAuth ameliore (methode `getToken()`) |
| `supabase/functions/fedex-cancel-shipment/index.ts` | Error handling OAuth ameliore (inline FedExClient L28-46) |

**Scope strict** : Uniquement les fichiers contenant `getToken()` (3 `fedex-client.ts` + 1 inline dans `fedex-cancel-shipment/index.ts`). Aucune modification du code Flutter.

---

## Tests Requis

### Test 1 : OAuth sandbox valide

```
Action : curl POST /oauth/token avec credentials sandbox
Expected : HTTP 200 + body { access_token: "...", expires_in: 3600, ... }
```

### Test 2 : OAuth credentials invalides

```
Action : curl POST /oauth/token avec client_secret incorrect
Expected : HTTP 401 + body { errors: [{ code: "NOT.AUTHORIZED.ERROR", message: "..." }] }
```

### Test 3 : Edge Function fedex-create-shipment

```
Action : Invoquer via Supabase avec un body de test (adresses US)
Expected : Reponse 200 avec tracking_number + label_url (ou erreur structuree claire si pas de transaction)
```

### Test 4 : Edge Function fedex-calculate-rate

```
Action : Invoquer avec from_address NYC, to_address LA, category dress
Expected : Reponse 200 avec au moins 1 rate en USD
```

### Test 5 : Error handling ameliore

```
Action : Desactiver temporairement le secret FEDEX_CLIENT_SECRET, invoquer une function
Expected : Reponse 500 avec { error: "FedEx OAuth failed: NOT.AUTHORIZED.ERROR - ...", code: "NOT.AUTHORIZED.ERROR" }
```

---

## Definition of Done

- [ ] **PRE-REQUIS** : Les credentials locales `.env.fedex` sont testées et valides (curl OAuth retourne HTTP 200)
- [ ] Les 4 secrets FedEx sont configurés dans Supabase via CLI (`FEDEX_CLIENT_ID`, `FEDEX_CLIENT_SECRET`, `FEDEX_ACCOUNT_NUMBER`, `FEDEX_ENV=sandbox`)
- [ ] `supabase secrets list --project-ref hekyovgnovhfhmkpfrna` confirme la présence des 4 secrets
- [ ] L'error handling des 4 Edge Functions parse les erreurs FedEx JSON (3 `fedex-client.ts` + 1 inline `fedex-cancel-shipment/index.ts`)
- [ ] Les 4 Edge Functions sont redeployées (`fedex-create-shipment`, `fedex-calculate-rate`, `fedex-track-shipment`, `fedex-cancel-shipment`)
- [ ] `fedex-create-shipment` génère une étiquette en sandbox (ou erreur claire si pas de transaction test)
- [ ] `fedex-calculate-rate` retourne des tarifs en sandbox
- [ ] Les logs Edge Functions montrent des messages d'erreur structurés (plus de `throw brut`)
- [ ] Zero regression sur le code Flutter existant

---

## Validation INVEST

| Critere | Validation |
|---------|-----------|
| **Independent** | Aucune dependance. Peut etre developpe en premier. |
| **Negotiable** | L'error handling (AC-4) peut etre simplifie si le diagnostic (AC-1/AC-2) suffit. |
| **Valuable** | Debloque S06 (frais dynamiques) et S07 (tracking). Sans cette story, tout le shipping marketplace est casse. |
| **Estimable** | 2 SP. Diagnostic clair, 3 fichiers a modifier, scope reduit a OAuth + error handling. |
| **Small** | ~1.5h de travail (30 min diagnostic + 15 min secrets + 30 min error handling + 15 min validation). |
| **Testable** | 5 tests concrets definis. OAuth testable en curl, Edge Functions testables via Supabase MCP. |

---

## Notes pour le Developpeur

1. **TOUJOURS commencer par le test curl** (Phase 1) AVANT toute configuration Supabase. Si les credentials locales échouent, aucune configuration Supabase ne résoudra le problème.
2. **Ne pas régénérer les credentials** sans avoir testé les actuelles d'abord. Les credentials dans `.env.fedex` sont peut-être valides mais simplement absentes de Supabase.
3. **Il n'existe pas de commande MCP pour gérer les secrets Supabase**. Seul le CLI fonctionne (`supabase secrets list/set`). Ne pas chercher d'outil MCP pour cette tâche.
4. **Les 3 fichiers `fedex-client.ts` + 1 inline sont des copies** avec des variations mineures. Le fix error handling doit être appliqué aux 4 de manière cohérente.
5. **FEDEX_ENV vs FEDEX_API_URL** : Le fichier local `.env.fedex` contient `FEDEX_API_URL` (URL complète), mais les Edge Functions utilisent `FEDEX_ENV` (valeur `sandbox` ou `production`) et construisent l'URL dynamiquement. Le secret Supabase doit être `FEDEX_ENV=sandbox` (pas l'URL).
6. **fedex-cancel-shipment** a une architecture différente : le `FedExClient` est inline dans `index.ts` (L14-69) au lieu d'un fichier séparé `fedex-client.ts`. Le fix error handling doit être appliqué à cet endroit.

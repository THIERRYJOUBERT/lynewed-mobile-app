# Story S06: Creer Edge Function send-wedding-invitation (Resend)

## Description
En tant que systeme, je veux pouvoir envoyer des emails d'invitation aux guests via une Edge Function, afin de permettre aux mariees d'inviter leurs proches.

## Criteres d'Acceptance (Gherkin)

- [ ] Given a guest with email "pierre@example.com" When the Edge Function send-wedding-invitation is called with guest_id and wedding_id Then an email should be sent to "pierre@example.com" And the email subject should be "Vous etes invite(e) au mariage de Marie !" And the email body should contain the invite code "ABCD1234" And the email should contain a QR code image And the email should contain a deep link "https://lynewed.app/join/ABCD1234" And wedding_guests.status should be updated to 'invited' And wedding_guests.invited_at should be set to current timestamp
- [ ] Given the invitation email is generated Then it should contain: Header "Vous etes invite(e) au mariage de Marie !", Instructions "Telechargez l'app Lynewed et rejoignez le mariage.", Code "Code mariage : ABCD1234", QR Code encoding the deep link, Button "Rejoindre le mariage" linking to deep link, Footer "Ce code expire dans 30 jours"
- [ ] Given the QR code is generated When scanning the QR code Then it should resolve to "https://lynewed.app/join/ABCD1234"
- [ ] Given a guest with invalid email "not-an-email" When the Edge Function is called Then it should return an error "invalid_email" And no email should be sent And wedding_guests.status should remain unchanged
- [ ] Given Resend rate limit has been exceeded When the Edge Function is called Then it should return an error "rate_limited" And the response should include retry_after timestamp
- [ ] Given a non-existent guest_id When the Edge Function is called Then it should return an error "guest_not_found"
- [ ] Given a guest already has status='invited' When the Edge Function is called again Then a new email should be sent (re-invitation) And invited_at should be updated to current timestamp

## Fichiers Concernes

### A Creer
- `supabase/functions/send-wedding-invitation/index.ts`
- `supabase/functions/send-wedding-invitation/email_template.ts`

### A Modifier
- Aucun fichier Flutter (Edge Function backend uniquement)

## Notes Techniques

### Edge Function Complete

```typescript
// supabase/functions/send-wedding-invitation/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { Resend } from "npm:resend@2.0.0";
import QRCode from "npm:qrcode@1.5.3";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Verify JWT
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const { guest_id, wedding_id } = await req.json();

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Get guest and wedding info
    const { data: guest, error: guestError } = await supabase
      .from('wedding_guests')
      .select(`
        id,
        name,
        email,
        status,
        weddings!inner(
          id,
          invite_code,
          invite_code_expires_at,
          bride_profile_id,
          profiles!bride_profile_id(first_name)
        )
      `)
      .eq('id', guest_id)
      .eq('wedding_id', wedding_id)
      .single();

    if (guestError || !guest) {
      return new Response(
        JSON.stringify({ error: 'guest_not_found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Validate email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!guest.email || !emailRegex.test(guest.email)) {
      return new Response(
        JSON.stringify({ error: 'invalid_email' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const inviteCode = guest.weddings.invite_code;
    const brideName = guest.weddings.profiles.first_name;
    const deepLink = `https://lynewed.app/join/${inviteCode}`;
    const expiresAt = new Date(guest.weddings.invite_code_expires_at);

    // Generate QR code as data URL
    const qrCodeDataUrl = await QRCode.toDataURL(deepLink, {
      width: 200,
      margin: 2,
      color: {
        dark: '#000000',
        light: '#FFFFFF',
      },
    });

    // Initialize Resend
    const resendApiKey = Deno.env.get('RESEND_API_KEY');
    if (!resendApiKey) {
      return new Response(
        JSON.stringify({ error: 'email_service_not_configured' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const resend = new Resend(resendApiKey);

    // Send email
    const { data: emailData, error: emailError } = await resend.emails.send({
      from: 'Lynewed <noreply@lynewed.app>',
      to: guest.email,
      subject: `Vous etes invite(e) au mariage de ${brideName} !`,
      html: generateEmailTemplate({
        brideName,
        guestName: guest.name || 'Invite',
        inviteCode,
        deepLink,
        qrCodeDataUrl,
        expiresAt,
      }),
    });

    if (emailError) {
      // Check if rate limited
      if (emailError.message?.includes('rate limit')) {
        return new Response(
          JSON.stringify({
            error: 'rate_limited',
            retry_after: Math.floor(Date.now() / 1000) + 60,
          }),
          { status: 429, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }

      return new Response(
        JSON.stringify({ error: 'email_service_error', details: emailError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Update guest status
    await supabase
      .from('wedding_guests')
      .update({
        status: 'invited',
        invited_at: new Date().toISOString(),
      })
      .eq('id', guest_id);

    return new Response(
      JSON.stringify({
        success: true,
        email_id: emailData?.id,
        status: 'invited',
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ error: 'internal_error', details: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

function generateEmailTemplate(params: {
  brideName: string;
  guestName: string;
  inviteCode: string;
  deepLink: string;
  qrCodeDataUrl: string;
  expiresAt: Date;
}): string {
  const { brideName, guestName, inviteCode, deepLink, qrCodeDataUrl, expiresAt } = params;
  const formattedDate = expiresAt.toLocaleDateString('fr-FR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });

  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px;">
  <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">

    <!-- Header -->
    <div style="background: linear-gradient(135deg, #D4A574 0%, #C4956C 100%); padding: 40px 30px; text-align: center;">
      <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 600;">
        Vous etes invite(e) au mariage de ${brideName} !
      </h1>
    </div>

    <!-- Content -->
    <div style="padding: 40px 30px;">
      <p style="color: #333333; font-size: 16px; line-height: 1.6; margin: 0 0 20px;">
        Bonjour ${guestName},
      </p>

      <p style="color: #333333; font-size: 16px; line-height: 1.6; margin: 0 0 30px;">
        Telechargez l'app Lynewed et rejoignez le mariage pour partager vos photos et discuter avec les autres invites.
      </p>

      <!-- Code -->
      <div style="background-color: #f8f8f8; border-radius: 12px; padding: 24px; text-align: center; margin-bottom: 30px;">
        <p style="color: #666666; font-size: 14px; margin: 0 0 12px;">Code mariage :</p>
        <p style="color: #D4A574; font-size: 32px; font-weight: bold; letter-spacing: 6px; margin: 0;">
          ${inviteCode}
        </p>
      </div>

      <!-- QR Code -->
      <div style="text-align: center; margin-bottom: 30px;">
        <img src="${qrCodeDataUrl}" alt="QR Code" style="width: 200px; height: 200px; border-radius: 8px;" />
        <p style="color: #666666; font-size: 12px; margin: 12px 0 0;">
          Scannez ce QR code avec votre telephone
        </p>
      </div>

      <!-- CTA Button -->
      <div style="text-align: center; margin-bottom: 30px;">
        <a href="${deepLink}" style="display: inline-block; background: linear-gradient(135deg, #D4A574 0%, #C4956C 100%); color: #ffffff; text-decoration: none; padding: 16px 40px; border-radius: 30px; font-size: 16px; font-weight: 600; box-shadow: 0 4px 12px rgba(212, 165, 116, 0.4);">
          Rejoindre le mariage
        </a>
      </div>

      <!-- Footer note -->
      <p style="color: #999999; font-size: 12px; text-align: center; margin: 0;">
        Ce code expire le ${formattedDate}.
      </p>
    </div>

    <!-- Footer -->
    <div style="background-color: #f8f8f8; padding: 20px 30px; text-align: center; border-top: 1px solid #eeeeee;">
      <p style="color: #999999; font-size: 12px; margin: 0;">
        Envoye avec amour par Lynewed
      </p>
    </div>

  </div>
</body>
</html>
  `;
}
```

### Deploiement

```bash
# Deployer l'Edge Function
supabase functions deploy send-wedding-invitation

# Variables d'environnement requises
supabase secrets set RESEND_API_KEY=re_xxxxxxxxxxxx
```

### Test local

```bash
# Tester en local
supabase functions serve send-wedding-invitation --env-file .env.local

# Appel test
curl -X POST http://localhost:54321/functions/v1/send-wedding-invitation \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"guest_id": "uuid", "wedding_id": "uuid"}'
```

## Definition of Done

- [ ] Criteres valides
- [ ] Tests manuels (envoi email reel avec Resend)
- [ ] Edge Function deployee sur Supabase
- [ ] RESEND_API_KEY configure dans secrets
- [ ] Template email teste sur differents clients mail (Gmail, Outlook, Apple Mail)
- [ ] QR code scannable et fonctionnel
- [ ] Rate limiting gere correctement
- [ ] Logs disponibles dans Supabase dashboard

## Estimation

**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (integration Resend, deliverabilite emails)

## Dependances

- EPIC-06 complete (colonnes invite_code, invited_at)
- Compte Resend configure avec domaine lynewed.app verifie

## Stories Dependantes

- S07 (UI envoi invitation - appelle cette Edge Function)

## Notes Resend

### Configuration domaine

Pour que les emails arrivent correctement (pas en spam):
1. Verifier le domaine lynewed.app dans Resend dashboard
2. Configurer les enregistrements DNS (SPF, DKIM, DMARC)
3. Utiliser une adresse from: coherente (noreply@lynewed.app)

### Rate limits Resend

- Plan gratuit: 100 emails/jour, 1 email/seconde
- Plan Pro: 50,000 emails/mois, 10 emails/seconde
- Gerer les erreurs 429 avec retry

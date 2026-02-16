import { serve } from "https://deno.land/std@0.190.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { Resend } from "https://esm.sh/resend@4.0.0";
import QRCode from "https://esm.sh/qrcode@1.5.3";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(
  body: Record<string, unknown>,
  status: number
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
}

function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function generateEmailHtml(
  guestName: string,
  brideName: string,
  inviteCode: string,
  qrCodeDataUrl: string,
  expiresAt: string | null
): string {
  const formattedDate = expiresAt
    ? new Date(expiresAt).toLocaleDateString("en-US", {
        year: "numeric",
        month: "long",
        day: "numeric",
      })
    : null;

  const expiryLine = formattedDate
    ? `<p style="color: #999999; font-size: 12px; text-align: center; margin: 0;">
        This code expires on ${formattedDate}.
      </p>`
    : "";

  return `<!DOCTYPE html>
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
        You're invited to ${brideName}'s Wedding!
      </h1>
    </div>

    <!-- Content -->
    <div style="padding: 40px 30px;">
      <p style="color: #333333; font-size: 16px; line-height: 1.6; margin: 0 0 20px;">
        Hello ${guestName},
      </p>

      <p style="color: #333333; font-size: 16px; line-height: 1.6; margin: 0 0 30px;">
        Download the Lynewed app and join the wedding to share your photos
        and chat with other guests.
      </p>

      <!-- Code -->
      <div style="background-color: #f8f8f8; border-radius: 12px; padding: 24px; text-align: center; margin-bottom: 30px;">
        <p style="color: #666666; font-size: 14px; margin: 0 0 12px;">Wedding code:</p>
        <p style="color: #D4A574; font-size: 32px; font-weight: bold; letter-spacing: 6px; margin: 0;">
          ${inviteCode}
        </p>
      </div>

      <!-- QR Code -->
      <div style="text-align: center; margin-bottom: 30px;">
        <img src="${qrCodeDataUrl}" alt="QR Code" style="width: 200px; height: 200px; border-radius: 8px;" />
        <p style="color: #666666; font-size: 12px; margin: 12px 0 0;">
          Scan this QR code with your phone
        </p>
      </div>

      <!-- CTA Button -->
      <div style="text-align: center; margin-bottom: 30px;">
        <a href="https://lynewed.com/join/${inviteCode}" style="display: inline-block; background: linear-gradient(135deg, #D4A574 0%, #C4956C 100%); color: #ffffff; text-decoration: none; padding: 16px 40px; border-radius: 30px; font-size: 16px; font-weight: 600; box-shadow: 0 4px 12px rgba(212, 165, 116, 0.4);">
          Join the Wedding
        </a>
      </div>

      <!-- Footer note -->
      ${expiryLine}
    </div>

    <!-- Footer -->
    <div style="background-color: #f8f8f8; padding: 20px 30px; text-align: center; border-top: 1px solid #eeeeee;">
      <p style="color: #999999; font-size: 12px; margin: 0;">
        Sent with love by Lynewed
      </p>
    </div>

  </div>
</body>
</html>`;
}

const handler = async (req: Request): Promise<Response> => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // --- AC-9: Check RESEND_API_KEY is configured ---
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    if (!resendApiKey) {
      console.error("RESEND_API_KEY not configured");
      return jsonResponse({ error: "email_service_not_configured" }, 500);
    }
    const resend = new Resend(resendApiKey);

    // --- AC-10: Authentication required ---
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "unauthorized" }, 401);
    }

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: { Authorization: authHeader },
        },
      }
    );

    const {
      data: { user },
    } = await supabaseClient.auth.getUser();
    if (!user) {
      return jsonResponse({ error: "unauthorized" }, 401);
    }

    // --- Parse request body ---
    const { guest_id, wedding_id } = await req.json();
    if (!guest_id || !wedding_id) {
      return jsonResponse({ error: "missing_parameters" }, 400);
    }

    // --- AC-6: Query DB for guest + wedding + bride profile ---
    const serviceClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const { data: guest, error: queryError } = await serviceClient
      .from("wedding_guests")
      .select(
        `
        email,
        name,
        status,
        wedding_id,
        weddings!inner (
          id,
          invite_code,
          invite_code_expires_at,
          bride_profile_id,
          profiles!bride_profile_id (
            first_name
          )
        )
      `
      )
      .eq("id", guest_id)
      .eq("wedding_id", wedding_id)
      .single();

    if (queryError || !guest) {
      console.error("Guest query error:", queryError?.message);
      return jsonResponse({ error: "guest_not_found" }, 404);
    }

    // Extract wedding data from join
    const wedding = guest.weddings as Record<string, unknown>;
    if (!wedding) {
      return jsonResponse({ error: "guest_not_found" }, 404);
    }

    // --- AC-5: Validate email ---
    const guestEmail = guest.email as string | null;
    if (!guestEmail || !isValidEmail(guestEmail)) {
      return jsonResponse({ error: "invalid_email" }, 400);
    }

    // --- AC-2: Validate invite_code (anti-null CRITICAL) ---
    const inviteCode = (wedding.invite_code as string | null)?.trim();
    if (!inviteCode || inviteCode.length === 0) {
      console.error(
        "Invalid invite_code for wedding:",
        wedding_id,
        "value:",
        wedding.invite_code
      );
      return jsonResponse({ error: "invalid_invite_code" }, 400);
    }

    // --- AC-4: Generate QR code ---
    const deepLink = `https://lynewed.com/join/${inviteCode}`;
    const qrCodeDataUrl = await QRCode.toDataURL(deepLink, {
      width: 200,
      margin: 2,
      color: {
        dark: "#000000",
        light: "#FFFFFF",
      },
    });

    // --- AC-3: Generate English email template ---
    const guestName = (guest.name as string) || "Guest";
    const brideProfile = wedding.profiles as Record<string, unknown> | null;
    const brideName = (brideProfile?.first_name as string) || "the bride";
    const expiresAt = wedding.invite_code_expires_at as string | null;

    const html = generateEmailHtml(
      guestName,
      brideName,
      inviteCode,
      qrCodeDataUrl,
      expiresAt
    );

    // --- AC-1: Send email via Resend ---
    const subject = `You're invited to ${brideName}'s Wedding!`;

    console.log(`Sending invitation to ${guestEmail} for wedding ${wedding_id}`);

    let emailResponse;
    try {
      emailResponse = await resend.emails.send({
        from: "Lynewed <noreply@lynewed.com>",
        to: [guestEmail],
        subject,
        html,
      });
    } catch (sendError: unknown) {
      // --- AC-8: Rate limiting ---
      const err = sendError as { statusCode?: number; message?: string };
      if (err.statusCode === 429) {
        return jsonResponse(
          {
            error: "rate_limited",
            retry_after: new Date(
              Date.now() + 60 * 1000
            ).toISOString(),
          },
          429
        );
      }
      console.error("Resend error:", err.message);
      return jsonResponse({ error: "email_service_error" }, 500);
    }

    // --- AC-1 + AC-7: Update guest status ---
    const { error: updateError } = await serviceClient
      .from("wedding_guests")
      .update({
        status: "invited",
        invited_at: new Date().toISOString(),
      })
      .eq("id", guest_id);

    if (updateError) {
      console.error("Failed to update guest status:", updateError.message);
      // Email was sent, so we still return success but log the error
    }

    // --- AC-1: Success response ---
    return jsonResponse(
      {
        success: true,
        email_id: emailResponse?.data?.id ?? null,
        status: "invited",
      },
      200
    );
  } catch (error: unknown) {
    const err = error as { message?: string };
    console.error("Error in send-wedding-invitation:", err.message);
    return jsonResponse({ error: "internal_error" }, 500);
  }
};

serve(handler);

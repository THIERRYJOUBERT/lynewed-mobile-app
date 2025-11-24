import { serve } from "https://deno.land/std@0.190.0/http/server.ts";
import { Resend } from "https://esm.sh/resend@4.0.0";
const resend = new Resend(Deno.env.get("RESEND_API_KEY"));
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type"
};
// Template HTML pour la réponse au ticket
const generateTicketReplyHTML = (recipientName, ticketTitle, replyContent)=>{
  return `<!DOCTYPE html>
      <html lang="en" style="margin:0;padding:0;background:#f8f8f8;font-family:Helvetica,Arial,sans-serif;color:#111;">
        <head>
          <meta charset="UTF-8">
          <title>Réponse à votre ticket support - Lynewed</title>
        </head>
        <body style="margin:0;padding:0;background:#f8f8f8;">
          <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background:#f8f8f8;padding:40px 0;">
            <tr>
              <td align="center">
                <table role="presentation" width="600" cellspacing="0" cellpadding="0" border="0" style="background:#fff;border-radius:0px;box-shadow:0 8px 24px rgba(0,0,0,0.05);overflow:hidden;">
                  <!-- Header -->
                  <tr>
                    <td style="background:#000;color:#fff;text-align:center;padding:40px;">
                      <h1 style="margin:0;font-size:28px;font-weight:600;letter-spacing:0.5px;">
                        LYNEWED
                      </h1>
                      <p style="margin:8px 0 0;font-size:14px;opacity:0.9;">Support Client</p>
                    </td>
                  </tr>
                  
                  <!-- Greeting -->
                  <tr>
                    <td style="padding:40px 40px 20px;color:#333;font-family:Helvetica,Arial,sans-serif;">
                      <p style="margin:0;font-size:16px;">Bonjour ${recipientName || 'cher utilisateur'},</p>
                    </td>
                  </tr>
                  
                  <!-- Ticket Reference -->
                  <tr>
                    <td style="padding:0 40px 20px;">
                      <div style="background:#f5f5f5;padding:16px;border-left:4px solid #000;border-radius:4px;">
                        <p style="margin:0;font-size:12px;text-transform:uppercase;color:#666;letter-spacing:0.5px;">Votre demande :</p>
                        <p style="margin:8px 0 0;font-size:14px;color:#333;font-weight:600;">${ticketTitle}</p>
                      </div>
                    </td>
                  </tr>
                  
                  <!-- Reply Content -->
                  <tr>
                    <td style="padding:0 40px 40px;color:#333;font-family:Georgia, serif; font-size:16px; line-height:1.6;">
                      ${replyContent}
                    </td>
                  </tr>
                  
                  <!-- Closing -->
                  <tr>
                    <td style="padding:0 40px 40px;color:#333;font-family:Helvetica,Arial,sans-serif;">
                      <p style="margin:0;font-size:14px;">Cordialement,</p>
                      <p style="margin:4px 0 0;font-size:14px;font-weight:600;">L'équipe Lynewed</p>
                    </td>
                  </tr>
                  
                  <!-- CTA Section -->
                  <tr>
                    <td style="padding:0 40px 40px; text-align:center;">
                      <a href="https://lynewed.com" style="display:block; max-width: 300px; margin: 0 auto; background:#000;color:#fff;text-decoration:none;padding:14px 32px;border-radius:8px;font-weight:600;font-size:16px;font-family:Helvetica,Arial,sans-serif;">
                        Retour sur Lynewed
                      </a>
                    </td>
                  </tr>
                  
                  <!-- Footer -->
                  <tr>
                    <td style="background:#fafafa;text-align:center;padding:32px 24px;color:#888;font-size:12px;line-height:1.8;">
                      <p style="margin:0 0 16px;">© 2025 Lynewed. All rights reserved.</p>
                      <p style="margin:0 0 16px;font-style:italic;color:#666;">The wedding industry in your pocket.</p>
                      <p style="margin:0 0 16px;">
                        <a href="https://apps.apple.com/us/app/lynewed/id6753673667" style="color:#666;text-decoration:underline;">Download the App</a>
                        <span style="color:#ddd; margin: 0 8px;">|</span>
                        <a href="https://crm.lynewed.com/auth" style="color:#666;text-decoration:underline;">CRM Access for Professionals</a>
                      </p>
                      <p style="margin:0;color:#999;font-size:11px;">
                        Cet email est une réponse à votre demande de support. Si vous n'êtes pas à l'origine de cette demande, veuillez ignorer ce message.
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </body>
      </html>`;
};
const handler = async (req)=>{
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: corsHeaders
    });
  }
  try {
    const { ticketId, recipientEmail, recipientName, ticketTitle, replyContent } = await req.json();
    console.log("🎫 Processing ticket reply");
    console.log(`Ticket ID: ${ticketId}`);
    console.log(`Recipient: ${recipientEmail}`);
    // Validation
    if (!recipientEmail || !replyContent || !ticketTitle) {
      throw new Error("Missing required fields: recipientEmail, ticketTitle, or replyContent");
    }
    // Générer le HTML de l'email
    const htmlContent = generateTicketReplyHTML(recipientName, ticketTitle, replyContent);
    // Envoyer via Resend
    const emailResponse = await resend.emails.send({
      from: "Lynewed Support <noreply@lynewed.com>",
      to: [
        recipientEmail
      ],
      subject: `Re: ${ticketTitle}`,
      html: htmlContent
    });
    console.log("✅ Email sent successfully:", emailResponse);
    return new Response(JSON.stringify({
      success: true,
      emailId: emailResponse.data?.id,
      message: "Ticket reply sent successfully"
    }), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders
      }
    });
  } catch (error) {
    console.error("❌ Error in send-ticket-reply function:", error);
    return new Response(JSON.stringify({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error"
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders
      }
    });
  }
};
serve(handler);

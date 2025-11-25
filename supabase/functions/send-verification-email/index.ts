import { serve } from "https://deno.land/std@0.190.0/http/server.ts";
import { Resend } from "https://esm.sh/resend@4.0.0";
const resend = new Resend(Deno.env.get("RESEND_API_KEY"));
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type"
};
const handler = async (req)=>{
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: corsHeaders
    });
  }
  try {
    const { email, firstName, lastName, status } = await req.json();
    console.log(`Sending ${status} email to ${email} (${firstName} ${lastName})`);
    let subject;
    let html;
    if (status === "verified") {
      subject = "✅ Votre profil a été validé !";
      html = `
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
              .container { max-width: 600px; margin: 0 auto; padding: 20px; }
              .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
              .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
              .button { display: inline-block; padding: 15px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; font-weight: bold; }
              .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>🎉 Félicitations ${firstName} !</h1>
              </div>
              <div class="content">
                <p>Bonjour ${firstName} ${lastName},</p>
                
                <p><strong>Excellente nouvelle !</strong> Votre profil a été validé par notre équipe. 🎊</p>
                
                <p>Vous pouvez maintenant accéder à toutes les fonctionnalités de notre plateforme et choisir le plan d'abonnement qui correspond le mieux à vos besoins.</p>
                
                <div style="text-align: center;">
                  <a href="https://pjcorrkwafjskmzmimon.supabase.co" class="button">
                    🚀 Choisir mon plan d'abonnement
                  </a>
                </div>
                
                <p>Merci de votre confiance et bienvenue parmi nos professionnels ! 💼</p>
                
                <p>À très bientôt,<br>
                <strong>L'équipe WedApp</strong></p>
              </div>
              <div class="footer">
                <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
              </div>
            </div>
          </body>
        </html>
      `;
    } else {
      subject = "❌ Mise à jour de votre demande d'inscription";
      html = `
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
              .container { max-width: 600px; margin: 0 auto; padding: 20px; }
              .header { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
              .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
              .button { display: inline-block; padding: 15px 30px; background: #667eea; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; font-weight: bold; }
              .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>Mise à jour de votre demande</h1>
              </div>
              <div class="content">
                <p>Bonjour ${firstName} ${lastName},</p>
                
                <p>Nous avons examiné votre demande d'inscription et malheureusement, nous ne pouvons pas l'approuver pour le moment.</p>
                
                <p><strong>Pourquoi ?</strong><br>
                Pour garantir la qualité de notre plateforme, nous sélectionnons attentivement nos professionnels partenaires. Il est possible que votre profil ne corresponde pas encore à nos critères actuels.</p>
                
                <p>Si vous pensez qu'il s'agit d'une erreur ou souhaitez plus d'informations, n'hésitez pas à nous contacter.</p>
                
                <div style="text-align: center;">
                  <a href="mailto:contact@wedapp.com" class="button">
                    📧 Nous contacter
                  </a>
                </div>
                
                <p>Merci de votre compréhension.<br>
                <strong>L'équipe WedApp</strong></p>
              </div>
              <div class="footer">
                <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
              </div>
            </div>
          </body>
        </html>
      `;
    }
    const emailResponse = await resend.emails.send({
      from: "WedApp <noreply@lynewed.com>",
      to: [
        email
      ],
      subject: subject,
      html: html
    });
    console.log("Email sent successfully:", emailResponse);
    return new Response(JSON.stringify({
      success: true,
      data: emailResponse
    }), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders
      }
    });
  } catch (error) {
    console.error("Error in send-verification-email function:", error);
    return new Response(JSON.stringify({
      error: error.message
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

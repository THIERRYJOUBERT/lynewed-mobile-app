// Stripe Connect Return Handler
// Redirects from Stripe Connect onboarding back to the Lynewed app
// This function is called by Stripe after the user completes/exits onboarding
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const success = url.searchParams.get("success");
  const error = url.searchParams.get("error");

  // Build the deep link back to the app
  let deepLink = "lynewed://stripe-connect-return";
  if (success) {
    deepLink += `?success=${success}`;
  } else if (error) {
    deepLink += `?error=${error}`;
  }

  // Serve an HTML page that redirects to the app via deep link
  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Lynewed - Payment Setup</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
      background-color: #FAF9F6;
      color: #2C2C2C;
    }
    .container {
      text-align: center;
      padding: 40px 20px;
      max-width: 400px;
    }
    h1 { font-size: 24px; margin-bottom: 16px; }
    p { font-size: 16px; color: #666; margin-bottom: 24px; }
    .btn {
      display: inline-block;
      background-color: #C4A882;
      color: white;
      text-decoration: none;
      padding: 14px 32px;
      border-radius: 8px;
      font-size: 16px;
      font-weight: 600;
    }
    .btn:hover { opacity: 0.9; }
  </style>
</head>
<body>
  <div class="container">
    <h1>${success ? 'Setup Complete!' : 'Payment Setup'}</h1>
    <p>${success
      ? 'Your Stripe account setup is progressing. Return to the app to check your status.'
      : 'Please return to the app to continue your payment setup.'
    }</p>
    <a href="${deepLink}" class="btn">Return to Lynewed</a>
  </div>
  <script>
    // Auto-redirect to the app after a short delay
    setTimeout(function() {
      window.location.href = '${deepLink}';
    }, 1500);
  </script>
</body>
</html>`;

  return new Response(html, {
    status: 200,
    headers: { "Content-Type": "text/html; charset=utf-8" },
  });
});

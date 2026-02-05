// EPIC-12 S10: Create Magazine Checkout
// Creates a Stripe Checkout session for magazine orders
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import Stripe from "npm:stripe@17.7.0";
import { createClient } from "jsr:@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!);

interface CheckoutRequest {
  wedding_id: string;
  bride_user_id: string;
  magazine_format: string;
  magazine_price_cents: number;
  photo_count: number;
  magazine_title: string;
  magazine_date?: string;
  cover_photo_id?: string;
  success_url: string;
  cancel_url: string;
}

const formatNames: Record<string, string> = {
  guest_edition: "GUEST EDITION",
  iconic: "ICONIC",
  memory: "MEMORY",
  collector: "COLLECTOR",
};

const formatSizes: Record<string, string> = {
  guest_edition: "21x30cm",
  iconic: "21x30cm",
  memory: "21x30cm",
  collector: "25x32cm",
};

// SECURITY: Magazine format prices - SERVER-SIDE source of truth
// Never trust client-side prices - always use these values
const FORMAT_PRICES: Record<string, number> = {
  guest_edition: 2900, // $29
  iconic: 5900, // $59
  memory: 6900, // $69
  collector: 8900, // $89
};

// Valid formats whitelist
const VALID_FORMATS = Object.keys(FORMAT_PRICES);

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  try {
    // Verify authorization
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Initialize Supabase client to verify user
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Parse request body
    const body: CheckoutRequest = await req.json();

    // Validate required fields
    if (
      !body.wedding_id ||
      !body.bride_user_id ||
      !body.magazine_format ||
      !body.photo_count ||
      !body.success_url ||
      !body.cancel_url
    ) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // SECURITY: Validate magazine_format is in whitelist
    if (!VALID_FORMATS.includes(body.magazine_format)) {
      return new Response(
        JSON.stringify({
          error: `Invalid magazine format: ${body.magazine_format}. Valid formats: ${VALID_FORMATS.join(", ")}`,
        }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // SECURITY: Calculate prices SERVER-SIDE (never trust client)
    const magazinePriceCents = FORMAT_PRICES[body.magazine_format];

    // Security check: user must match bride_user_id
    if (user.id !== body.bride_user_id) {
      return new Response(
        JSON.stringify({ error: "User does not match order" }),
        {
          status: 403,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Additional security: verify wedding belongs to bride using service role
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: wedding, error: weddingError } = await supabaseAdmin
      .from("weddings")
      .select("bride_profile_id")
      .eq("id", body.wedding_id)
      .single();

    if (weddingError || !wedding) {
      return new Response(JSON.stringify({ error: "Wedding not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (wedding.bride_profile_id !== body.bride_user_id) {
      return new Response(
        JSON.stringify({ error: "Wedding does not belong to user" }),
        {
          status: 403,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const formatName = formatNames[body.magazine_format] || body.magazine_format;
    const formatSize = formatSizes[body.magazine_format] || "21x30cm";

    // Create Stripe Checkout session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      mode: "payment",
      line_items: [
        {
          price_data: {
            currency: "usd",
            product_data: {
              name: `Lynewed Magazine - ${formatName}`,
              description: `${formatSize} • ${body.photo_count} photos`,
              images: ["https://lynewed.com/images/magazine-preview.jpg"],
            },
            unit_amount: magazinePriceCents, // SERVER-SIDE calculated
          },
          quantity: 1,
        },
      ],
      shipping_address_collection: {
        allowed_countries: ["US", "CA", "GB", "FR", "DE", "IT", "ES", "AU"],
      },
      shipping_options: [
        {
          shipping_rate_data: {
            type: "fixed_amount",
            fixed_amount: { amount: 1500, currency: "usd" },
            display_name: "Standard Shipping — USA",
            delivery_estimate: {
              minimum: { unit: "business_day", value: 5 },
              maximum: { unit: "business_day", value: 10 },
            },
          },
        },
        {
          shipping_rate_data: {
            type: "fixed_amount",
            fixed_amount: { amount: 2500, currency: "usd" },
            display_name: "International — Canada & Europe",
            delivery_estimate: {
              minimum: { unit: "business_day", value: 7 },
              maximum: { unit: "business_day", value: 14 },
            },
          },
        },
        {
          shipping_rate_data: {
            type: "fixed_amount",
            fixed_amount: { amount: 3500, currency: "usd" },
            display_name: "International — Australia",
            delivery_estimate: {
              minimum: { unit: "business_day", value: 10 },
              maximum: { unit: "business_day", value: 21 },
            },
          },
        },
      ],
      metadata: {
        product_type: "magazine",
        wedding_id: body.wedding_id,
        bride_user_id: body.bride_user_id,
        magazine_format: body.magazine_format,
        magazine_price_cents: magazinePriceCents.toString(),
        photo_count: body.photo_count.toString(),
        magazine_title: body.magazine_title,
        magazine_date: body.magazine_date || "",
        cover_photo_id: body.cover_photo_id || "",
      },
      success_url: body.success_url,
      cancel_url: body.cancel_url,
      customer_email: user.email,
    });

    console.log(`Created checkout session ${session.id} for wedding ${body.wedding_id}`);

    return new Response(
      JSON.stringify({
        checkout_url: session.url,
        session_id: session.id,
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    console.error("Error creating checkout session:", error);
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
});

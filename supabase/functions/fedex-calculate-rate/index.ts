// EPIC-14 S11: Calculate FedEx Shipping Rates
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { FedExClient } from "./fedex-client.ts";

interface RateRequest {
  from_address: { streetLines: string[]; city: string; stateOrProvinceCode?: string; postalCode: string; countryCode: string };
  to_address: { streetLines: string[]; city: string; stateOrProvinceCode?: string; postalCode: string; countryCode: string };
  package_weight_kg?: number;
  package_dimensions_cm?: { length: number; width: number; height: number };
  category?: 'dress' | 'shoes' | 'accessories' | 'decoration';
}

const DEFAULT_PACKAGES: Record<string, { weight: { units: 'KG'; value: number }; dimensions: { units: 'CM'; length: number; width: number; height: number } }> = {
  dress: { weight: { units: 'KG', value: 3 }, dimensions: { units: 'CM', length: 60, width: 40, height: 20 } },
  shoes: { weight: { units: 'KG', value: 2 }, dimensions: { units: 'CM', length: 35, width: 25, height: 15 } },
  accessories: { weight: { units: 'KG', value: 1 }, dimensions: { units: 'CM', length: 30, width: 20, height: 10 } },
  decoration: { weight: { units: 'KG', value: 5 }, dimensions: { units: 'CM', length: 50, width: 50, height: 30 } },
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Methods": "POST, OPTIONS", "Access-Control-Allow-Headers": "Content-Type, Authorization" } });
  }
  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: { "Content-Type": "application/json" } });

    const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, { global: { headers: { Authorization: authHeader } } });
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers: { "Content-Type": "application/json" } });

    const body: RateRequest = await req.json();
    if (!body.from_address || !body.to_address) return new Response(JSON.stringify({ error: "Missing from_address or to_address" }), { status: 400, headers: { "Content-Type": "application/json" } });

    const fedex = new FedExClient({
      clientId: Deno.env.get('FEDEX_CLIENT_ID')!,
      clientSecret: Deno.env.get('FEDEX_CLIENT_SECRET')!,
      accountNumber: Deno.env.get('FEDEX_ACCOUNT_NUMBER')!,
      environment: (Deno.env.get('FEDEX_ENV') || 'sandbox') as 'sandbox' | 'production',
    });

    console.log('Validating addresses...');
    const [fromValidation, toValidation] = await Promise.all([
      fedex.validateAddress(body.from_address),
      fedex.validateAddress(body.to_address),
    ]);

    if (!fromValidation.valid || !toValidation.valid) {
      return new Response(JSON.stringify({ error: 'invalid_address', from_suggestions: fromValidation.suggestions, to_suggestions: toValidation.suggestions }), { status: 400, headers: { "Content-Type": "application/json" } });
    }

    const category = body.category || 'dress';
    const defaultPackage = DEFAULT_PACKAGES[category] || DEFAULT_PACKAGES.dress;
    const packageDetails = {
      weight: body.package_weight_kg ? { units: 'KG' as const, value: body.package_weight_kg } : defaultPackage.weight,
      dimensions: body.package_dimensions_cm ? { units: 'CM' as const, ...body.package_dimensions_cm } : defaultPackage.dimensions,
    };

    console.log('Calculating rates...');
    let rates;
    let retries = 0;
    while (retries <= 2) {
      try {
        rates = await Promise.race([
          fedex.getRates({ shipper: body.from_address, recipient: body.to_address, packageDetails }),
          new Promise<never>((_, reject) => setTimeout(() => reject(new Error('Request timeout')), 30000)),
        ]);
        break;
      } catch (error) {
        retries++;
        if (retries > 2) throw error;
        console.log(`Rate request failed, retrying (${retries}/2)...`);
        await new Promise((resolve) => setTimeout(resolve, 1000 * retries));
      }
    }

    return new Response(JSON.stringify({
      rates: rates!.map((r) => ({ service_type: r.serviceType, service_name: r.serviceName, rate_cents: Math.round(r.totalCharges * 100), currency: r.currency || 'USD', estimated_delivery: r.deliveryTimestamp, estimated_days: r.transitTime })),
    }), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (error) {
    console.error("Error calculating rates:", error);
    const msg = (error as Error).message;
    if (msg.includes('timeout')) return new Response(JSON.stringify({ error: 'Request timeout. Please try again.' }), { status: 500, headers: { "Content-Type": "application/json" } });
    try { const parsed = JSON.parse(msg); return new Response(JSON.stringify(parsed), { status: 500, headers: { "Content-Type": "application/json" } }); } catch { /* not JSON */ }
    return new Response(JSON.stringify({ error: msg }), { status: 500, headers: { "Content-Type": "application/json" } });
  }
});

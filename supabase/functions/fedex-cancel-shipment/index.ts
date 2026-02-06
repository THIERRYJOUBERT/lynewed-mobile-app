/// Edge Function: fedex-cancel-shipment
/// Cancels a FedEx shipment (voids the shipping label) for a marketplace transaction.
/// Only the seller can cancel, and only when status = 'label_created'.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

interface FedExConfig {
  clientId: string;
  clientSecret: string;
  accountNumber: string;
  environment: "sandbox" | "production";
}

class FedExClient {
  private config: FedExConfig;
  private accessToken: string | null = null;
  private tokenExpiry: Date | null = null;
  private baseUrl: string;

  constructor(config: FedExConfig) {
    this.config = config;
    this.baseUrl =
      config.environment === "sandbox"
        ? "https://apis-sandbox.fedex.com"
        : "https://apis.fedex.com";
  }

  private async getToken(): Promise<string> {
    if (this.accessToken && this.tokenExpiry && new Date() < this.tokenExpiry)
      return this.accessToken;
    const response = await fetch(`${this.baseUrl}/oauth/token`, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "client_credentials",
        client_id: this.config.clientId,
        client_secret: this.config.clientSecret,
      }),
    });
    if (!response.ok)
      throw new Error(`FedEx OAuth failed: ${await response.text()}`);
    const data = await response.json();
    this.accessToken = data.access_token;
    this.tokenExpiry = new Date(Date.now() + 55 * 60 * 1000);
    return this.accessToken!;
  }

  async cancelShipment(trackingNumber: string): Promise<void> {
    const token = await this.getToken();
    const response = await fetch(`${this.baseUrl}/ship/v1/shipments/cancel`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({
        accountNumber: { value: this.config.accountNumber },
        trackingNumber: trackingNumber,
      }),
    });
    if (!response.ok) {
      const data = await response.json();
      console.error("FedEx Cancel error:", data);
      throw new Error(
        data.errors?.[0]?.message || "Shipment cancellation failed"
      );
    }
  }
}

Deno.serve(async (req: Request) => {
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
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Verify the user from JWT
    const token = authHeader.replace("Bearer ", "");
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser(token);
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Invalid token" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const { transaction_id } = await req.json();
    if (!transaction_id) {
      return new Response(
        JSON.stringify({ error: "Missing transaction_id" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Fetch the transaction
    const { data: tx, error: txError } = await supabase
      .from("marketplace_transactions")
      .select(
        "id, seller_id, buyer_id, listing_id, status, fedex_tracking_number, fedex_label_url"
      )
      .eq("id", transaction_id)
      .single();

    if (txError || !tx) {
      return new Response(
        JSON.stringify({ error: "Transaction not found" }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }

    // Only the seller can cancel
    if (tx.seller_id !== user.id) {
      return new Response(
        JSON.stringify({
          error: "Only the seller can cancel a shipment",
        }),
        { status: 403, headers: { "Content-Type": "application/json" } }
      );
    }

    // Only label_created can be cancelled
    if (tx.status !== "label_created") {
      return new Response(
        JSON.stringify({
          error: `Cannot cancel shipment with status: ${tx.status}. Only label_created shipments can be cancelled.`,
        }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    if (!tx.fedex_tracking_number) {
      return new Response(
        JSON.stringify({ error: "No tracking number found" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Call FedEx Cancel API
    const fedex = new FedExClient({
      clientId: Deno.env.get("FEDEX_CLIENT_ID")!,
      clientSecret: Deno.env.get("FEDEX_CLIENT_SECRET")!,
      accountNumber: Deno.env.get("FEDEX_ACCOUNT_NUMBER")!,
      environment: (Deno.env.get("FEDEX_ENV") || "sandbox") as
        | "sandbox"
        | "production",
    });

    await fedex.cancelShipment(tx.fedex_tracking_number);

    // Revert transaction to paid, clear FedEx fields
    const now = new Date().toISOString();
    await supabase
      .from("marketplace_transactions")
      .update({
        status: "paid",
        fedex_tracking_number: null,
        fedex_label_url: null,
        updated_at: now,
      })
      .eq("id", tx.id);

    // Audit trail: insert cancellation event
    await supabase.from("fedex_events").insert({
      transaction_id: tx.id,
      tracking_number: tx.fedex_tracking_number,
      event_type: "shipment_cancelled",
      event_description: "Shipping label voided by seller",
      event_code: "CA",
      event_timestamp: now,
      created_at: now,
    });

    // Fetch listing title for notification
    const { data: listing } = await supabase
      .from("marketplace_listings")
      .select("title")
      .eq("id", tx.listing_id)
      .maybeSingle();
    const listingTitle = listing?.title || "item";

    // Notify the buyer
    await supabase.from("notifications_outbox").insert({
      event_type: "marketplace_shipment_cancelled",
      event_key: `marketplace:shipment_cancelled:${tx.id}`,
      payload: {
        recipient_id: tx.buyer_id,
        transaction_id: tx.id,
        listing_id: tx.listing_id,
        listing_title: listingTitle,
      },
    });

    console.log(
      `Cancelled shipment for transaction ${tx.id}, tracking ${tx.fedex_tracking_number}`
    );

    return new Response(
      JSON.stringify({
        success: true,
        transaction_id: tx.id,
        cancelled_tracking_number: tx.fedex_tracking_number,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Cancel shipment error:", error);
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});

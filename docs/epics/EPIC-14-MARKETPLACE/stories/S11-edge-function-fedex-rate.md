# Story S11: Edge Function FedEx Rate API

## Description
En tant qu'acheteuse, je veux voir les frais de port en temps reel, afin de connaitre le cout total avant d'acheter.

## Prerequisites

- [ ] FedEx Developer Account created: https://developer.fedex.com/
- [ ] APIs enabled: Address Validation, Rate and Transit Times
- [ ] Credentials stored in Supabase Secrets:
  - `FEDEX_CLIENT_ID`
  - `FEDEX_CLIENT_SECRET`
  - `FEDEX_ACCOUNT_NUMBER`
  - `FEDEX_ENV` (set to `'sandbox'` for testing)
- [ ] Context7 FedEx documentation available: `/websites/developer_fedex_api_en-us`

## Criteres d'Acceptance (Gherkin)

- [ ] Given a listing in New York And a buyer address in Los Angeles When calculating shipping rate Then response should include service_type, rate_cents, estimated_days for multiple options (Ground, Express)
- [ ] Given a listing in Paris, France And a buyer address in New York, USA When calculating shipping rate Then response should include international options And customs fees should be indicated
- [ ] Given an invalid destination address When calculating shipping rate Then error should indicate invalid address And suggest corrections if available via Address Validation API
- [ ] Given valid from/to addresses When calling the Rate API Then both addresses should be validated first via Address Validation API
- [ ] Given a successful rate calculation Then rates should be returned sorted by price (cheapest first)

## Files to Create/Modify

### CREATE

```
supabase/functions/
├── _shared/
│   └── fedex-client.ts                              # Shared FedEx client (OAuth2, Address Validation, Rate, Ship, Track)
├── fedex-calculate-rate/
│   └── index.ts                                     # Edge Function for rate calculation

lib/features/marketplace/
├── domain/
│   ├── entities/
│   │   ├── shipping_rate.dart                       # Entity
│   │   └── address.dart                             # Address entity
│   ├── repositories/
│   │   └── fedex_repository.dart                    # Abstract interface
│   └── usecases/
│       ├── calculate_shipping_rate.dart             # Use case
│       └── validate_address.dart                    # Use case
├── data/
│   ├── models/
│   │   ├── shipping_rate_model.dart                 # Data model
│   │   └── address_model.dart                       # Data model
│   ├── datasources/
│   │   └── fedex_remote_datasource.dart             # API calls
│   └── repositories/
│       └── fedex_repository_impl.dart               # Repository implementation
└── presentation/
    └── widgets/
        └── shipping_rate_selector.dart              # Widget to display/select rates

test/features/marketplace/
├── domain/usecases/
│   ├── calculate_shipping_rate_test.dart
│   └── validate_address_test.dart
├── data/repositories/
│   └── fedex_repository_impl_test.dart
└── presentation/widgets/
    └── shipping_rate_selector_test.dart
```

### MODIFY

- `lib/core/di/injection_container.dart` - Add `_initMarketplaceFedEx()`

## Shared FedEx Client

`supabase/functions/_shared/fedex-client.ts`:

```typescript
// EPIC-14 S11-S13: Shared FedEx API Client
// Provides OAuth2 authentication, Address Validation, Rate, Ship, and Track APIs
import Stripe from "npm:stripe@17.7.0"; // For type compatibility

interface FedExConfig {
  clientId: string;
  clientSecret: string;
  accountNumber: string;
  environment: 'sandbox' | 'production';
}

interface Address {
  streetLines: string[];
  city: string;
  stateOrProvinceCode?: string;
  postalCode: string;
  countryCode: string; // ISO 2-letter (e.g., 'US', 'FR')
  personName?: string;
  phoneNumber?: string;
  companyName?: string;
}

interface AddressValidationResult {
  valid: boolean;
  suggestions?: Address[];
  error?: string;
}

interface PackageDetails {
  weight: { units: 'KG' | 'LB'; value: number };
  dimensions: { units: 'CM' | 'IN'; length: number; width: number; height: number };
}

interface RateParams {
  shipper: Address;
  recipient: Address;
  packageDetails: PackageDetails;
}

interface ShippingRate {
  serviceType: string;
  serviceName: string;
  totalCharges: number;
  currency: string;
  deliveryTimestamp?: string;
  transitTime?: number;
}

interface ShipmentParams {
  shipper: Address;
  recipient: Address;
  serviceType: string;
  packageDetails: PackageDetails;
  referenceId?: string;
}

interface ShipmentResult {
  trackingNumber: string;
  labelUrl: string;
  labelBase64?: string;
  rawResponse: any;
}

interface TrackingEvent {
  code: string;
  description: string;
  timestamp: string;
  location?: string;
  city?: string;
  country?: string;
}

export class FedExClient {
  private config: FedExConfig;
  private accessToken: string | null = null;
  private tokenExpiry: Date | null = null;
  private baseUrl: string;

  constructor(config: FedExConfig) {
    this.config = config;
    this.baseUrl = config.environment === 'sandbox'
      ? 'https://apis-sandbox.fedex.com'
      : 'https://apis.fedex.com';
  }

  /**
   * Get OAuth2 access token (cached for 1 hour)
   */
  private async getToken(): Promise<string> {
    // Check if cached token is still valid
    if (this.accessToken && this.tokenExpiry && new Date() < this.tokenExpiry) {
      return this.accessToken;
    }

    console.log('Fetching new FedEx OAuth2 token...');

    const response = await fetch(`${this.baseUrl}/oauth/token`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'client_credentials',
        client_id: this.config.clientId,
        client_secret: this.config.clientSecret,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`FedEx OAuth failed: ${error}`);
    }

    const data = await response.json();
    this.accessToken = data.access_token;

    // Token expires in 3600 seconds (1 hour), cache for 55 minutes to be safe
    this.tokenExpiry = new Date(Date.now() + 55 * 60 * 1000);

    console.log('FedEx OAuth2 token obtained');
    return this.accessToken;
  }

  /**
   * Validate an address
   */
  async validateAddress(address: Address): Promise<AddressValidationResult> {
    const token = await this.getToken();

    const response = await fetch(`${this.baseUrl}/address/v1/addresses/resolve`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify({
        addressesToValidate: [
          {
            address: {
              streetLines: address.streetLines,
              city: address.city,
              stateOrProvinceCode: address.stateOrProvinceCode,
              postalCode: address.postalCode,
              countryCode: address.countryCode,
            },
          },
        ],
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error('FedEx Address Validation error:', data);
      return {
        valid: false,
        error: data.errors?.[0]?.message || 'Address validation failed',
      };
    }

    const result = data.output?.resolvedAddresses?.[0];
    if (!result) {
      return { valid: false, error: 'No validation result' };
    }

    const isValid = result.classification === 'VALID' ||
                   result.classification === 'STANDARDIZED';

    if (!isValid && result.parsedAddress) {
      // Provide suggestion
      return {
        valid: false,
        suggestions: [
          {
            streetLines: result.parsedAddress.streetLines || address.streetLines,
            city: result.parsedAddress.city || address.city,
            stateOrProvinceCode: result.parsedAddress.stateOrProvinceCode,
            postalCode: result.parsedAddress.postalCode || address.postalCode,
            countryCode: result.parsedAddress.countryCode || address.countryCode,
          },
        ],
      };
    }

    return { valid: isValid };
  }

  /**
   * Get shipping rates
   */
  async getRates(params: RateParams): Promise<ShippingRate[]> {
    const token = await this.getToken();

    const response = await fetch(`${this.baseUrl}/rate/v1/rates/quotes`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify({
        accountNumber: {
          value: this.config.accountNumber,
        },
        requestedShipment: {
          shipper: {
            address: {
              streetLines: params.shipper.streetLines,
              city: params.shipper.city,
              stateOrProvinceCode: params.shipper.stateOrProvinceCode,
              postalCode: params.shipper.postalCode,
              countryCode: params.shipper.countryCode,
            },
          },
          recipient: {
            address: {
              streetLines: params.recipient.streetLines,
              city: params.recipient.city,
              stateOrProvinceCode: params.recipient.stateOrProvinceCode,
              postalCode: params.recipient.postalCode,
              countryCode: params.recipient.countryCode,
            },
          },
          pickupType: 'DROPOFF_AT_FEDEX_LOCATION',
          rateRequestType: ['ACCOUNT', 'LIST'],
          requestedPackageLineItems: [
            {
              weight: params.packageDetails.weight,
              dimensions: params.packageDetails.dimensions,
            },
          ],
        },
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error('FedEx Rate API error:', data);
      throw new Error(data.errors?.[0]?.message || 'Rate calculation failed');
    }

    const rateReplyDetails = data.output?.rateReplyDetails || [];

    const rates: ShippingRate[] = rateReplyDetails.map((detail: any) => {
      const totalCharge = detail.ratedShipmentDetails?.[0]?.totalNetCharge || 0;
      const currency = detail.ratedShipmentDetails?.[0]?.currency || 'USD';

      return {
        serviceType: detail.serviceType,
        serviceName: detail.serviceName || detail.serviceType,
        totalCharges: totalCharge,
        currency,
        deliveryTimestamp: detail.commit?.dateDetail?.dayFormat,
        transitTime: detail.commit?.transitDays,
      };
    });

    // Sort by price (cheapest first)
    rates.sort((a, b) => a.totalCharges - b.totalCharges);

    return rates;
  }

  /**
   * Create shipment and generate label
   */
  async createShipment(params: ShipmentParams): Promise<ShipmentResult> {
    const token = await this.getToken();

    const response = await fetch(`${this.baseUrl}/ship/v1/shipments`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify({
        accountNumber: {
          value: this.config.accountNumber,
        },
        requestedShipment: {
          shipper: {
            contact: {
              personName: params.shipper.personName || 'Seller',
              phoneNumber: params.shipper.phoneNumber || '0000000000',
              companyName: params.shipper.companyName,
            },
            address: {
              streetLines: params.shipper.streetLines,
              city: params.shipper.city,
              stateOrProvinceCode: params.shipper.stateOrProvinceCode,
              postalCode: params.shipper.postalCode,
              countryCode: params.shipper.countryCode,
            },
          },
          recipient: {
            contact: {
              personName: params.recipient.personName || 'Buyer',
              phoneNumber: params.recipient.phoneNumber || '0000000000',
              companyName: params.recipient.companyName,
            },
            address: {
              streetLines: params.recipient.streetLines,
              city: params.recipient.city,
              stateOrProvinceCode: params.recipient.stateOrProvinceCode,
              postalCode: params.recipient.postalCode,
              countryCode: params.recipient.countryCode,
            },
          },
          serviceType: params.serviceType,
          pickupType: 'DROPOFF_AT_FEDEX_LOCATION',
          packagingType: 'YOUR_PACKAGING',
          shippingChargesPayment: {
            paymentType: 'SENDER',
          },
          labelSpecification: {
            labelFormatType: 'COMMON2D',
            imageType: 'PDF',
            labelStockType: 'PAPER_4X6',
          },
          requestedPackageLineItems: [
            {
              weight: params.packageDetails.weight,
              dimensions: params.packageDetails.dimensions,
              customerReferences: params.referenceId
                ? [{ customerReferenceType: 'CUSTOMER_REFERENCE', value: params.referenceId }]
                : undefined,
            },
          ],
        },
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error('FedEx Ship API error:', data);
      throw new Error(data.errors?.[0]?.message || 'Shipment creation failed');
    }

    const completedShipmentDetail = data.output?.transactionShipments?.[0]?.completedShipmentDetail;
    const trackingNumber = completedShipmentDetail?.masterTrackingNumber || completedShipmentDetail?.trackingIdNumber;
    const labelBase64 = completedShipmentDetail?.shipmentDocuments?.[0]?.encodedLabel;

    if (!trackingNumber || !labelBase64) {
      throw new Error('Missing tracking number or label in FedEx response');
    }

    // For this implementation, we return base64 and let the Edge Function store it in Supabase Storage
    return {
      trackingNumber,
      labelUrl: '', // Will be set by Edge Function after uploading to Storage
      labelBase64,
      rawResponse: data,
    };
  }

  /**
   * Track a shipment
   */
  async trackShipment(trackingNumber: string): Promise<TrackingEvent[]> {
    const token = await this.getToken();

    const response = await fetch(`${this.baseUrl}/track/v1/trackingnumbers`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify({
        includeDetailedScans: true,
        trackingInfo: [
          {
            trackingNumberInfo: {
              trackingNumber,
            },
          },
        ],
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      console.error('FedEx Track API error:', data);
      throw new Error(data.errors?.[0]?.message || 'Tracking failed');
    }

    const trackResults = data.output?.completeTrackResults?.[0]?.trackResults || [];
    const events: TrackingEvent[] = [];

    for (const result of trackResults) {
      const scanEvents = result.scanEvents || [];
      for (const event of scanEvents) {
        events.push({
          code: event.eventType || 'UNKNOWN',
          description: event.eventDescription || 'Unknown event',
          timestamp: event.date || new Date().toISOString(),
          location: `${event.scanLocation?.city || ''}, ${event.scanLocation?.stateOrProvinceCode || ''} ${event.scanLocation?.countryCode || ''}`.trim(),
          city: event.scanLocation?.city,
          country: event.scanLocation?.countryCode,
        });
      }
    }

    // Sort by timestamp (oldest first)
    events.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());

    return events;
  }
}
```

## Edge Function: fedex-calculate-rate

`supabase/functions/fedex-calculate-rate/index.ts`:

```typescript
// EPIC-14 S11: Calculate FedEx Shipping Rates
// Validates addresses and calculates shipping rates
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { FedExClient } from "../_shared/fedex-client.ts";

interface RateRequest {
  from_address: {
    streetLines: string[];
    city: string;
    stateOrProvinceCode?: string;
    postalCode: string;
    countryCode: string;
  };
  to_address: {
    streetLines: string[];
    city: string;
    stateOrProvinceCode?: string;
    postalCode: string;
    countryCode: string;
  };
  package_weight_kg?: number;
  package_dimensions_cm?: { length: number; width: number; height: number };
  category?: 'dress' | 'shoes' | 'accessories' | 'decoration';
}

// Default package dimensions by category
const DEFAULT_PACKAGES: Record<string, { weight: { units: 'KG'; value: number }; dimensions: { units: 'CM'; length: number; width: number; height: number } }> = {
  dress: {
    weight: { units: 'KG', value: 3 },
    dimensions: { units: 'CM', length: 60, width: 40, height: 20 },
  },
  shoes: {
    weight: { units: 'KG', value: 2 },
    dimensions: { units: 'CM', length: 35, width: 25, height: 15 },
  },
  accessories: {
    weight: { units: 'KG', value: 1 },
    dimensions: { units: 'CM', length: 30, width: 20, height: 10 },
  },
  decoration: {
    weight: { units: 'KG', value: 5 },
    dimensions: { units: 'CM', length: 50, width: 50, height: 30 },
  },
};

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

    // Initialize Supabase client
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    // Verify user
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

    // Parse request
    const body: RateRequest = await req.json();

    // Validate required fields
    if (!body.from_address || !body.to_address) {
      return new Response(JSON.stringify({ error: "Missing from_address or to_address" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Initialize FedEx client
    const fedex = new FedExClient({
      clientId: Deno.env.get('FEDEX_CLIENT_ID')!,
      clientSecret: Deno.env.get('FEDEX_CLIENT_SECRET')!,
      accountNumber: Deno.env.get('FEDEX_ACCOUNT_NUMBER')!,
      environment: (Deno.env.get('FEDEX_ENV') || 'sandbox') as 'sandbox' | 'production',
    });

    // 1. Validate addresses
    console.log('Validating addresses...');
    const [fromValidation, toValidation] = await Promise.all([
      fedex.validateAddress(body.from_address),
      fedex.validateAddress(body.to_address),
    ]);

    if (!fromValidation.valid || !toValidation.valid) {
      return new Response(
        JSON.stringify({
          error: 'invalid_address',
          from_suggestions: fromValidation.suggestions,
          to_suggestions: toValidation.suggestions,
        }),
        {
          status: 400,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    // 2. Get package details (use provided or default by category)
    const category = body.category || 'dress';
    const defaultPackage = DEFAULT_PACKAGES[category] || DEFAULT_PACKAGES.dress;

    const packageDetails = {
      weight: body.package_weight_kg
        ? { units: 'KG' as const, value: body.package_weight_kg }
        : defaultPackage.weight,
      dimensions: body.package_dimensions_cm
        ? { units: 'CM' as const, ...body.package_dimensions_cm }
        : defaultPackage.dimensions,
    };

    console.log('Calculating rates with package:', packageDetails);

    // 3. Get rates (with timeout and retry)
    let rates;
    let retries = 0;
    const maxRetries = 2;

    while (retries <= maxRetries) {
      try {
        rates = await Promise.race([
          fedex.getRates({
            shipper: body.from_address,
            recipient: body.to_address,
            packageDetails,
          }),
          new Promise<never>((_, reject) =>
            setTimeout(() => reject(new Error('Request timeout')), 30000)
          ),
        ]);
        break; // Success
      } catch (error) {
        retries++;
        if (retries > maxRetries) {
          throw error;
        }
        console.log(`Rate request failed, retrying (${retries}/${maxRetries})...`);
        await new Promise((resolve) => setTimeout(resolve, 1000 * retries)); // Backoff
      }
    }

    // 4. Format response
    return new Response(
      JSON.stringify({
        rates: rates!.map((r) => ({
          service_type: r.serviceType,
          service_name: r.serviceName,
          rate_cents: Math.round(r.totalCharges * 100),
          currency: r.currency || 'USD',
          estimated_delivery: r.deliveryTimestamp,
          estimated_days: r.transitTime,
        })),
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
    console.error("Error calculating rates:", error);

    // Friendly error messages
    let errorMessage = (error as Error).message;
    if (errorMessage.includes('timeout')) {
      errorMessage = 'Request timeout. Please try again.';
    } else if (errorMessage.includes('rate_limit')) {
      errorMessage = 'Too many requests. Please wait a moment.';
    }

    return new Response(
      JSON.stringify({ error: errorMessage }),
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
```

## FedEx Error Codes (Top 10)

| Code | Description | User Message |
|------|-------------|--------------|
| `AUTHENTICATION.FAILED` | Invalid credentials | "FedEx authentication error. Please contact support." |
| `INVALID.ADDRESS` | Address not valid | "Invalid shipping address. Please verify and try again." |
| `SERVICE.NOT.AVAILABLE` | Service unavailable for route | "Shipping not available for this route." |
| `WEIGHT.EXCEEDS.MAXIMUM` | Package too heavy | "Package exceeds maximum weight limit." |
| `POSTAL.CODE.INVALID` | Invalid postal code | "Invalid postal code. Please check and try again." |
| `COUNTRY.NOT.SUPPORTED` | Country not supported | "Shipping to this country is not available." |
| `RATE.NOT.AVAILABLE` | No rates found | "No shipping options available for this route." |
| `SYSTEM.UNAVAILABLE` | FedEx system down | "Shipping service temporarily unavailable. Please try again later." |
| `REQUEST.TIMEOUT` | Request timed out | "Request timeout. Please try again." |
| `ACCOUNT.INVALID` | Account issue | "FedEx account configuration error. Please contact support." |

## Design System Integration

### Widgets to Use

```dart
import '/core/design/design.dart';

// Use:
// - LynewedButton for "Calculate Shipping"
// - LynewedColors for rate cards
// - LynewedTextStyles for rate display
// - LynewedRadioTile or LynewedChip for service selection
```

### Shipping Rate Selector Widget

`lib/features/marketplace/presentation/widgets/shipping_rate_selector.dart`:

```dart
import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/shipping_rate.dart';

class ShippingRateSelector extends StatefulWidget {
  final List<ShippingRate> rates;
  final ShippingRate? selectedRate;
  final ValueChanged<ShippingRate> onRateSelected;

  const ShippingRateSelector({
    required this.rates,
    required this.onRateSelected,
    this.selectedRate,
    super.key,
  });

  @override
  State<ShippingRateSelector> createState() => _ShippingRateSelectorState();
}

class _ShippingRateSelectorState extends State<ShippingRateSelector> {
  @override
  Widget build(BuildContext context) {
    if (widget.rates.isEmpty) {
      return Center(
        child: Text(
          'No shipping options available',
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Shipping Method',
          style: LynewedTextStyles.titleMedium,
        ),
        const SizedBox(height: LynewedSpacing.md),
        ...widget.rates.map((rate) => _buildRateCard(rate)),
      ],
    );
  }

  Widget _buildRateCard(ShippingRate rate) {
    final isSelected = widget.selectedRate?.serviceType == rate.serviceType;

    return GestureDetector(
      onTap: () => widget.onRateSelected(rate),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? LynewedColors.primary.withOpacity(0.1)
              : LynewedColors.surface,
          border: Border.all(
            color: isSelected ? LynewedColors.primary : LynewedColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: rate.serviceType,
              groupValue: widget.selectedRate?.serviceType,
              onChanged: (_) => widget.onRateSelected(rate),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rate.serviceName,
                    style: LynewedTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  if (rate.estimatedDays != null)
                    Text(
                      '${rate.estimatedDays} business days',
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '\$${(rate.rateCents / 100).toStringAsFixed(2)}',
              style: LynewedTextStyles.titleMedium.copyWith(
                color: LynewedColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Tests Required

### Unit Tests

```dart
// test/features/marketplace/domain/usecases/calculate_shipping_rate_test.dart
group('CalculateShippingRateUseCase', () {
  test('calls Edge Function with correct addresses', () async {
    // Arrange: mock datasource
    // Act: call use case
    // Assert: datasource called with from_address, to_address
  });

  test('returns sorted rates (cheapest first)', () async {
    // Arrange: mock returns multiple rates
    // Act: call use case
    // Assert: rates sorted by price
  });

  test('throws exception when addresses invalid', () async {
    // Arrange: mock returns invalid address error
    // Act & Assert: expect exception with suggestions
  });
});
```

## Error Handling

| Error | Code | User Message | Retry? |
|-------|------|-------------|--------|
| Invalid address | `invalid_address` | "Invalid address. Please verify and try again." | No (show suggestions) |
| No service available | `service_unavailable` | "Shipping not available for this route." | No |
| FedEx API error | `fedex_error` | "Error calculating shipping. Please try again." | Yes |
| Timeout | `timeout` | "Request timeout. Please try again." | Yes |
| Rate limit | `rate_limit` | "Too many requests. Please wait a moment." | Yes (after delay) |
| Authentication | `auth_error` | "FedEx configuration error. Contact support." | No |

## Definition of Done

- [ ] FedEx credentials configured in Supabase Secrets
- [ ] Shared FedExClient created in `_shared/fedex-client.ts`
- [ ] Edge Function `fedex-calculate-rate` deployed
- [ ] Address Validation works correctly
- [ ] Rate API returns correct tarifs for multiple services
- [ ] Rates sorted by price (cheapest first)
- [ ] Default package dimensions configured by category
- [ ] Timeout (30s) and retry (2x with backoff) implemented
- [ ] All unit tests pass
- [ ] All widget tests pass
- [ ] `flutter analyze --fatal-infos` passes
- [ ] Tested in sandbox mode with various addresses

## Estimation
**Points** : 5
**Complexite** : Moyenne
**Risque** : Moyen (API externe, quotas, rate limits)

## Dependances

### Requires
- FedEx Developer Account configured
- Supabase Secrets configured:
  - `FEDEX_CLIENT_ID`
  - `FEDEX_CLIENT_SECRET`
  - `FEDEX_ACCOUNT_NUMBER`
  - `FEDEX_ENV` (sandbox/production)

### Provides
- Shared FedExClient for S12 (Ship) and S13 (Track)
- Rate calculation capability for marketplace

### Blocks
- S12 (FedEx Ship - uses same FedExClient)
- S20 (purchase flow - needs rate calculation)

## Stories Dependantes
- S12 (FedEx Ship API - utilise meme FedExClient)
- S20 (flow achat - calcul frais port)

## Notes

### FedEx API Reference (Context7)

For detailed API documentation:
```
mcp__plugin_context7_context7__query-docs:
- libraryId: "/websites/developer_fedex_api_en-us"
- query: "rate and transit times API request format"
```

### Example JSON Request/Response

**Request:**
```json
{
  "from_address": {
    "streetLines": ["123 Main St"],
    "city": "New York",
    "stateOrProvinceCode": "NY",
    "postalCode": "10001",
    "countryCode": "US"
  },
  "to_address": {
    "streetLines": ["456 Ocean Ave"],
    "city": "Los Angeles",
    "stateOrProvinceCode": "CA",
    "postalCode": "90001",
    "countryCode": "US"
  },
  "category": "dress"
}
```

**Response:**
```json
{
  "rates": [
    {
      "service_type": "FEDEX_GROUND",
      "service_name": "FedEx Ground",
      "rate_cents": 1250,
      "currency": "USD",
      "estimated_delivery": "2026-02-10",
      "estimated_days": 5
    },
    {
      "service_type": "FEDEX_2_DAY",
      "service_name": "FedEx 2Day",
      "rate_cents": 2500,
      "currency": "USD",
      "estimated_delivery": "2026-02-06",
      "estimated_days": 2
    }
  ]
}
```

### OAuth2 Token Caching

The FedExClient caches tokens in a global variable. Edge Functions can reuse warm instances, making this effective for reducing OAuth calls. Token expires in 1 hour, cached for 55 minutes.

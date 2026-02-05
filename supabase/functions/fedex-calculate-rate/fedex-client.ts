// Shared FedEx API Client - OAuth2, Address Validation, Rate, Ship, Track

export interface FedExConfig {
  clientId: string;
  clientSecret: string;
  accountNumber: string;
  environment: 'sandbox' | 'production';
}

export interface Address {
  streetLines: string[];
  city: string;
  stateOrProvinceCode?: string;
  postalCode: string;
  countryCode: string;
  personName?: string;
  phoneNumber?: string;
  companyName?: string;
}

export interface AddressValidationResult {
  valid: boolean;
  suggestions?: Address[];
  error?: string;
}

export interface PackageDetails {
  weight: { units: 'KG' | 'LB'; value: number };
  dimensions: { units: 'CM' | 'IN'; length: number; width: number; height: number };
}

export interface RateParams {
  shipper: Address;
  recipient: Address;
  packageDetails: PackageDetails;
}

export interface ShippingRate {
  serviceType: string;
  serviceName: string;
  totalCharges: number;
  currency: string;
  deliveryTimestamp?: string;
  transitTime?: number;
}

export interface ShipmentParams {
  shipper: Address;
  recipient: Address;
  serviceType: string;
  packageDetails: PackageDetails;
  referenceId?: string;
}

export interface ShipmentResult {
  trackingNumber: string;
  labelUrl: string;
  labelBase64?: string;
  rawResponse: unknown;
}

export interface TrackingEvent {
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

  private async getToken(): Promise<string> {
    if (this.accessToken && this.tokenExpiry && new Date() < this.tokenExpiry) {
      return this.accessToken;
    }
    console.log('Fetching new FedEx OAuth2 token...');
    const response = await fetch(`${this.baseUrl}/oauth/token`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
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
    this.tokenExpiry = new Date(Date.now() + 55 * 60 * 1000);
    console.log('FedEx OAuth2 token obtained');
    return this.accessToken!;
  }

  async validateAddress(address: Address): Promise<AddressValidationResult> {
    const token = await this.getToken();
    const response = await fetch(`${this.baseUrl}/address/v1/addresses/resolve`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
      body: JSON.stringify({
        addressesToValidate: [{
          address: {
            streetLines: address.streetLines,
            city: address.city,
            stateOrProvinceCode: address.stateOrProvinceCode,
            postalCode: address.postalCode,
            countryCode: address.countryCode,
          },
        }],
      }),
    });
    const data = await response.json();
    if (!response.ok) {
      console.error('FedEx Address Validation error:', data);
      return { valid: false, error: data.errors?.[0]?.message || 'Address validation failed' };
    }
    const result = data.output?.resolvedAddresses?.[0];
    if (!result) return { valid: false, error: 'No validation result' };
    const isValid = result.classification === 'VALID' || result.classification === 'STANDARDIZED';
    if (!isValid && result.parsedAddress) {
      return {
        valid: false,
        suggestions: [{
          streetLines: result.parsedAddress.streetLines || address.streetLines,
          city: result.parsedAddress.city || address.city,
          stateOrProvinceCode: result.parsedAddress.stateOrProvinceCode,
          postalCode: result.parsedAddress.postalCode || address.postalCode,
          countryCode: result.parsedAddress.countryCode || address.countryCode,
        }],
      };
    }
    return { valid: isValid };
  }

  async getRates(params: RateParams): Promise<ShippingRate[]> {
    const token = await this.getToken();
    const response = await fetch(`${this.baseUrl}/rate/v1/rates/quotes`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
      body: JSON.stringify({
        accountNumber: { value: this.config.accountNumber },
        requestedShipment: {
          shipper: { address: { streetLines: params.shipper.streetLines, city: params.shipper.city, stateOrProvinceCode: params.shipper.stateOrProvinceCode, postalCode: params.shipper.postalCode, countryCode: params.shipper.countryCode } },
          recipient: { address: { streetLines: params.recipient.streetLines, city: params.recipient.city, stateOrProvinceCode: params.recipient.stateOrProvinceCode, postalCode: params.recipient.postalCode, countryCode: params.recipient.countryCode } },
          pickupType: 'DROPOFF_AT_FEDEX_LOCATION',
          rateRequestType: ['ACCOUNT', 'LIST'],
          requestedPackageLineItems: [{ weight: params.packageDetails.weight, dimensions: params.packageDetails.dimensions }],
        },
      }),
    });
    const data = await response.json();
    if (!response.ok) {
      console.error('FedEx Rate API error:', data);
      throw new Error(data.errors?.[0]?.message || 'Rate calculation failed');
    }
    const rateReplyDetails = data.output?.rateReplyDetails || [];
    const rates: ShippingRate[] = rateReplyDetails.map((detail: Record<string, unknown>) => ({
      serviceType: detail.serviceType,
      serviceName: detail.serviceName || detail.serviceType,
      totalCharges: (detail.ratedShipmentDetails as Array<Record<string, unknown>>)?.[0]?.totalNetCharge || 0,
      currency: (detail.ratedShipmentDetails as Array<Record<string, unknown>>)?.[0]?.currency || 'USD',
      deliveryTimestamp: (detail.commit as Record<string, unknown>)?.dateDetail ? ((detail.commit as Record<string, unknown>).dateDetail as Record<string, unknown>).dayFormat : undefined,
      transitTime: (detail.commit as Record<string, unknown>)?.transitDays,
    }));
    rates.sort((a, b) => a.totalCharges - b.totalCharges);
    return rates;
  }

  async createShipment(params: ShipmentParams): Promise<ShipmentResult> {
    const token = await this.getToken();
    const response = await fetch(`${this.baseUrl}/ship/v1/shipments`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
      body: JSON.stringify({
        accountNumber: { value: this.config.accountNumber },
        requestedShipment: {
          shipper: {
            contact: { personName: params.shipper.personName || 'Seller', phoneNumber: params.shipper.phoneNumber || '0000000000', companyName: params.shipper.companyName },
            address: { streetLines: params.shipper.streetLines, city: params.shipper.city, stateOrProvinceCode: params.shipper.stateOrProvinceCode, postalCode: params.shipper.postalCode, countryCode: params.shipper.countryCode },
          },
          recipient: {
            contact: { personName: params.recipient.personName || 'Buyer', phoneNumber: params.recipient.phoneNumber || '0000000000', companyName: params.recipient.companyName },
            address: { streetLines: params.recipient.streetLines, city: params.recipient.city, stateOrProvinceCode: params.recipient.stateOrProvinceCode, postalCode: params.recipient.postalCode, countryCode: params.recipient.countryCode },
          },
          serviceType: params.serviceType,
          pickupType: 'DROPOFF_AT_FEDEX_LOCATION',
          packagingType: 'YOUR_PACKAGING',
          shippingChargesPayment: { paymentType: 'SENDER' },
          labelSpecification: { labelFormatType: 'COMMON2D', imageType: 'PDF', labelStockType: 'PAPER_4X6' },
          requestedPackageLineItems: [{
            weight: params.packageDetails.weight,
            dimensions: params.packageDetails.dimensions,
            customerReferences: params.referenceId ? [{ customerReferenceType: 'CUSTOMER_REFERENCE', value: params.referenceId }] : undefined,
          }],
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
    if (!trackingNumber || !labelBase64) throw new Error('Missing tracking number or label in FedEx response');
    return { trackingNumber, labelUrl: '', labelBase64, rawResponse: data };
  }

  async trackShipment(trackingNumber: string): Promise<TrackingEvent[]> {
    const token = await this.getToken();
    const response = await fetch(`${this.baseUrl}/track/v1/trackingnumbers`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
      body: JSON.stringify({
        includeDetailedScans: true,
        trackingInfo: [{ trackingNumberInfo: { trackingNumber } }],
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
      for (const event of (result.scanEvents || [])) {
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
    events.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
    return events;
  }
}

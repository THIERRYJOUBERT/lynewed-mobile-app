// Shared FedEx API Client - Ship only
export interface FedExConfig { clientId: string; clientSecret: string; accountNumber: string; environment: 'sandbox' | 'production'; }
export interface Address { streetLines: string[]; city: string; stateOrProvinceCode?: string; postalCode: string; countryCode: string; personName?: string; phoneNumber?: string; companyName?: string; }
export interface PackageDetails { weight: { units: 'KG' | 'LB'; value: number }; dimensions: { units: 'CM' | 'IN'; length: number; width: number; height: number }; }
export interface ShipmentParams { shipper: Address; recipient: Address; serviceType: string; packageDetails: PackageDetails; referenceId?: string; }
export interface ShipmentResult { trackingNumber: string; labelUrl: string; labelBase64?: string; rawResponse: unknown; }

export class FedExClient {
  private config: FedExConfig;
  private accessToken: string | null = null;
  private tokenExpiry: Date | null = null;
  private baseUrl: string;
  constructor(config: FedExConfig) { this.config = config; this.baseUrl = config.environment === 'sandbox' ? 'https://apis-sandbox.fedex.com' : 'https://apis.fedex.com'; }
  private async getToken(): Promise<string> {
    if (this.accessToken && this.tokenExpiry && new Date() < this.tokenExpiry) return this.accessToken;
    console.log('Fetching new FedEx OAuth2 token...');
    const response = await fetch(`${this.baseUrl}/oauth/token`, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: new URLSearchParams({ grant_type: 'client_credentials', client_id: this.config.clientId, client_secret: this.config.clientSecret }) });
    if (!response.ok) {
      const rawBody = await response.text();
      console.error(`FedEx OAuth failed (HTTP ${response.status}):`, rawBody);
      try {
        const errData = JSON.parse(rawBody);
        const code = errData.errors?.[0]?.code || `HTTP_${response.status}`;
        const message = errData.errors?.[0]?.message || rawBody;
        throw new Error(JSON.stringify({ error: `FedEx OAuth failed: ${code} - ${message}`, code }));
      } catch (e) { if (e instanceof SyntaxError) throw new Error(JSON.stringify({ error: `FedEx OAuth failed: ${rawBody}`, code: `HTTP_${response.status}` })); throw e; }
    }
    const data = await response.json();
    this.accessToken = data.access_token;
    this.tokenExpiry = new Date(Date.now() + 55 * 60 * 1000);
    console.log('FedEx OAuth2 token obtained');
    return this.accessToken!;
  }
  async createShipment(params: ShipmentParams): Promise<ShipmentResult> {
    const token = await this.getToken();
    const response = await fetch(`${this.baseUrl}/ship/v1/shipments`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
      body: JSON.stringify({
        accountNumber: { value: this.config.accountNumber },
        requestedShipment: {
          shipper: { contact: { personName: params.shipper.personName || 'Seller', phoneNumber: params.shipper.phoneNumber || '0000000000', companyName: params.shipper.companyName }, address: { streetLines: params.shipper.streetLines, city: params.shipper.city, stateOrProvinceCode: params.shipper.stateOrProvinceCode, postalCode: params.shipper.postalCode, countryCode: params.shipper.countryCode } },
          recipient: { contact: { personName: params.recipient.personName || 'Buyer', phoneNumber: params.recipient.phoneNumber || '0000000000', companyName: params.recipient.companyName }, address: { streetLines: params.recipient.streetLines, city: params.recipient.city, stateOrProvinceCode: params.recipient.stateOrProvinceCode, postalCode: params.recipient.postalCode, countryCode: params.recipient.countryCode } },
          serviceType: params.serviceType, pickupType: 'DROPOFF_AT_FEDEX_LOCATION', packagingType: 'YOUR_PACKAGING',
          shippingChargesPayment: { paymentType: 'SENDER' },
          labelSpecification: { labelFormatType: 'COMMON2D', imageType: 'PDF', labelStockType: 'PAPER_4X6' },
          requestedPackageLineItems: [{ weight: params.packageDetails.weight, dimensions: params.packageDetails.dimensions, customerReferences: params.referenceId ? [{ customerReferenceType: 'CUSTOMER_REFERENCE', value: params.referenceId }] : undefined }],
        },
      }),
    });
    const data = await response.json();
    if (!response.ok) { console.error('FedEx Ship API error:', data); throw new Error(data.errors?.[0]?.message || 'Shipment creation failed'); }
    const csd = data.output?.transactionShipments?.[0]?.completedShipmentDetail;
    const trackingNumber = csd?.masterTrackingNumber || csd?.trackingIdNumber;
    const labelBase64 = csd?.shipmentDocuments?.[0]?.encodedLabel;
    if (!trackingNumber || !labelBase64) throw new Error('Missing tracking number or label');
    return { trackingNumber, labelUrl: '', labelBase64, rawResponse: data };
  }
}

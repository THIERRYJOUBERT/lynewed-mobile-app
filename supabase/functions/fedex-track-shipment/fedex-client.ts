// Shared FedEx API Client - Track only
export interface FedExConfig { clientId: string; clientSecret: string; accountNumber: string; environment: 'sandbox' | 'production'; }
export interface TrackingEvent { code: string; description: string; timestamp: string; location?: string; city?: string; country?: string; }

export class FedExClient {
  private config: FedExConfig;
  private accessToken: string | null = null;
  private tokenExpiry: Date | null = null;
  private baseUrl: string;
  constructor(config: FedExConfig) { this.config = config; this.baseUrl = config.environment === 'sandbox' ? 'https://apis-sandbox.fedex.com' : 'https://apis.fedex.com'; }
  private async getToken(): Promise<string> {
    if (this.accessToken && this.tokenExpiry && new Date() < this.tokenExpiry) return this.accessToken;
    const response = await fetch(`${this.baseUrl}/oauth/token`, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: new URLSearchParams({ grant_type: 'client_credentials', client_id: this.config.clientId, client_secret: this.config.clientSecret }) });
    if (!response.ok) throw new Error(`FedEx OAuth failed: ${await response.text()}`);
    const data = await response.json();
    this.accessToken = data.access_token;
    this.tokenExpiry = new Date(Date.now() + 55 * 60 * 1000);
    return this.accessToken!;
  }
  async trackShipment(trackingNumber: string): Promise<TrackingEvent[]> {
    const token = await this.getToken();
    const response = await fetch(`${this.baseUrl}/track/v1/trackingnumbers`, { method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }, body: JSON.stringify({ includeDetailedScans: true, trackingInfo: [{ trackingNumberInfo: { trackingNumber } }] }) });
    const data = await response.json();
    if (!response.ok) { console.error('FedEx Track error:', data); throw new Error(data.errors?.[0]?.message || 'Tracking failed'); }
    const events: TrackingEvent[] = [];
    for (const result of (data.output?.completeTrackResults?.[0]?.trackResults || [])) {
      for (const event of (result.scanEvents || [])) {
        events.push({ code: event.eventType || 'UNKNOWN', description: event.eventDescription || 'Unknown event', timestamp: event.date || new Date().toISOString(), location: `${event.scanLocation?.city || ''}, ${event.scanLocation?.stateOrProvinceCode || ''} ${event.scanLocation?.countryCode || ''}`.trim(), city: event.scanLocation?.city, country: event.scanLocation?.countryCode });
      }
    }
    events.sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
    return events;
  }
}

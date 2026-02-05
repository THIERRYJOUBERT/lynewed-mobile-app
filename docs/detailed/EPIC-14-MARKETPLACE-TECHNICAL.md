# EPIC-14 Marketplace - Documentation Technique

> Date : 2026-02-05 | Status : COMPLETE | 26/26 stories | 500+ tests

---

## Vue d'ensemble

Marketplace de revente de robes et chaussures de mariage entre mariees. Commission plateforme 10%. Shipping mondial via FedEx. Paiements via Stripe Connect Express.

**Source PRD** : `docs/specs/MISSION-01-EVOLUTIONS-2026.md` Section 11 (APP-08)

---

## Architecture Technique

### Stack

| Composant | Technologie |
|-----------|-------------|
| Frontend | Flutter (Clean Architecture) |
| Backend | Supabase (PostgreSQL + Edge Functions + Storage + Realtime) |
| Paiements | Stripe Connect Express |
| Shipping | FedEx API (Rate, Ship, Track) |
| Notifications | FCM + deep links |

### Clean Architecture (80 fichiers Flutter)

```
lib/features/marketplace/
├── domain/
│   ├── entities/        (14 fichiers)
│   ├── repositories/    (6 interfaces)
│   └── usecases/        (5 use cases)
├── data/
│   ├── datasources/     (2 remote datasources)
│   ├── repositories/    (6 implementations)
│   └── [brands_data, sizes_data]
└── presentation/
    ├── pages/           (13 pages)
    ├── widgets/         (31 widgets)
    └── sheets/          (1 sheet)
```

---

## Database (7 tables + 2 buckets)

### Tables

| Table | Role | RLS | Relations |
|-------|------|-----|-----------|
| `marketplace_listings` | Annonces (dress/shoes) | 5 policies | seller_id → profiles |
| `marketplace_photos` | Photos annonces (5-10) | CASCADE | listing_id → listings |
| `marketplace_offers` | Offres acheteurs | Buyer/Seller | listing_id + buyer_id |
| `marketplace_transactions` | Transactions completes | Buyer/Seller | listing_id + offer_id |
| `marketplace_messages` | Chat par annonce | Participants | listing_id + sender/receiver |
| `fedex_events` | Audit log shipping | Read-only | transaction_id |
| `cgvu_acceptances` | Acceptations CGVU | Owner only | user_id + type |

### Storage Buckets

| Bucket | Usage | Politique |
|--------|-------|-----------|
| `marketplace-listings` | Photos annonces | Public read, owner write |
| `marketplace-labels` | Etiquettes FedEx PDF | Owner read only |

### Indexes notables

- `marketplace_listings`: category, status, seller_id, created_at, (latitude, longitude)
- `marketplace_offers`: listing_id + status, buyer_id, expires_at
- `marketplace_transactions`: buyer_id, seller_id, status

---

## Entities (14)

| Entity | Champs cles | Pattern |
|--------|-------------|---------|
| `MarketplaceListing` | id, sellerId, title, category (dress/shoes), priceCents, size, designerBrand, condition (new/excellent/good/fair), country, status (draft/active/reserved/sold/deleted), coverPhotoStoragePath | Immutable + copyWith + fromJson/toJson |
| `MarketplacePhoto` | id, listingId, storagePath, thumbnailPath, position | CASCADE delete |
| `MarketplaceOffer` | id, listingId, buyerId, amountCents, message, status (pending/accepted/rejected/expired/withdrawn), expiresAt | 48h expiration |
| `MarketplaceTransaction` | id, listingId, offerId, sellerId, buyerId, itemPriceCents, shippingCostCents, platformFeeCents (10%), sellerPayoutCents (90%), stripePaymentIntentId, fedexTrackingNumber, status | Lifecycle complet |
| `MarketplaceMessage` | id, listingId, senderId, receiverId, content, isRead | Realtime |
| `MarketplaceConversation` | listingId, otherUserId, otherUserName, lastMessage, unreadCount | Aggregation chat |
| `ShippingAddress` | streetLines, city, postalCode, countryCode, stateOrProvinceCode, personName, phoneNumber | FedEx format |
| `ShippingRate` | rateId, serviceName, serviceType, priceCents, deliveryDays | FedEx Rate API |
| `ShippingLabel` | trackingNumber, labelUrl (PDF) | FedEx Ship API |
| `TrackingEvent` | eventType, eventDescription, eventTimestamp, location | FedEx Track API |
| `FedexEvent` | Raw event + parsed fields | Audit log |
| `ListingFilter` | category, minPrice, maxPrice, sizes, brands, conditions, sleeveLengths, countryCode, searchRadius | Filtres avances |
| `SellerProfile` | id, displayName, avatarUrl, listingsCount | Profil public vendeur |
| `OfferDisplayModel` | Offer + buyer profile info | UI display model |

---

## Repositories (6 interfaces + 6 implementations)

| Interface | Implementation | Methodes cles |
|-----------|----------------|---------------|
| `MarketplaceRepository` | `SupabaseMarketplaceRepository` | createListing, getListings, getFilteredListings, uploadPhotos, getPhotoUrls, getSellerInfo |
| `MarketplaceChatRepository` | `SupabaseMarketplaceChatRepository` | sendMessage, getMessages (Realtime stream), getConversations, markAsRead |
| `MarketplaceOfferRepository` | `SupabaseMarketplaceOfferRepository` | createOffer, acceptOffer, rejectOffer, withdrawOffer, getOffersForListing |
| `MarketplaceTransactionRepository` | `SupabaseMarketplaceTransactionRepository` | createCheckoutSession, getTransaction, getMyPurchases, getMySales, acceptBuyerCgvu |
| `StripeConnectRepository` | `StripeConnectRepositoryImpl` | createAccount, getAccountStatus, getOnboardingUrl |
| `FedExRepository` | `FedExRepositoryImpl` | calculateRates, createShipment, getTrackingEvents |

---

## Edge Functions (5)

| Fonction | Trigger | Action |
|----------|---------|--------|
| `create-stripe-connect-account` | POST depuis app | Cree compte Stripe Express pour vendeur |
| `stripe-connect-webhook` | Webhook Stripe | Gere account.updated events |
| `fedex-calculate-rate` | POST depuis checkout | Calcule tarifs FedEx (priority/standard) |
| `fedex-create-shipment` | POST apres paiement | Genere etiquette + tracking number |
| `fedex-track-shipment` | Cron hourly + GET | Poll status livraison, maj transaction |

### Cron Job

- `fedex-tracking-poll` : Toutes les heures, poll FedEx Track API pour transactions `shipped`, maj status si `delivered`.

---

## Pages UI (13)

| Page | Route | Role |
|------|-------|------|
| `MarketplaceFeedPage` | `/marketplace` | Grille annonces + filtres + pagination infinie |
| `ListingDetailPage` | `/marketplace/listing/:id` | Detail annonce + carousel photos + actions |
| `CreateListingPage` | `/marketplace/create` | Formulaire creation (photos, details, location) |
| `MarketplaceChatListPage` | `/marketplace/chat` | Liste conversations |
| `MarketplaceChatPage` | - | Chat Realtime par annonce |
| `MyOffersPage` | `/marketplace/offers` | Offres envoyees (acheteur) |
| `ReceivedOffersPage` | - | Offres recues (vendeur) |
| `CheckoutPage` | `/marketplace/checkout` | Adresse + shipping + paiement |
| `OrderConfirmationPage` | `/marketplace/order-confirmation` | Confirmation post-paiement |
| `TransactionDetailPage` | `/marketplace/transactions` | Detail transaction (vendeur) |
| `BuyerTransactionPage` | - | Detail transaction (acheteur) |
| `SellerDashboardPage` | - | Dashboard vendeur (annonces + ventes) |
| `StripeSetupPage` | `/stripeSetup` | Onboarding Stripe Connect |

---

## Integrations App Existante

### Navigation

- **NavBarBridesWidget** : Tab 3 "Market" (Icons.shopping_bag_outlined) ajoute, tabs 4-6 decales
- **HomeBridesWidget** : Section HomeMarketplacePreview (5 annonces recentes, scroll horizontal)
- **Routes** : 10+ routes ajoutees dans `routes.dart` et `nav.dart`
- **Deep Links** : `lynewed://marketplace/payment-success`, `lynewed://marketplace/payment-cancel`

### DI (injection_container.dart)

- 6 repositories enregistres
- 5 use cases enregistres
- 2 datasources enregistres

### Map (EPIC-13 synergies)

- Filter chip "Marketplace" (bride-only) dans `map_page.dart`
- Navigation vers `ListingDetailPage` depuis marker
- Navigation vers `MarketplaceChatPage` depuis marker contact

---

## Decisions Techniques

| Decision | Pourquoi | Impact |
|----------|----------|--------|
| Montants en USD cents (int) | Eviter erreurs float | `price_cents INTEGER` partout |
| Commission 10% fixe | PRD APP-08 | `platform_fee = item_price * 0.10` calcule serveur |
| Stripe Connect Express | Onboarding simplifie | Moins de friction vs Custom |
| FedEx worldwide | Support multi-pays | Address Validation obligatoire |
| Offres expirent 48h | Balance UX vendeur/acheteur | `expires_at`, pg_cron cleanup |
| 7j avant completion | Protection acheteur post-livraison | Transaction workflow |
| Photos 5-10 obligatoires | Qualite annonces | Validation frontend + backend |
| CGVU scroll + checkbox | Conformite juridique | cgvu_acceptances avec timestamp |
| Chat par annonce | Contexte clair | Un thread par listing+user pair |
| Entities immutables | State predictable | copyWith + == + hashCode partout |

---

## Tests (500+)

| Couche | Fichiers | Tests |
|--------|----------|-------|
| Domain entities | 14 | Serialization, equality, copyWith |
| Domain use cases | 5 | Success + error cases |
| Data repositories | 6 | Mock Supabase calls |
| Data datasources | 2 | Mock Edge Function calls |
| Presentation pages | 13 | Widget tests (render, interaction, states) |
| Presentation widgets | 11+ | Unit + widget tests |
| Map integration | 1 | Filter toggles + navigation |
| Navigation | 2 | Routes + deep links |

**Total** : 500+ tests marketplace, 3069+ tests projet, 0 lint warnings.

---

## Flux Utilisateur

### Vendeur

```
1. Accepter CGVU vendeur
2. Configurer Stripe Connect Express
3. Creer annonce (5-10 photos, details, prix)
4. Recevoir offres → accepter/refuser
5. Acheteur paie → generer etiquette FedEx
6. Envoyer colis → tracking automatique
7. Livraison confirmee → payout 90% apres 7j
```

### Acheteur

```
1. Parcourir feed / filtrer / carte
2. Voir detail annonce
3. Contacter vendeur (chat) ou faire offre
4. Offre acceptee → checkout (adresse + shipping + paiement)
5. Accepter CGVU acheteur
6. Payer via Stripe
7. Suivre colis (tracking timeline)
8. Livraison confirmee → transaction complete
```

---

## Timeline Implementation

| Date | Milestone |
|------|-----------|
| 2026-01-28 | Epic cree depuis PRD APP-08 |
| 2026-02-04 | Phase 1 : 7 tables DB + 2 buckets + RLS |
| 2026-02-04 | Phase 2 : CGVU + Stripe Connect (3 stories) |
| 2026-02-04 | Phase 3 : FedEx 3 Edge Functions + cron |
| 2026-02-05 | Phase 4 : Frontend Core (feed, detail, create, filters, chat) |
| 2026-02-05 | Phase 5 : Transactions (offres, checkout, labels, tracking) |
| 2026-02-05 | Phase 6 : Polish (notifications, map, dashboard, navbar) |
| 2026-02-05 | **EPIC-14 COMPLETE** |

---

## Pre-Production Checklist

- [ ] FedEx production certification (sandbox → prod credentials)
- [ ] CGVU textes valides par avocat
- [ ] Privacy policy mise a jour
- [ ] Stripe Connect webhook production endpoint
- [ ] Load testing Edge Functions
- [ ] Performance profiling (feed scroll, photo carousel)
- [ ] Security audit RLS policies

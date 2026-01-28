# Story S24: Marqueurs marketplace sur carte

## Description
En tant qu'acheteuse, je veux voir les annonces marketplace sur la carte, afin de trouver des articles pres de chez moi.

## Criteres d'Acceptance (Gherkin)

- [ ] Given active listings with location When user views map with marketplace toggle ON Then dress listings show dress icon And shoe listings show shoe icon
- [ ] Given a marketplace marker When user taps it Then listing detail page opens
- [ ] Given the map filters panel When user toggles "Marketplace" Then marketplace markers appear/disappear
- [ ] Given listings clustered in same area When zoomed out Then markers should cluster with count
- [ ] Given the map view When loading marketplace markers Then loading should not block other map functionality

## Fichiers Concernes

### A Creer
- `lib/features/marketplace/presentation/widgets/marketplace_map_marker.dart` - Custom marker
- `lib/features/marketplace/domain/usecases/get_listings_for_map.dart` - Use case

### A Modifier
- `lib/features/map/presentation/pages/map_page.dart` - Add marketplace markers
- `lib/features/map/presentation/widgets/map_filter_panel.dart` - Add marketplace toggle
- `lib/features/map/data/repositories/map_repository_impl.dart` - Fetch marketplace listings
- `lib/features/map/domain/entities/map_marker.dart` - Add marketplace marker type

## Notes Techniques

### Marker Types
```dart
enum MapMarkerType {
  professional,  // Existing
  venue,         // Existing
  marketplaceDress,  // New
  marketplaceShoes,  // New
}
```

### Custom Marker Icons
```dart
// Using flutter_map or google_maps_flutter
class MarketplaceMapMarker extends StatelessWidget {
  final ListingEntity listing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToListing(context, listing),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: listing.category == 'dress'
            ? Colors.pink.shade100
            : Colors.purple.shade100,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [BoxShadow(...)],
        ),
        child: Icon(
          listing.category == 'dress'
            ? Icons.checkroom  // Dress icon
            : Icons.shopping_bag,  // Shoes icon
          color: listing.category == 'dress'
            ? Colors.pink.shade700
            : Colors.purple.shade700,
          size: 24,
        ),
      ),
    );
  }
}
```

### Map Filter Integration
```dart
class MapFilterPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Existing filters...
        FilterToggle(
          label: 'Professionals',
          icon: Icons.business,
          value: _showProfessionals,
          onChanged: (v) => setState(() => _showProfessionals = v),
        ),

        FilterToggle(
          label: 'Venues',
          icon: Icons.location_city,
          value: _showVenues,
          onChanged: (v) => setState(() => _showVenues = v),
        ),

        // New marketplace toggle
        FilterToggle(
          label: 'Marketplace',
          icon: Icons.shopping_bag,
          value: _showMarketplace,
          onChanged: (v) => setState(() => _showMarketplace = v),
        ),
      ],
    );
  }
}
```

### Fetch Marketplace Listings for Map
```dart
Future<List<MapMarkerData>> getMarketplaceMarkers(LatLngBounds bounds) async {
  final response = await supabase
    .from('marketplace_listings')
    .select('id, title, category, price_cents, latitude, longitude, photos:marketplace_photos(storage_path)')
    .eq('status', 'active')
    .not('latitude', 'is', null)
    .not('longitude', 'is', null)
    .gte('latitude', bounds.south)
    .lte('latitude', bounds.north)
    .gte('longitude', bounds.west)
    .lte('longitude', bounds.east)
    .limit(100);  // Limit for performance

  return response.map((json) => MapMarkerData(
    id: json['id'],
    type: json['category'] == 'dress'
      ? MapMarkerType.marketplaceDress
      : MapMarkerType.marketplaceShoes,
    position: LatLng(json['latitude'], json['longitude']),
    data: ListingEntity.fromJson(json),
  )).toList();
}
```

### Clustering (Optional Enhancement)
```dart
// Using flutter_map_marker_cluster
MarkerClusterLayerWidget(
  options: MarkerClusterLayerOptions(
    maxClusterRadius: 80,
    markers: marketplaceMarkers,
    builder: (context, markers) => Container(
      decoration: BoxDecoration(
        color: Colors.pink.shade200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${markers.length}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ),
);
```

### Marker Info Window (On Tap)
```dart
void _onMarkerTap(ListingEntity listing) {
  // Option 1: Navigate directly to detail
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ListingDetailPage(listingId: listing.id),
    ),
  );

  // Option 2: Show info window first
  _showMarkerInfoWindow(listing);
}

void _showMarkerInfoWindow(ListingEntity listing) {
  showModalBottomSheet(
    context: context,
    builder: (_) => ListingMiniCard(
      listing: listing,
      onTap: () {
        Navigator.pop(context);
        _navigateToDetail(listing);
      },
    ),
  );
}
```

## Definition of Done
- [ ] Marketplace markers sur la carte
- [ ] Icones differentes dress/shoes
- [ ] Toggle marketplace dans filtres map
- [ ] Tap marker ouvre detail
- [ ] Markers clusteres si necessaire
- [ ] Performance acceptable (limit, bounds)
- [ ] Tests unitaires
- [ ] `flutter analyze --fatal-infos` passe

## Estimation
**Points** : 3
**Complexite** : Faible
**Risque** : Faible (integration map existante)

## Dependances
- S01 (marketplace_listings avec latitude/longitude)
- EPIC-13 (infrastructure filtres map si necessaire)

## Stories Dependantes
- Aucune

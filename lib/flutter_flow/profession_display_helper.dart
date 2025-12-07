import '/backend/schema/enums/enums.dart';

/// Helper pour afficher les noms de professions de manière lisible
String getProfessionDisplayName(Profession profession) {
  switch (profession) {
    case Profession.PHOTOGRAPHER:
      return 'Photographer';
    case Profession.FILMMAKER:
      return 'Filmmaker';
    case Profession.PLANNER:
      return 'Planner';
    case Profession.MAKEUP:
      return 'Make-up';
    case Profession.HAIRDRESSER:
      return 'Hairdresser';
    case Profession.DESIGNER:
      return 'Designer';
    case Profession.BRIDALDESIGNER:
      return 'Bridal Designer';
    case Profession.VENUE:
      return 'Venue';
    case Profession.BRIDALSHOP:
      return 'Bridal Shop';
    case Profession.FLORIST:
      return 'Florist';
    case Profession.PHOTOMOVIE:
      return 'Photo/Movie';
    case Profession.MAKEUPARTIST:
      return 'Make-up Artist';
    case Profession.EVENTDESIGNER:
      return 'Event Designer';
    case Profession.OTHER:
      return 'Other';
    // 🌍 Global professions (available everywhere)
    case Profession.MUSIC:
      return 'Music';
    case Profession.STATIONERY:
      return 'Stationery';
    // 🇮🇳 India-only professions
    case Profession.CATERER:
      return 'Caterer';
    case Profession.BRIDALWEARDESIGNER:
      return 'Bridal Wear Designer';
    // 🌍 Global-only professions (not in India)
    case Profession.JEWELLER:
      return 'Jeweller';
    case Profession.CONTENTCREATOR:
      return 'Content Creator';
    default:
      return profession.name;
  }
}

/// Helper pour afficher les types de marqueurs de manière lisible
String getMapMarkerTypeDisplayName(MapMarkerType markerType) {
  switch (markerType) {
    case MapMarkerType.professional:
      return 'Professional';
    case MapMarkerType.proFixedLocation:
      return 'Pro Fixed Location';
        case MapMarkerType.professionalAlert:
      return 'Alert';
    case MapMarkerType.weddingPin:
      return 'Wedding Pin';
    case MapMarkerType.poiPrivate:
      return 'Private POI';
    // searchTarget supprimé dans la refactorisation map
    default:
      return markerType.name;
  }
}

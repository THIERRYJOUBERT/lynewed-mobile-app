import 'package:collection/collection.dart';

enum UserRole {
  bride,
  professional,
}

enum SubscriptionTierType {
  inactive,
  trial,
  earlyAccess,
  premiumVisibility,
  ultimateAccess,
}

enum Profession {
  PHOTOGRAPHER,
  FILMMAKER,
  PLANNER,
  MAKEUP,
  HAIRDRESSER,
  DESIGNER,
  BRIDALDESIGNER,
  VENUE,
  BRIDALSHOP,
  FLORIST,
  PHOTOMOVIE,
  MAKEUPARTIST,
  EVENTDESIGNER,
  OTHER,
}

enum MapMarkerType {
  professional,
  proFixedLocation,
  professionalAlert,
  weddingPin,
  poiPrivate,
}

enum MapActionType {
  none,
  locateUser,
  moveToTarget,
  zoomIn,
  zoomOut,
  fitBounds,
}

enum DistanceUnit {
  km,
  miles,
}

enum MessageType {
  text,
  image,
  audio,
}

enum ConnectionRequestSource {
  wishlist,
  weddingPin,
  map,
  alert,
  proToPro,
}

enum ConnectionRequestStatus {
  pending,
  accepted,
  declined,
}

enum ConversationStatus {
  active,
  archived,
  pending,
  declined,
  blocked,
  reportedPending,
}

enum AlertStatus {
  active,
  expired,
}

enum VideoSessionStatus {
  pending,
  accepted,
  declined,
  missed,
  completed,
  cancelled,
}

enum NotificationType {
  chatMessage,
  connectionRequest,
  connectionRequestAccepted,
  connectionRequestDeclined,
  wishlistAdd,
  professionalAlert,
  professionalAlertReminder24h,
  videoIncoming,
  wedPublished,
  weddingPinMatch,
}

enum RoomType {
  private,
  public,
}

enum PermissionType {
  LOCATION,
  CAMERA,
  PHOTOS,
  MICROPHONE,
  NOTIFICATIONS,
}

enum MapStyleType {
  normal,
  satellite,
  terrain,
  hybrid,
}

enum ChatEntryStatus {
  roomReady,
  requestPending,
  notAllowed,
  blocked,
  error,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (UserRole):
      return UserRole.values.deserialize(value) as T?;
    case (SubscriptionTierType):
      return SubscriptionTierType.values.deserialize(value) as T?;
    case (Profession):
      return Profession.values.deserialize(value) as T?;
    case (MapMarkerType):
      return MapMarkerType.values.deserialize(value) as T?;
    case (MapActionType):
      return MapActionType.values.deserialize(value) as T?;
    case (DistanceUnit):
      return DistanceUnit.values.deserialize(value) as T?;
    case (MessageType):
      return MessageType.values.deserialize(value) as T?;
    case (ConnectionRequestSource):
      return ConnectionRequestSource.values.deserialize(value) as T?;
    case (ConnectionRequestStatus):
      return ConnectionRequestStatus.values.deserialize(value) as T?;
    case (ConversationStatus):
      return ConversationStatus.values.deserialize(value) as T?;
    case (AlertStatus):
      return AlertStatus.values.deserialize(value) as T?;
    case (VideoSessionStatus):
      return VideoSessionStatus.values.deserialize(value) as T?;
    case (NotificationType):
      return NotificationType.values.deserialize(value) as T?;
    case (RoomType):
      return RoomType.values.deserialize(value) as T?;
    case (PermissionType):
      return PermissionType.values.deserialize(value) as T?;
    case (MapStyleType):
      return MapStyleType.values.deserialize(value) as T?;
    case (ChatEntryStatus):
      return ChatEntryStatus.values.deserialize(value) as T?;
    default:
      return null;
  }
}

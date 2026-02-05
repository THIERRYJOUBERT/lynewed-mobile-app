import '/backend/schema/enums/enums.dart';

/// Configuration d'un type de notification avec ses règles d'affichage par rôle.
/// 
/// Définit quels types de notifications sont visibles et configurables
/// selon le rôle de l'utilisateur et son niveau d'abonnement.
class NotificationTypeConfig {
  final String type;
  final String titleKey;
  final String descriptionBrideKey;
  final String descriptionProKey;
  final bool visibleForBride;
  final bool visibleForPro;
  final SubscriptionTierType? requiredTier; // null = tous les tiers
  final bool isActive; // false = type obsolète/code mort

  const NotificationTypeConfig({
    required this.type,
    required this.titleKey,
    required this.descriptionBrideKey,
    required this.descriptionProKey,
    this.visibleForBride = true,
    this.visibleForPro = true,
    this.requiredTier,
    this.isActive = true,
  });

  /// Vérifie si ce type de notification est visible pour l'utilisateur donné.
  bool isVisibleFor({
    required UserRole role,
    SubscriptionTierType? subscriptionTier,
  }) {
    if (!isActive) return false;
    
    // Vérifier le rôle
    if (role == UserRole.bride && !visibleForBride) return false;
    if (role == UserRole.professional && !visibleForPro) return false;
    
    // Vérifier le tier d'abonnement si requis
    if (requiredTier != null && subscriptionTier != null) {
      return _tierMeetsRequirement(subscriptionTier, requiredTier!);
    }
    
    return true;
  }

  /// Vérifie si le tier actuel satisfait le tier requis.
  bool _tierMeetsRequirement(SubscriptionTierType current, SubscriptionTierType required) {
    const tierOrder = [
      SubscriptionTierType.inactive,
      SubscriptionTierType.trial,
      SubscriptionTierType.earlyAccess,
      SubscriptionTierType.premiumVisibility,
      SubscriptionTierType.ultimateAccess,
    ];
    
    final currentIndex = tierOrder.indexOf(current);
    final requiredIndex = tierOrder.indexOf(required);
    
    return currentIndex >= requiredIndex;
  }

  String getDescription(UserRole role) {
    return role == UserRole.bride ? descriptionBrideKey : descriptionProKey;
  }
}

/// Configuration de tous les types de notifications actifs.
/// 
/// ## Architecture à deux systèmes:
/// 
/// ### Notifications Transactionnelles (Edge Function notifications_outbox_drain)
/// - chatMessage, connectionRequest, connectionRequestAccepted, wishlistAdd, videoIncoming
/// - Déclenchées par des triggers SQL sur les tables sources
/// - Settings configurables par l'utilisateur
/// 
/// ### Notifications Broadcast (Edge Function send-broadcast-notification)
/// - Wedding of the Week, Replays, Annonces générales
/// - Envoyées manuellement depuis l'Admin Panel
/// - Utilisent des deep links lynewed://[page]
/// - PAS de settings utilisateur (tout le monde les reçoit)
class NotificationTypesConfig {
  static const List<NotificationTypeConfig> all = [
    // === NOTIFICATIONS TRANSACTIONNELLES ===
    
    // chatMessage - Tous les utilisateurs
    NotificationTypeConfig(
      type: 'chatMessage',
      titleKey: 'Private messages',
      descriptionBrideKey: 'Receive an alert for each new message in a private conversation.',
      descriptionProKey: 'Receive an alert for each new message in a private conversation.',
      visibleForBride: true,
      visibleForPro: true,
    ),
    
    // connectionRequest - Brides reçoivent, Pros envoient
    NotificationTypeConfig(
      type: 'connectionRequest',
      titleKey: 'Contact requests',
      descriptionBrideKey: 'Receive notifications when a professional sends you a contact request.',
      descriptionProKey: 'Get notified when another professional contacts you.',
      visibleForBride: true,
      visibleForPro: true,
    ),
    
    // connectionRequestAccepted - Pros reçoivent quand Bride accepte
    NotificationTypeConfig(
      type: 'connectionRequestAccepted',
      titleKey: 'Request accepted',
      descriptionBrideKey: 'Get notified when your contact request is accepted.',
      descriptionProKey: 'Get notified when a Bride accepts your contact request.',
      visibleForBride: false, // Brides n'envoient pas de demandes
      visibleForPro: true,
    ),
    
    // wishlistAdd - Pros Ultimate uniquement
    NotificationTypeConfig(
      type: 'wishlistAdd',
      titleKey: 'Added to wishlist',
      descriptionBrideKey: '', // Non visible pour Brides
      descriptionProKey: 'Receive a personalized notification when a Bride adds you to her wishlist.',
      visibleForBride: false,
      visibleForPro: true,
      requiredTier: SubscriptionTierType.ultimateAccess,
    ),
    
    // videoIncoming - Tous les utilisateurs
    NotificationTypeConfig(
      type: 'videoIncoming',
      titleKey: 'Video calls',
      descriptionBrideKey: 'Receive notifications for incoming video calls.',
      descriptionProKey: 'Receive notifications for incoming video calls.',
      visibleForBride: true,
      visibleForPro: true,
    ),
    
    // marketplaceNewMessage - Both roles (sellers AND buyers can receive messages)
    NotificationTypeConfig(
      type: 'marketplaceNewMessage',
      titleKey: 'Marketplace messages',
      descriptionBrideKey: 'Get notified when someone messages you about a marketplace listing.',
      descriptionProKey: 'Get notified when someone messages you about a marketplace listing.',
      visibleForBride: true,
      visibleForPro: true,
    ),

    // === NOTIFICATIONS BROADCAST (Admin Panel) ===
    
    // wedPublished - Wedding of the Week - Tous les utilisateurs
    NotificationTypeConfig(
      type: 'wedPublished',
      titleKey: 'Wedding of the Week',
      descriptionBrideKey: 'Get notified when a new Wedding of the Week is published.',
      descriptionProKey: 'Get notified when a new Wedding of the Week is published.',
      visibleForBride: true,
      visibleForPro: true,
    ),
    
    // replayPublished - Replays - Tous les utilisateurs
    NotificationTypeConfig(
      type: 'replayPublished',
      titleKey: 'New Replays',
      descriptionBrideKey: 'Get notified when new video replays are available.',
      descriptionProKey: 'Get notified when new video replays are available.',
      visibleForBride: true,
      visibleForPro: true,
    ),
  ];

  /// Retourne les types de notifications visibles pour l'utilisateur.
  static List<NotificationTypeConfig> getVisibleTypes({
    required UserRole? role,
    SubscriptionTierType? subscriptionTier,
  }) {
    if (role == null) return [];
    return all.where((config) => config.isVisibleFor(
      role: role,
      subscriptionTier: subscriptionTier,
    )).toList();
  }
}

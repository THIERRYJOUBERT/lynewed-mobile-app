/// Route path constants for the Lynewed application.
///
/// This file provides a centralized registry of all route paths used in the
/// application. It serves as a single source of truth for navigation paths,
/// ensuring consistency between FlutterFlow legacy pages and Clean Architecture
/// feature modules.
///
/// Usage:
/// ```dart
/// context.pushNamed(RouteNames.chatDetails,
///   queryParameters: {'roomId': roomId});
/// // or
/// context.go(AppRoutes.chatDetails);
/// ```
///
/// Route categories:
/// - Auth: Authentication and onboarding flows
/// - Bride: Bride-specific pages
/// - Pro: Professional-specific pages
/// - Shared: Pages used by both user types
/// - Features: Clean Architecture feature modules
library;

/// Route path constants.
///
/// All paths start with '/' and follow the existing FlutterFlow naming
/// conventions to ensure backward compatibility.
abstract final class AppRoutes {
  // ============================================
  // Root
  // ============================================
  static const String root = '/';

  // ============================================
  // Auth Routes
  // ============================================

  /// Sign up page for email registration
  static const String signUp = '/signUpEmailPage';

  /// Sign in page for email authentication
  static const String signIn = '/signInEmailPage';

  /// Password recovery page
  static const String forgotPassword = '/forgotPasswordPage';

  /// Welcome/landing page for authentication
  static const String authWelcome = '/authWelcomePage';

  /// Password reset confirmation page
  static const String resetPassword = '/ResetPasswordNewPage';

  /// Professional sign in page
  static const String signInPro = '/signInEmailPagePro';

  /// Professional password setup page
  static const String setPasswordPro = '/setPasswordPagePro';

  /// Initial routing gate after app launch
  static const String startupGate = '/startupGate';

  /// Bride onboarding wizard
  static const String onboardingBridesWizard = '/onboardingBridesWizard';

  // ============================================
  // Bride Routes
  // ============================================

  /// Bride home/dashboard page
  static const String homeBrides = '/homeBrides';

  /// Bride feed page showing professional content
  static const String feedBrides = '/feedBrides';

  /// Bride messages/conversations list (legacy)
  static const String messagesBrides = '/messagesBrides';

  /// Bride map view for finding professionals
  static const String mapBrides = '/mapBridesLarge';

  /// Bride profile editing page
  static const String editProfileBrides = '/editProfileBrides';

  /// Favorite professionals list
  static const String favProList = '/favProList';

  /// Feed detail viewer for professional content
  static const String feedDetailViewer = '/feedDetailViewer';

  // ============================================
  // Pro Routes
  // ============================================

  /// Professional dashboard page
  static const String dashboardPro = '/dashboardPro';

  /// Professional messages/conversations list (legacy)
  static const String messagesPro = '/messagesPro';

  /// Professional map view for seeing brides
  static const String mapPro = '/mapProLarge';

  /// Public profile view for professionals
  static const String publicProProfileView = '/publicProProfileView';

  /// Professional wishlist management
  static const String wishlistPro = '/wishlistPro';

  /// Weddings hub for professionals
  static const String weddingsHubPro = '/weddingsHubPro';

  // ============================================
  // Shared Routes
  // ============================================

  /// Professional details page
  static const String proDetails = '/proDetails';

  /// Profile page for both brides and pros
  static const String profileBridesAndPro = '/profileBridesAndPro';

  /// User preferences page
  static const String preference = '/preference';

  /// App permissions settings page
  static const String settingsPermissions = '/settingsPermissions';

  /// Wedding of the week showcase
  static const String weddingOfTheWeek = '/weddingOfTheWeek';

  /// Support/help page
  static const String support = '/support';

  /// Replay content listing page
  static const String contentReplay = '/contentReplay';

  /// Video replay player page
  static const String replayPlayerPage = '/replayPlayerPage';

  /// Portfolio image gallery viewer
  static const String portfolioImageViewer = '/portfolioImageViewer';

  /// Video call page
  static const String videoCallPage = '/videoCallPage';

  /// WOW carousel viewer
  static const String wowViewerCarrousel = '/wowViewerCarrousel';

  /// WOW simple viewer
  static const String wowSimpleViewer = '/wowSimpleViewer';

  // ============================================
  // Feature Routes (Clean Architecture)
  // ============================================

  /// Notifications list page
  static const String notifications = '/notificationsPage';

  /// Notification settings page
  static const String notificationSettings = '/notificationSettings';

  /// Chat conversation details page
  static const String chatDetails = '/chatDetailsPage';

  /// Messages/conversations list (Clean Architecture)
  static const String messages = '/messages';

  /// My wedding page for brides
  static const String myWedding = '/myWedding';

  /// Budget management page
  static const String budget = '/budget';

  /// Wedding agenda page
  static const String agenda = '/agenda';

  /// Inspirations gallery page
  static const String inspirations = '/inspirations';

  /// Guest list management page
  static const String guests = '/guests';

  /// Map page (Clean Architecture)
  static const String map = '/map';

  // ============================================
  // Deep Link Routes
  // ============================================

  /// Deep link for chat room: lynewed://chat/{roomId}
  static String chatDeepLink(String roomId) => '/chatDetailsPage?roomId=$roomId';

  /// Deep link for profile: lynewed://profile/{profileId}
  static String profileDeepLink(String profileId) =>
      '/proDetails?profileId=$profileId';

  /// Deep link for wedding: lynewed://wedding/{weddingId}
  static String weddingDeepLink(String weddingId) =>
      '/myWedding?weddingId=$weddingId';
}

/// Route name constants for named navigation.
///
/// These match the routeName static properties on page widgets, ensuring
/// consistency with go_router named navigation.
abstract final class RouteNames {
  // ============================================
  // Auth
  // ============================================
  static const String signUp = 'SignUpEmailPage';
  static const String signIn = 'SignInEmailPage';
  static const String forgotPassword = 'ForgotPasswordPage';
  static const String authWelcome = 'AuthWelcomePage';
  static const String resetPassword = 'ResetPasswordNewPage';
  static const String signInPro = 'SignInEmailPagePro';
  static const String setPasswordPro = 'SetPasswordPagePro';
  static const String startupGate = 'StartupGate';
  static const String onboardingBridesWizard = 'OnboardingBridesWizard';

  // ============================================
  // Bride
  // ============================================
  static const String homeBrides = 'HomeBrides';
  static const String feedBrides = 'FeedBrides';
  static const String messagesBrides = 'MessagesBrides';
  static const String mapBrides = 'MapBridesLarge';
  static const String editProfileBrides = 'EditProfileBrides';
  static const String favProList = 'FavProList';
  static const String feedDetailViewer = 'FeedDetailViewer';

  // ============================================
  // Pro
  // ============================================
  static const String dashboardPro = 'DashboardPro';
  static const String messagesPro = 'MessagesPro';
  static const String mapPro = 'MapProLarge';
  static const String publicProProfileView = 'PublicProProfileView';
  static const String wishlistPro = 'WishlistPro';
  static const String weddingsHubPro = 'weddingsHubPro';

  // ============================================
  // Shared
  // ============================================
  static const String proDetails = 'ProDetails';
  static const String profileBridesAndPro = 'ProfileBridesAndPro';
  static const String preference = 'Preference';
  static const String settingsPermissions = 'SettingsPermissions';
  static const String weddingOfTheWeek = 'WeddingOfTheWeek';
  static const String support = 'Support';
  static const String contentReplay = 'ContentReplay';
  static const String replayPlayerPage = 'ReplayPlayerPage';
  static const String portfolioImageViewer = 'PortfolioImageViewer';
  static const String videoCallPage = 'VideoCallPage';
  static const String wowViewerCarrousel = 'WowViewerCarrousel';
  static const String wowSimpleViewer = 'WowSimpleViewer';

  // ============================================
  // Features (Clean Architecture)
  // ============================================
  static const String notifications = 'NotificationsPage';
  static const String notificationSettings = 'NotificationSettings';
  static const String chatDetails = 'ChatDetailsPage';
  static const String messages = 'Messages';
  static const String myWedding = 'myWedding';
  static const String budget = 'budget';
  static const String agenda = 'agenda';
  static const String inspirations = 'inspirations';
  static const String guests = 'guests';
  static const String map = 'MapPage';
}

// Custom code actions barrel export.
//
// This file exports all legacy custom actions used by FlutterFlow pages.
//
// ## Migration Status (EPIC-01 S40)
//
// ### Removed Actions (migrated to Clean Architecture):
// - getAlertItemDetailsRpc -> lib/features/map/data/datasources/supabase_map_datasource.dart
// - fetchAlertMotifsAction -> Not used, removed
// - createProfessionalAlertAction -> lib/features/map/data/datasources/supabase_map_datasource.dart
//
// ### Video Call Actions (bridge to Agora widget):
// These actions delegate to AgoraVideoViewWidget static methods.
// They are kept for FlutterFlow page compatibility but the actual
// Agora SDK integration is in custom_code/widgets/agora_video_view.dart.
// - agoraToggleMute, agoraToggleCamera, agoraSwitchCamera, agoraEndCall
// - startVideoSessionAction, getAgoraTokenAction, updateVideoSessionStatusAction
//
// ### Google Places Actions:
// These use flutter_google_places_sdk for autocomplete and place details.
// - getPlacePredictions, getPlaceDetails, getPlaceDetailsRich
//
// ### Utility Actions (stable, production):
// - checkAndRequestPermission - Permission handler wrapper
// - requestAppReview - In-app review for iOS/Android
// - setupDeeplinkListener, getInitialDeepLink - Deep link handling
// - pickLocalImage - Image picker wrapper

// ignore_for_file: deprecated_member_use_from_same_package

// Google Places SDK actions
export 'get_place_predictions.dart' show getPlacePredictions;
export 'get_place_details.dart' show getPlaceDetails;
export 'get_place_details_rich.dart' show getPlaceDetailsRich;

// Session and Profile actions
export 'load_initial_session_data.dart' show loadInitialSessionData;
export 'save_user_preferences.dart' show saveUserPreferences;
export 'save_profile_fields.dart' show saveProfileFields;

// Feed and Professional actions
export 'get_feed_professionals_action.dart' show getFeedProfessionalsAction;
export 'toggle_wishlist_action.dart' show toggleWishlistAction;
export 'get_pro_item_details_action.dart' show getProItemDetailsAction;
export 'get_portfolio_feed_action.dart' show getPortfolioFeedAction;
export 'get_favorited_professionals_action.dart'
    show getFavoritedProfessionalsAction;
export 'get_wishlisted_by_brides_action.dart' show getWishlistedByBridesAction;

// Legal and Auth actions
export 'check_tos_accepted.dart' show checkTosAccepted;
export 'insert_legal_acceptance.dart' show insertLegalAcceptance;
export 'sign_up_bride.dart' show signUpBride;
export 'call_delete_account_edge_function.dart'
    show callDeleteAccountEdgeFunction;

// Chat and Messaging actions
export 'get_rooms_with_unread_counts_action.dart'
    show getRoomsWithUnreadCountsAction;
export 'get_pending_contact_requests_action.dart'
    show getPendingContactRequestsAction;
export 'get_public_chat_rooms_for_brides_action.dart'
    show getPublicChatRoomsForBridesAction;
export 'join_public_room_if_needed_action.dart'
    show joinPublicRoomIfNeededAction;
export 'send_text_message_action.dart' show sendTextMessageAction;
export 'upload_and_send_images_action.dart' show uploadAndSendImagesAction;
export 'create_signed_url_for_chat_media_action.dart'
    show createSignedUrlForChatMediaAction;
export 'upload_and_send_audio_action.dart' show uploadAndSendAudioAction;
export 'open_or_prepare_contact_action.dart' show openOrPrepareContactAction;

// Video Call actions (bridge to AgoraVideoViewWidget)
export 'agora_toggle_mute.dart' show agoraToggleMute;
export 'agora_toggle_camera.dart' show agoraToggleCamera;
export 'agora_switch_camera.dart' show agoraSwitchCamera;
export 'agora_end_call.dart' show agoraEndCall;
export 'start_video_session_action.dart' show startVideoSessionAction;
export 'get_agora_token_action.dart' show getAgoraTokenAction;
export 'update_video_session_status_action.dart'
    show updateVideoSessionStatusAction;
export 'handle_video_session_timeout.dart' show handleVideoSessionTimeout;

// Content actions
export 'fetch_replays_bundle.dart' show fetchReplaysBundle;
export 'get_latest_wed_article.dart' show getLatestWedArticle;
export 'get_all_wed_articles.dart' show getAllWedArticles;
export 'get_wed_article_by_id.dart' show getWedArticleById;

// Notification actions
export 'init_push_notifications.dart' show initPushNotifications;
export 'mark_notification_as_read.dart' show markNotificationAsRead;
export 'get_unread_notifications_count.dart' show getUnreadNotificationsCount;
export 'get_unread_messages_count_action.dart' show getUnreadMessagesCountAction;
export 'handle_notification_redirection.dart'
    show handleNotificationRedirection;
export 'refresh_unread_counts.dart' show refreshUnreadCounts;

// Utility actions
export 'get_initial_deep_link.dart' show getInitialDeepLink;
export 'setup_deeplink_listener.dart'
    show setupDeeplinkListener, cancelDeeplinkListener;
export 'check_and_request_permission.dart' show checkAndRequestPermission;
export 'pick_local_image.dart' show pickLocalImage;
export 'upload_avatar.dart' show uploadAvatar;
export 'get_device_locale.dart' show getDeviceLocale;
export 'get_user_market_region.dart' show getUserMarketRegion;
export 'request_app_review.dart' show requestAppReview;

// Alert actions (used by dashboard)
export 'get_active_alerts_action.dart' show getActiveAlertsAction;

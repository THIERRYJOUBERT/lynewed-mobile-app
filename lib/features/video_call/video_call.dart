/// Video call feature module.
///
/// Provides video calling functionality using Agora SDK including:
/// - Video session management
/// - Call controls (mute, camera, switch camera)
/// - Real-time video streaming
///
/// ## Architecture Notes (EPIC-01 S40)
///
/// This module provides Clean Architecture abstractions for video calls:
/// - [VideoCallRepository] - Interface for session CRUD
/// - [VideoCallRepositoryImpl] - Supabase implementation
/// - [VideoCallCubit] - State management for calls
///
/// ### Legacy Integration
///
/// The actual Agora SDK integration remains in `custom_code/widgets/agora_video_view.dart`
/// due to its tight coupling with FlutterFlow-generated pages. The legacy actions in
/// `custom_code/actions/` (agoraToggleMute, agoraToggleCamera, etc.) are thin wrappers
/// that delegate to AgoraVideoViewWidget static methods.
///
/// Session creation still uses `custom_code/actions/start_video_session_action.dart`
/// which handles:
/// - Creating DB record via Supabase
/// - Triggering push notification drain
/// - Setting up timeout handler
///
/// Token generation uses `custom_code/actions/get_agora_token_action.dart` which
/// calls the `agora_token_issue` Edge Function with retry logic.
library;

// Domain layer
export 'domain/entities/call_status.dart';
export 'domain/entities/video_session.dart';
export 'domain/repositories/video_call_repository.dart';

// Data layer
export 'data/repositories/video_call_repository_impl.dart';

// Presentation layer
export 'presentation/bloc/video_call_cubit.dart';
export 'presentation/bloc/video_call_state.dart';
export 'presentation/pages/video_call_page.dart';
export 'presentation/widgets/video_controls.dart';

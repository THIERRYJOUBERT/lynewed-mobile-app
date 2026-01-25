/// Video call feature module.
///
/// Provides video calling functionality using Agora SDK including:
/// - Video session management
/// - Call controls (mute, camera, switch camera)
/// - Real-time video streaming
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

/// Chat Module - Clean Architecture
/// 
/// Complete chat and contact system for LYNEWED app.
/// 
/// ## Architecture
/// ```
/// lib/features/chat/
/// ├── domain/           # Business logic layer
/// │   ├── entities/     # Data classes
/// │   └── repositories/ # Repository interfaces
/// ├── data/             # Data layer
/// │   ├── datasources/  # Remote/local data sources
/// │   └── repositories/ # Repository implementations
/// └── presentation/     # UI layer
///     ├── bloc/         # State management
///     ├── pages/        # Full-screen pages
///     ├── widgets/      # Reusable widgets
///     └── sheets/       # Bottom sheets
/// ```
/// 
/// ## Usage
/// ```dart
/// import 'package:lynewed/features/chat/chat.dart';
/// 
/// // Prepare contact context
/// final result = await contactRepository.prepareContactContext(targetId);
/// 
/// // Handle based on status
/// if (result.data?.requiresContactRequest == true) {
///   // Show ContactRequestSheet for Pro→Bride
///   ContactRequestSheet.show(
///     context: context,
///     targetProfileId: targetId,
///     targetName: 'Marie',
///     source: ContactRequestSource.fromProfile,
///   );
/// } else if (result.data?.canNavigateToChat == true) {
///   // Navigate to chat directly
///   Navigator.pushNamed(context, '/chatDetails', arguments: {...});
/// }
/// ```
/// 
/// ## Key Entities
/// - `ChatMessage` - A single message in a room
/// - `ChatRoom` - A chat room (private or public)
/// - `Conversation` - A conversation item in the list
/// - `ContactRequest` - A pending contact request (Pro→Bride)
/// - `ChatEntryContext` - Result of contact preparation
/// - `BlockedUser` - A blocked user
/// 
/// ## Key Enums
/// - `ChatEntryStatus` - Status from open_or_prepare_contact_context
/// - `ContactRequestSource` - Source of contact request
/// - `MessageType` - Type of message (text, image, audio)
/// - `ConversationStatus` - Status of conversation
/// - `ReportReason` - Reason for reporting a message
library;

// Domain layer
export 'domain/entities/entities.dart';
export 'domain/repositories/repositories.dart';

// Data layer
export 'data/datasources/datasources.dart';
export 'data/repositories/repositories.dart';

// Presentation layer
export 'presentation/bloc/bloc.dart';
export 'presentation/pages/pages.dart';
export 'presentation/widgets/widgets.dart';
export 'presentation/sheets/sheets.dart';

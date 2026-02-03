/// Get My Media Use Case.
///
/// Retrieves all media uploaded by the current guest for a wedding.
library;

import 'package:lynewed_beta/core/utils/result.dart';
import '../entities/guest_media.dart';
import '../repositories/guest_album_repository.dart';

/// Use case to get all media uploaded by the guest.
class GetMyMediaUseCase {
  /// Creates the use case with a repository.
  const GetMyMediaUseCase(this.repository);

  /// The repository for album operations.
  final GuestAlbumRepository repository;

  /// Gets all media uploaded by the current guest for a wedding.
  ///
  /// Returns an empty list if no album exists yet.
  Future<Result<List<GuestMedia>>> call({
    required String weddingId,
  }) {
    return repository.getMyMedia(weddingId: weddingId);
  }
}

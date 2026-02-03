/// Use case to get all guest albums for a wedding.
///
/// The bride sees ALL guest albums automatically (no opt-in filter).
library;

import '../entities/guest_album.dart';
import '../repositories/my_wedding_repository.dart';

/// Use case to get all guest albums for a wedding.
///
/// RLS ensures the bride only sees albums from her own wedding.
/// No opt-in filter - bride sees ALL albums automatically.
class GetGuestAlbumsUseCase {
  /// Creates the use case with the required repository.
  const GetGuestAlbumsUseCase(this.repository);

  /// The repository for accessing wedding data.
  final MyWeddingRepository repository;

  /// Gets all guest albums for the given wedding.
  ///
  /// Returns albums ordered by most recent first.
  /// Empty albums (0 media) are included in the list.
  Future<RepositoryResult<List<GuestAlbum>>> call({
    required String weddingId,
  }) {
    return repository.getGuestAlbums(weddingId: weddingId);
  }
}

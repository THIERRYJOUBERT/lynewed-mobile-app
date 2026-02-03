/// Delete Guest Media Use Case.
///
/// Deletes a media file from the guest's album.
library;

import 'package:lynewed_beta/core/utils/result.dart';
import '../repositories/guest_album_repository.dart';

/// Use case to delete a media file from the guest's album.
class DeleteGuestMediaUseCase {
  /// Creates the use case with a repository.
  const DeleteGuestMediaUseCase(this.repository);

  /// The repository for album operations.
  final GuestAlbumRepository repository;

  /// Deletes a media file from the guest's album.
  ///
  /// Also removes the file from storage.
  Future<Result<void>> call({
    required String mediaId,
  }) {
    return repository.deleteMedia(mediaId: mediaId);
  }
}

/// Wedding Team Cubit for managing wedding team state.
///
/// Handles loading team members, inviting pros, and excluding pros.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/my_wedding_repository.dart';
import 'wedding_team_state.dart';

/// Cubit for managing wedding team state.
///
/// Provides methods for loading team data, inviting professionals,
/// and excluding professionals from the wedding team.
class WeddingTeamCubit extends Cubit<WeddingTeamState> {
  /// Creates a WeddingTeamCubit with the given repository and wedding ID.
  WeddingTeamCubit({
    required MyWeddingRepository repository,
    required this.weddingId,
  })  : _repository = repository,
        super(const WeddingTeamState());

  /// The repository for wedding operations.
  final MyWeddingRepository _repository;

  /// The wedding ID for this cubit instance.
  final String weddingId;

  /// Loads the wedding team data.
  ///
  /// Fetches team members, available pros (contacted), and team chat info.
  /// Emits loading state first, then the loaded data or empty lists on failure.
  Future<void> loadTeam() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    // Fetch all data in parallel
    final results = await Future.wait([
      _repository.getWeddingTeam(weddingId: weddingId),
      _repository.getContactedPros(),
      _repository.getWeddingTeamChat(weddingId: weddingId),
    ]);

    final teamResult = results[0] as RepositoryResult<List<WeddingTeamMember>>;
    final prosResult = results[1] as RepositoryResult<List<ContactedPro>>;
    final chatResult = results[2] as RepositoryResult<WeddingTeamChatInfo?>;

    emit(state.copyWith(
      isLoading: false,
      members: teamResult.isSuccess ? teamResult.data ?? [] : [],
      availablePros: prosResult.isSuccess ? prosResult.data ?? [] : [],
      teamChat: chatResult.isSuccess ? chatResult.data : null,
    ));
  }

  /// Invites a professional to the wedding team.
  ///
  /// On success, reloads the team data to reflect the change.
  /// On failure, emits an error state.
  Future<void> invitePro(String proProfileId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.inviteProToWedding(
      weddingId: weddingId,
      proProfileId: proProfileId,
    );

    if (result.isSuccess) {
      await loadTeam();
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to invite pro',
      ));
    }
  }

  /// Excludes a professional from the wedding team.
  ///
  /// On success, reloads the team data to reflect the change.
  /// On failure, emits an error state.
  Future<void> excludePro(String proProfileId, {String? reason}) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.excludeProFromWedding(
      weddingId: weddingId,
      proProfileId: proProfileId,
      reason: reason,
    );

    if (result.isSuccess) {
      await loadTeam();
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to exclude pro',
      ));
    }
  }

  /// Clears the current error state.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}

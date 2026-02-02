/// Wedding Groups Cubit for managing wedding groups state.
///
/// Handles loading groups, creating groups, managing members, etc.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/wedding_group.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import 'wedding_groups_state.dart';

/// Cubit for managing wedding groups state.
///
/// Provides methods for loading groups, creating/deleting groups,
/// and managing group members.
class WeddingGroupsCubit extends Cubit<WeddingGroupsState> {
  /// Creates a WeddingGroupsCubit with the given repository and wedding ID.
  WeddingGroupsCubit({
    required MyWeddingRepository repository,
    required this.weddingId,
  })  : _repository = repository,
        super(const WeddingGroupsState());

  /// The repository for wedding operations.
  final MyWeddingRepository _repository;

  /// The wedding ID for this cubit instance.
  final String weddingId;

  /// Loads all groups for this wedding.
  ///
  /// Emits loading state first, then the loaded groups or error.
  Future<void> loadGroups() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.getWeddingGroups(weddingId: weddingId);

    if (result.isSuccess) {
      emit(state.copyWith(
        isLoading: false,
        groups: result.data ?? [],
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.error ?? 'Failed to load groups',
      ));
    }
  }

  /// Loads eligible members for adding to groups.
  ///
  /// Call this when opening the member selector.
  Future<void> loadEligibleMembers() async {
    final result = await _repository.getEligibleGroupMembers(weddingId: weddingId);

    if (result.isSuccess) {
      emit(state.copyWith(eligibleMembers: result.data ?? []));
    }
  }

  /// Creates a new wedding group.
  ///
  /// On success, adds the new group to the list and reloads.
  /// On failure, emits an error state.
  Future<bool> createGroup({
    required String name,
    required bool isPublic,
    List<String>? memberProfileIds,
  }) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    final result = await _repository.createWeddingGroup(
      weddingId: weddingId,
      name: name,
      isPublic: isPublic,
      memberProfileIds: memberProfileIds,
    );

    if (result.isSuccess) {
      emit(state.copyWith(isSaving: false));
      // Reload groups to get the full data
      await loadGroups();
      return true;
    } else {
      emit(state.copyWith(
        isSaving: false,
        error: result.error ?? 'Failed to create group',
      ));
      return false;
    }
  }

  /// Updates a wedding group.
  ///
  /// On success, updates the group in the list.
  /// On failure, emits an error state.
  Future<bool> updateGroup({
    required String roomId,
    String? name,
    bool? isPublic,
  }) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    final result = await _repository.updateWeddingGroup(
      roomId: roomId,
      name: name,
      isPublic: isPublic,
    );

    if (result.isSuccess) {
      emit(state.copyWith(isSaving: false));
      // Reload groups to get the updated data
      await loadGroups();
      return true;
    } else {
      emit(state.copyWith(
        isSaving: false,
        error: result.error ?? 'Failed to update group',
      ));
      return false;
    }
  }

  /// Deletes a wedding group.
  ///
  /// On success, removes the group from the list.
  /// On failure, emits an error state.
  Future<bool> deleteGroup(String roomId) async {
    emit(state.copyWith(isSaving: true, clearError: true));

    final result = await _repository.deleteWeddingGroup(roomId: roomId);

    if (result.isSuccess) {
      final updatedGroups = state.groups.where((g) => g.roomId != roomId).toList();
      emit(state.copyWith(
        isSaving: false,
        groups: updatedGroups,
        clearSelectedGroup: state.selectedGroup?.roomId == roomId,
      ));
      return true;
    } else {
      emit(state.copyWith(
        isSaving: false,
        error: result.error ?? 'Failed to delete group',
      ));
      return false;
    }
  }

  /// Selects a group for member management.
  ///
  /// Loads the group members automatically.
  Future<void> selectGroup(WeddingGroup group) async {
    emit(state.copyWith(
      selectedGroup: group,
      isLoadingMembers: true,
      groupMembers: [],
    ));

    final result = await _repository.getWeddingGroupMembers(roomId: group.roomId);

    if (result.isSuccess) {
      emit(state.copyWith(
        isLoadingMembers: false,
        groupMembers: result.data ?? [],
      ));
    } else {
      emit(state.copyWith(
        isLoadingMembers: false,
        error: result.error ?? 'Failed to load group members',
      ));
    }
  }

  /// Clears the selected group.
  void clearSelectedGroup() {
    emit(state.copyWith(
      clearSelectedGroup: true,
      groupMembers: [],
    ));
  }

  /// Adds members to the selected group.
  ///
  /// On success, reloads the group members.
  Future<bool> addMembers(List<String> profileIds) async {
    if (state.selectedGroup == null) return false;

    emit(state.copyWith(isSaving: true, clearError: true));

    final result = await _repository.addGroupMembers(
      roomId: state.selectedGroup!.roomId,
      profileIds: profileIds,
    );

    if (result.isSuccess) {
      emit(state.copyWith(isSaving: false));
      // Reload members
      await selectGroup(state.selectedGroup!);
      // Also reload groups to update member count
      await loadGroups();
      return true;
    } else {
      emit(state.copyWith(
        isSaving: false,
        error: result.error ?? 'Failed to add members',
      ));
      return false;
    }
  }

  /// Removes a member from the selected group.
  ///
  /// On success, removes the member from the list.
  Future<bool> removeMember(String profileId) async {
    if (state.selectedGroup == null) return false;

    emit(state.copyWith(isSaving: true, clearError: true));

    final result = await _repository.removeGroupMembers(
      roomId: state.selectedGroup!.roomId,
      profileIds: [profileId],
    );

    if (result.isSuccess) {
      final updatedMembers =
          state.groupMembers.where((m) => m.profileId != profileId).toList();

      // Update local state
      emit(state.copyWith(
        isSaving: false,
        groupMembers: updatedMembers,
      ));

      // Update selected group member count
      final updatedGroup = state.selectedGroup!.copyWith(
        memberCount: updatedMembers.length,
      );
      final updatedGroups = state.groups.map((g) {
        if (g.roomId == updatedGroup.roomId) {
          return updatedGroup;
        }
        return g;
      }).toList();

      emit(state.copyWith(
        selectedGroup: updatedGroup,
        groups: updatedGroups,
      ));

      return true;
    } else {
      emit(state.copyWith(
        isSaving: false,
        error: result.error ?? 'Failed to remove member',
      ));
      return false;
    }
  }

  /// Clears the current error state.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}

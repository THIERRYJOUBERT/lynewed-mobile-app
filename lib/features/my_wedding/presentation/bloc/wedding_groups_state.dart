/// Wedding Groups State for WeddingGroupsCubit.
///
/// Defines the state for managing wedding groups.
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/wedding_group.dart';

/// State for the wedding groups Cubit.
///
/// Tracks the groups list, loading state, and errors.
@immutable
class WeddingGroupsState {
  /// Creates a wedding groups state.
  const WeddingGroupsState({
    this.groups = const [],
    this.eligibleMembers = const [],
    this.selectedGroup,
    this.groupMembers = const [],
    this.isLoading = false,
    this.isLoadingMembers = false,
    this.isSaving = false,
    this.error,
  });

  /// List of all wedding groups.
  final List<WeddingGroup> groups;

  /// List of eligible members for adding to groups.
  final List<EligibleGroupMember> eligibleMembers;

  /// Currently selected group (for member management).
  final WeddingGroup? selectedGroup;

  /// Members of the selected group.
  final List<GroupMember> groupMembers;

  /// Whether groups are being loaded.
  final bool isLoading;

  /// Whether group members are being loaded.
  final bool isLoadingMembers;

  /// Whether a save operation is in progress.
  final bool isSaving;

  /// Error message, if any.
  final String? error;

  /// Returns the total number of groups.
  int get totalGroups => groups.length;

  /// Returns the default wedding team group (if any).
  WeddingGroup? get defaultGroup => groups.where((g) => g.isDefault).firstOrNull;

  /// Returns custom groups (non-default).
  List<WeddingGroup> get customGroups => groups.where((g) => !g.isDefault).toList();

  /// Returns public groups.
  List<WeddingGroup> get publicGroups =>
      groups.where((g) => g.isPublic && !g.isDefault).toList();

  /// Returns private groups.
  List<WeddingGroup> get privateGroups =>
      groups.where((g) => !g.isPublic && !g.isDefault).toList();

  /// Returns eligible guests (not pros).
  List<EligibleGroupMember> get eligibleGuests =>
      eligibleMembers.where((m) => m.memberType == GroupMemberType.guest).toList();

  /// Returns eligible pros.
  List<EligibleGroupMember> get eligiblePros =>
      eligibleMembers.where((m) => m.memberType == GroupMemberType.pro).toList();

  /// Creates a copy with updated values.
  ///
  /// Use [clearError] to explicitly set error to null.
  WeddingGroupsState copyWith({
    List<WeddingGroup>? groups,
    List<EligibleGroupMember>? eligibleMembers,
    WeddingGroup? selectedGroup,
    bool clearSelectedGroup = false,
    List<GroupMember>? groupMembers,
    bool? isLoading,
    bool? isLoadingMembers,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return WeddingGroupsState(
      groups: groups ?? this.groups,
      eligibleMembers: eligibleMembers ?? this.eligibleMembers,
      selectedGroup: clearSelectedGroup ? null : (selectedGroup ?? this.selectedGroup),
      groupMembers: groupMembers ?? this.groupMembers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMembers: isLoadingMembers ?? this.isLoadingMembers,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeddingGroupsState &&
        listEquals(other.groups, groups) &&
        listEquals(other.eligibleMembers, eligibleMembers) &&
        other.selectedGroup == selectedGroup &&
        listEquals(other.groupMembers, groupMembers) &&
        other.isLoading == isLoading &&
        other.isLoadingMembers == isLoadingMembers &&
        other.isSaving == isSaving &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(groups),
        Object.hashAll(eligibleMembers),
        selectedGroup,
        Object.hashAll(groupMembers),
        isLoading,
        isLoadingMembers,
        isSaving,
        error,
      );
}

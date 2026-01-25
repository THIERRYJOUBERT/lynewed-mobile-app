/// Wedding Team State for WeddingTeamCubit.
///
/// Defines the state for managing the wedding team (professionals).
library;

import 'package:flutter/foundation.dart';

import '../../domain/repositories/my_wedding_repository.dart';

/// State for the wedding team Cubit.
///
/// Tracks the team members, available pros to invite, team chat info,
/// loading state, and errors.
@immutable
class WeddingTeamState {
  /// Creates a wedding team state.
  const WeddingTeamState({
    this.members = const [],
    this.availablePros = const [],
    this.teamChat,
    this.isLoading = false,
    this.error,
  });

  /// List of current wedding team members.
  final List<WeddingTeamMember> members;

  /// List of pros the bride has contacted that can be invited.
  final List<ContactedPro> availablePros;

  /// Wedding team chat room info.
  final WeddingTeamChatInfo? teamChat;

  /// Whether an operation is in progress.
  final bool isLoading;

  /// Error message, if any.
  final String? error;

  /// Returns only active team members.
  List<WeddingTeamMember> get activeMembers =>
      members.where((m) => m.status == 'active').toList();

  /// Returns members who have left or been excluded.
  List<WeddingTeamMember> get leftMembers =>
      members.where((m) => m.status == 'left' || m.status == 'excluded').toList();

  /// Creates a copy with updated values.
  ///
  /// Use [clearError] to explicitly set error to null.
  WeddingTeamState copyWith({
    List<WeddingTeamMember>? members,
    List<ContactedPro>? availablePros,
    WeddingTeamChatInfo? teamChat,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return WeddingTeamState(
      members: members ?? this.members,
      availablePros: availablePros ?? this.availablePros,
      teamChat: teamChat ?? this.teamChat,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeddingTeamState &&
        listEquals(other.members, members) &&
        listEquals(other.availablePros, availablePros) &&
        other.teamChat == teamChat &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(members),
        Object.hashAll(availablePros),
        teamChat,
        isLoading,
        error,
      );
}

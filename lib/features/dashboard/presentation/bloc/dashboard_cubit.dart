/// Dashboard cubit - Clean Architecture
///
/// Manages state for professional dashboard using ChangeNotifier pattern.
/// Loads stats and alerts in parallel.
library;

import 'package:flutter/foundation.dart';
import '../../domain/entities/pro_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import 'dashboard_state.dart';
import 'package:lynewed_beta/features/map/domain/entities/professional_alert.dart';

/// Cubit for managing professional dashboard state
///
/// Provides:
/// - Load dashboard data (stats + alerts)
/// - Refresh dashboard data
/// - Convenience getters for common data
class DashboardCubit extends ChangeNotifier {
  /// Creates a DashboardCubit with optional repository for testing.
  DashboardCubit({
    DashboardRepository? repository,
  }) : _repository = repository ?? DashboardRepositoryImpl();

  final DashboardRepository _repository;

  DashboardState _state = const DashboardInitial();

  /// Current state
  DashboardState get state => _state;

  /// Convenience getter for stats (null if not loaded)
  ProStats? get stats {
    final currentState = _state;
    if (currentState is DashboardLoaded) {
      return currentState.stats;
    }
    return null;
  }

  /// Convenience getter for alerts (empty if not loaded)
  List<ProfessionalAlert> get alerts {
    final currentState = _state;
    if (currentState is DashboardLoaded) {
      return currentState.alerts;
    }
    return const [];
  }

  /// Convenience getter for hasActiveAlerts
  bool get hasActiveAlerts {
    final currentState = _state;
    if (currentState is DashboardLoaded) {
      return currentState.hasActiveAlerts;
    }
    return false;
  }

  /// Emits a new state and notifies listeners
  void _emit(DashboardState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Load dashboard data (stats + alerts in parallel)
  Future<void> loadDashboard() async {
    _emit(const DashboardLoading());

    // Load stats and alerts in parallel with explicit types
    final statsFuture = _repository.getStats();
    final alertsFuture = _repository.getActiveAlerts(limit: 3);

    final statsResult = await statsFuture;
    final alertsResult = await alertsFuture;

    // Check for any failure
    if (statsResult.isFailure) {
      final failure = statsResult.failureOrNull()!;
      _emit(DashboardError(failure.message));
      return;
    }

    if (alertsResult.isFailure) {
      final failure = alertsResult.failureOrNull()!;
      _emit(DashboardError(failure.message));
      return;
    }

    // Both succeeded
    final stats = statsResult.getOrNull()!;
    final alerts = alertsResult.getOrNull() ?? [];

    _emit(DashboardLoaded(
      stats: stats,
      alerts: alerts,
    ));
  }

  /// Refresh dashboard data (background refresh)
  Future<void> refresh() async {
    final currentState = _state;
    if (currentState is! DashboardLoaded) {
      await loadDashboard();
      return;
    }

    // Set refreshing flag
    _emit(currentState.copyWith(isRefreshing: true));

    // Load stats and alerts in parallel with explicit types
    final statsFuture = _repository.getStats();
    final alertsFuture = _repository.getActiveAlerts(limit: 3);

    final statsResult = await statsFuture;
    final alertsResult = await alertsFuture;

    // On any failure, just reset refreshing flag and keep current data
    if (statsResult.isFailure || alertsResult.isFailure) {
      _emit(currentState.copyWith(isRefreshing: false));
      return;
    }

    // Both succeeded
    final stats = statsResult.getOrNull()!;
    final alerts = alertsResult.getOrNull() ?? [];

    _emit(DashboardLoaded(
      stats: stats,
      alerts: alerts,
      isRefreshing: false,
    ));
  }

  /// For testing: set state directly
  @visibleForTesting
  void setStateForTesting(DashboardState newState) {
    _state = newState;
  }

  /// For testing: expose emit method
  @visibleForTesting
  void emit(DashboardState newState) {
    _emit(newState);
  }
}

/// Dashboard state - Clean Architecture
///
/// State classes for DashboardCubit.
library;

import 'package:flutter/foundation.dart';
import 'package:lynewed_beta/features/dashboard/domain/entities/pro_stats.dart';
import 'package:lynewed_beta/features/map/domain/entities/professional_alert.dart';

/// Base state for dashboard
@immutable
sealed class DashboardState {
  const DashboardState();
}

/// Initial state
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Loaded state with stats and alerts
class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.stats,
    required this.alerts,
    this.isRefreshing = false,
  });

  /// Professional statistics
  final ProStats stats;

  /// Active alerts in user's market region
  final List<ProfessionalAlert> alerts;

  /// Whether we're refreshing in background
  final bool isRefreshing;

  /// Whether there are active alerts
  bool get hasActiveAlerts => alerts.isNotEmpty;

  /// Creates a copy with updated fields
  DashboardLoaded copyWith({
    ProStats? stats,
    List<ProfessionalAlert>? alerts,
    bool? isRefreshing,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      alerts: alerts ?? this.alerts,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Error state
class DashboardError extends DashboardState {
  const DashboardError(this.message);

  final String message;
}

/// Dashboard repository interface for Clean Architecture.
///
/// Defines the contract for professional dashboard data operations.
/// Implementation is in the data layer.
library;

import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/map/domain/entities/professional_alert.dart';
import '../entities/pro_stats.dart';

/// Repository interface for professional dashboard operations.
///
/// This abstract class defines all operations for the pro dashboard:
/// - [getStats] - Fetch professional statistics
/// - [getActiveAlerts] - Fetch active alerts in user's market region
abstract class DashboardRepository {
  /// Fetches professional dashboard statistics.
  ///
  /// Returns [Success] with [ProStats], or [Failure] on error.
  Future<Result<ProStats>> getStats();

  /// Fetches active alerts in the user's market region.
  ///
  /// [limit] - Maximum number of alerts to return (default: 3)
  ///
  /// Returns [Success] with list of alerts, or [Failure] on error.
  Future<Result<List<ProfessionalAlert>>> getActiveAlerts({int limit = 3});
}

/// Dashboard feature - Clean Architecture
///
/// Professional dashboard with stats, alerts, and quick actions.
///
/// Usage:
/// ```dart
/// import 'package:lynewed_beta/features/dashboard/dashboard.dart';
/// ```
library;

// Domain
export 'domain/entities/pro_stats.dart';
export 'domain/repositories/dashboard_repository.dart';

// Data
export 'data/repositories/dashboard_repository_impl.dart';

// Presentation
export 'presentation/bloc/dashboard_state.dart';
export 'presentation/bloc/dashboard_cubit.dart';
export 'presentation/pages/dashboard_pro_page.dart';
export 'presentation/widgets/alert_item_widget.dart';

import '/backend/schema/enums/enums.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/core/design/design.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'wotw_history_sheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'wedding_of_the_week_model.dart';
export 'wedding_of_the_week_model.dart';

class WeddingOfTheWeekWidget extends StatefulWidget {
  const WeddingOfTheWeekWidget({super.key});

  static String routeName = 'WeddingOfTheWeek';
  static String routePath = '/weddingOfTheWeek';

  @override
  State<WeddingOfTheWeekWidget> createState() => _WeddingOfTheWeekWidgetState();
}

class _WeddingOfTheWeekWidgetState extends State<WeddingOfTheWeekWidget> {
  late WeddingOfTheWeekModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WeddingOfTheWeekModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.latestArticle = await actions.getLatestWedArticle(
        valueOrDefault<String>(
          FFAppState().currentUserPreferences.defaultLocale,
          'en',
        ),
      );
      _model.wedArticle = _model.latestArticle;
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: LynewedColors.background,
        body: SafeArea(
          bottom: false, // Navbar handles its own bottom safe area
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Header - Design System v3
                  _buildHeader(),
                  
                  // Divider
                  const Divider(height: 1, color: LynewedColors.gray200),
                  
                  // Content - Only show renderer if article exists
                  Expanded(
                    child: _model.wedArticle != null
                        ? custom_widgets.WedArticleRenderer(
                            width: MediaQuery.sizeOf(context).width,
                            height: MediaQuery.sizeOf(context).height,
                            article: _model.wedArticle,
                          )
                        : _buildEmptyState(),
                  ),
                ],
              ),
              
              // Bottom navigation
              Align(
                alignment: Alignment.bottomCenter,
                child: FFAppState().currentUserRole == UserRole.bride
                    ? wrapWithModel(
                        model: _model.navBarBridesModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const NavBarBridesWidget(number: 4),
                      )
                    : wrapWithModel(
                        model: _model.navBarProModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const NavBarProWidget(number: 4),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with title + history icon - Design System v3
  /// Uses same style as Replay page (18px, w500)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'WEDDING OF THE WEEK',
              style: LynewedTextStyles.headlineSmall, // 18px, w500 - same as Replay
            ),
          ),
          // History icon
          GestureDetector(
            onTap: _showHistorySheet,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.history,
                size: 24,
                color: LynewedColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show WOTW history sheet
  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WotwHistorySheet(
        onArticleSelected: (articleId) {
          _loadArticleById(articleId);
        },
      ),
    );
  }

  /// Load a specific article by ID
  Future<void> _loadArticleById(String articleId) async {
    final locale = FFAppState().currentUserPreferences.defaultLocale;
    final article = await actions.getWedArticleById(articleId, locale);
    if (article != null) {
      _model.wedArticle = article;
      safeSetState(() {});
    }
  }

  /// Empty state when no wedding article is available
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 64,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 16),
            Text(
              'No wedding this week',
              style: LynewedTextStyles.titleMedium.copyWith(
                color: LynewedColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check back soon for inspiring wedding stories from our community.',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

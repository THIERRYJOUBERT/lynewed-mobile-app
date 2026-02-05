import '/features/marketplace/presentation/pages/marketplace_feed_page.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'nav_bar_brides_model.dart';
export 'nav_bar_brides_model.dart';

class NavBarBridesWidget extends StatefulWidget {
  const NavBarBridesWidget({
    super.key,
    int? number,
  }) : number = number ?? 1;

  final int number;

  @override
  State<NavBarBridesWidget> createState() => _NavBarBridesWidgetState();
}

class _NavBarBridesWidgetState extends State<NavBarBridesWidget> {
  late NavBarBridesModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NavBarBridesModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84.0,
      child: Stack(
        alignment: const AlignmentDirectional(0.0, 1.0),
        children: [
          Align(
            alignment: const AlignmentDirectional(0.0, 1.0),
            child: Container(
              width: double.infinity,
              height: 84.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab 1: Home
                    _buildTab(
                      context,
                      number: 1,
                      icon: Icons.home_outlined,
                      label: 'Home',
                      onTap: () {
                        _model.number = 1;
                        safeSetState(() {});
                        context.goNamed(
                          HomeBridesWidget.routeName,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                    ),
                    // Tab 2: Feed
                    _buildTab(
                      context,
                      number: 2,
                      icon: Icons.search_sharp,
                      label: 'Feed',
                      onTap: () {
                        _model.number = 2;
                        safeSetState(() {});
                        context.goNamed(
                          FeedBridesWidget.routeName,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                    ),
                    // Tab 3: Marketplace (NEW)
                    _buildTab(
                      context,
                      number: 3,
                      icon: Icons.shopping_bag_outlined,
                      label: 'Market',
                      onTap: () {
                        _model.number = 3;
                        safeSetState(() {});
                        context.goNamed(
                          MarketplaceFeedPage.routeName,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                    ),
                    // Tab 4: Wedding (was 3)
                    _buildTab(
                      context,
                      number: 4,
                      icon: Icons.diamond_outlined,
                      label: 'Wedding',
                      onTap: () {
                        _model.number = 4;
                        safeSetState(() {});
                        context.goNamed(
                          MyWeddingPage.routeName,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                    ),
                    // Tab 5: WOTW (was 4)
                    _buildTab(
                      context,
                      number: 5,
                      icon: Icons.star_border,
                      label: 'WOTW',
                      onTap: () {
                        _model.number = 5;
                        safeSetState(() {});
                        context.goNamed(
                          WeddingOfTheWeekWidget.routeName,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                    ),
                    // Tab 6: Replay (was 5)
                    _buildTab(
                      context,
                      number: 6,
                      icon: Icons.mic_none,
                      label: 'Replay',
                      onTap: () {
                        _model.number = 6;
                        safeSetState(() {});
                        context.goNamed(
                          ContentReplayWidget.routeName,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0.0, -1.0),
            child: Container(
              width: double.infinity,
              height: 1.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single navbar tab with icon and label.
  Widget _buildTab(
    BuildContext context, {
    required int number,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isActive = widget.number == number;
    final color = isActive
        ? FlutterFlowTheme.of(context).primaryText
        : FlutterFlowTheme.of(context).alternate;

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async => onTap(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 23.0,
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                0.0, 5.0, 0.0, 0.0),
            child: Text(
              label,
              style: FlutterFlowTheme.of(context)
                  .bodyLarge
                  .override(
                    fontFamily: 'Haas Grot Text Trial',
                    color: color,
                    fontSize: 11.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

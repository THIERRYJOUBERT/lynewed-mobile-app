import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/compo_finaux/replay_guest_card/replay_guest_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'content_replay_model.dart';
export 'content_replay_model.dart';

class ContentReplayWidget extends StatefulWidget {
  const ContentReplayWidget({super.key});

  static String routeName = 'ContentReplay';
  static String routePath = '/contentReplay';

  @override
  State<ContentReplayWidget> createState() => _ContentReplayWidgetState();
}

class _ContentReplayWidgetState extends State<ContentReplayWidget> {
  late ContentReplayModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ContentReplayModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.replaysBundle = await actions.fetchReplaysBundle();
      _model.featuredReplay = _model.replaysBundle?.firstOrNull;
      _model.otherReplays = _model.replaysBundle!
          .where((e) => e.isFeatured != true)
          .toList()
          .toList()
          .cast<ReplayItemStruct>();
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              if (_model.featuredReplay != null)
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(20.0, 106.0, 20.0, 84.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header section
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LATEST MASTERCLASS',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Haas Grot Text Trial',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Replay from ${dateTimeFormat(
                                    "MMMM d, y",
                                    _model.featuredReplay?.publishedAt,
                                    locale: FFLocalizations.of(context)
                                        .languageCode,
                                  )}',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Haas Grot Text Trial',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            // Titre du replay actif
                            Text(
                              _model.featuredReplay?.title ?? '',
                              style: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 16.0),
                            // Grid des guests 2x2
                            Builder(
                              builder: (context) {
                                final guestsList = _model.featuredReplay?.guests ?? [];
                                final guestsCount = guestsList.length;
                                
                                // Calculer le nombre de lignes nécessaires
                                final rowCount = (guestsCount / 2).ceil();
                                final isScrollable = rowCount > 2;
                                final containerHeight = isScrollable ? 380.0 : (rowCount * 190.0);
                                
                                return Container(
                                  height: containerHeight,
                                  decoration: const BoxDecoration(),
                                  child: isScrollable
                                      ? SingleChildScrollView(
                                          child: _buildGuestsGrid(guestsList),
                                        )
                                      : _buildGuestsGrid(guestsList),
                                );
                              },
                            ),
                            const SizedBox(height: 16.0),
                            // Bouton WATCH THIS PODCAST
                            FFButtonWidget(
                              onPressed: () async {
                                context.pushNamed(
                                  ReplayPlayerPageWidget.routeName,
                                  queryParameters: {
                                    'videoUrl': serializeParam(
                                      _model.featuredReplay?.youtubeUrl,
                                      ParamType.String,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              text: 'WATCH THIS PODCAST',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 48.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32.0),
                        // Section MORE REPLAY
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'MORE REPLAY ?',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Haas Grot Text Trial',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Watch our latest podcasts without limits',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Haas Grot Text Trial',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Builder(
                              builder: (context) {
                                final otherReplays = _model.otherReplays.toList();

                                return ListView.separated(
                                  padding: EdgeInsets.zero,
                                  primary: false,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: otherReplays.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12.0),
                                  itemBuilder: (context, index) {
                                    final replayItem = otherReplays[index];
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        context.pushNamed(
                                          ReplayPlayerPageWidget.routeName,
                                          queryParameters: {
                                            'videoUrl': serializeParam(
                                              replayItem.youtubeUrl,
                                              ParamType.String,
                                            ),
                                          }.withoutNulls,
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primary,
                                          borderRadius:
                                              BorderRadius.circular(0.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              8.0, 12.0, 8.0, 12.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: Image.network(
                                                  valueOrDefault<String>(
                                                    replayItem.thumbnailUrl,
                                                    'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
                                                  ),
                                                  width: 60.0,
                                                  height: 60.0,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(width: 12.0),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      valueOrDefault<String>(
                                                        replayItem.title,
                                                        'Title...',
                                                      ),
                                                      style: FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                'Haas Grot Text Trial',
                                                            color: Colors.white,
                                                            fontSize: 14.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 4.0),
                                                    Text(
                                                      replayItem.guests
                                                          .map((e) => e.fullName)
                                                          .join(', '),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                'Haas Grot Text Trial',
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .accent1,
                                                            fontSize: 12.0,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12.0),
                                              Text(
                                                dateTimeFormat(
                                                  "MM/dd/y",
                                                  replayItem.publishedAt!,
                                                  locale:
                                                      FFLocalizations.of(context)
                                                          .languageCode,
                                                ),
                                                style: FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily:
                                                          'Haas Grot Text Trial',
                                                      color: FlutterFlowTheme.of(
                                                              context)
                                                          .accent1,
                                                      fontSize: 12.0,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Container(
                  width: double.infinity,
                  height: 90.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'REPLAY',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.0, 1.0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 14.0, 0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            height: 1.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondary,
                            ),
                            alignment: const AlignmentDirectional(0.0, 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: Stack(
                  alignment: const AlignmentDirectional(0.0, 1.0),
                  children: [
                    if (FFAppState().currentUserRole == UserRole.bride)
                      Align(
                        alignment: const AlignmentDirectional(0.0, 1.0),
                        child: wrapWithModel(
                          model: _model.navBarBridesModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const NavBarBridesWidget(
                            number: 4,
                          ),
                        ),
                      ),
                    if (FFAppState().currentUserRole == UserRole.professional)
                      wrapWithModel(
                        model: _model.navBarProModel,
                        updateCallback: () => safeSetState(() {}),
                        child: const NavBarProWidget(
                          number: 3,
                        ),
                      ),
                  ],
                ),
              ),
              if (_model.featuredReplay == null)
                Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: wrapWithModel(
                    model: _model.emptyStateModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const EmptyStateWidget(
                      message: 'No replies this month ',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the guests grid (2x2)
  Widget _buildGuestsGrid(List<ReplayGuestItemStruct> guests) {
    final guestsCount = guests.length;
    final rows = <Widget>[];
    
    for (int i = 0; i < guestsCount; i += 2) {
      final leftGuest = guests[i];
      final rightGuest = i + 1 < guestsCount ? guests[i + 1] : null;
      
      rows.add(
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ReplayGuestCardWidget(
                guestName: leftGuest.fullName,
                profession: leftGuest.profession,
                avatarUrl: leftGuest.avatarUrl,
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: rightGuest != null
                  ? ReplayGuestCardWidget(
                      guestName: rightGuest.fullName,
                      profession: rightGuest.profession,
                      avatarUrl: rightGuest.avatarUrl,
                    )
                  : Container(
                      width: MediaQuery.sizeOf(context).width * 0.5,
                      height: 180.0,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
            ),
          ],
        ),
      );
      
      if (i + 2 < guestsCount) {
        rows.add(const SizedBox(height: 10.0));
      }
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}

import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_toggle_icon.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/core/utils/video_url_helpers.dart';
import '/index.dart';
// Chat module imports for reporting
import '/features/chat/presentation/sheets/sheets.dart';
import '/features/chat/data/repositories/contact_repository_impl.dart';
import '/features/map/presentation/sheets/upcoming_travels_sheet.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'pro_details_model.dart';
export 'pro_details_model.dart';

class ProDetailsWidget extends StatefulWidget {
  const ProDetailsWidget({
    super.key,
    required this.proDetails,
  });

  final ProDetailsStruct? proDetails;

  static String routeName = 'ProDetails';
  static String routePath = '/proDetails';

  @override
  State<ProDetailsWidget> createState() => _ProDetailsWidgetState();
}

class _ProDetailsWidgetState extends State<ProDetailsWidget> {
  late ProDetailsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProDetailsModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Initialisation optimiste avec la valeur passée en paramètre
      _model.fav = widget.proDetails!.isFavorited;
      if (mounted) {
        safeSetState(() {});
      }
      
      // Vérifier le statut favori réel depuis la DB (pour synchronisation)
      await _checkFavoriteStatusFromDb();
    });
  }

  /// Vérifie le statut favori réel depuis la table wishlist_items
  /// Permet de synchroniser l'état si modifié ailleurs (map sheet, autre session)
  Future<void> _checkFavoriteStatusFromDb() async {
    if (!mounted) return;
    
    final userId = currentUserUid;
    final proId = widget.proDetails?.proProfileId;
    
    // Seulement pour les brides (les pros n'ont pas de wishlist)
    if (userId.isEmpty || 
        proId == null || 
        proId.isEmpty ||
        FFAppState().currentUserRole != UserRole.bride) {
      return;
    }
    
    try {
      final result = await SupaFlow.client
          .from('wishlist_items')
          .select('bride_profile_id')
          .eq('bride_profile_id', userId)
          .eq('professional_profile_id', proId)
          .maybeSingle();
      
      if (!mounted) return;
      
      final isFavoritedFromDb = result != null;
      
      // Mettre à jour seulement si différent de la valeur actuelle
      if (_model.fav != isFavoritedFromDb) {
        _model.fav = isFavoritedFromDb;
        safeSetState(() {});
      }
    } catch (e) {
      // En cas d'erreur, on garde la valeur initiale
      debugPrint('ProDetails: Failed to check favorite status: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  /// Check if video should be shown instead of slideshow
  /// Based on hasCoverVideo flag AND valid video URL
  bool _shouldShowVideo() {
    final proDetails = widget.proDetails;
    if (proDetails == null) return false;
    
    // Must have hasCoverVideo flag set to true
    if (!proDetails.hasCoverVideo) return false;
    
    // Must have a valid video URL
    final videoUrl = proDetails.profileVideoUrl;
    if (videoUrl.isEmpty) return false;
    
    // Check if it's a valid video URL (YouTube, Vimeo, or direct file)
    return VideoUrlHelpers.isValidVideoUrl(videoUrl);
  }

  /// Build the appropriate video player based on URL type
  Widget _buildVideoPlayer() {
    final videoUrl = widget.proDetails!.profileVideoUrl;
    
    // YouTube URLs use YoutubePlayerWidget
    if (VideoUrlHelpers.isYouTubeUrl(videoUrl)) {
      return SizedBox(
        width: double.infinity,
        height: 250.0,
        child: custom_widgets.YoutubePlayerWidget(
          width: double.infinity,
          height: 250.0,
          youtubeUrl: videoUrl,
        ),
      );
    }
    
    // Vimeo URLs - for now, show placeholder (Phase 2)
    // TODO: Implement Vimeo player when needed
    if (VideoUrlHelpers.isVimeoUrl(videoUrl)) {
      return SizedBox(
        width: double.infinity,
        height: 250.0,
        child: Container(
          color: Colors.black,
          child: const Center(
            child: Text(
              'Vimeo video\n(Coming soon)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
    
    // Direct video files use VideoplayerFilmmaker
    return SizedBox(
      width: double.infinity,
      height: 250.0,
      child: custom_widgets.VideoplayerFilmmaker(
        width: double.infinity,
        height: 250.0,
        videoUrl: videoUrl,
      ),
    );
  }

  /// Show report user sheet
  Future<void> _showReportSheet() async {
    final proDetails = widget.proDetails;
    if (proDetails == null) return;

    final contactRepository = ContactRepositoryImpl();

    await ReportUserSheet.show(
      context: context,
      userName: proDetails.fullName,
      userAvatarUrl: proDetails.avatarUrl,
      onReport: (reason, details) async {
        final result = await contactRepository.reportUser(
          reportedProfileId: proDetails.proProfileId,
          reason: reason,
          details: details,
        );

        if (mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signalement envoyé'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.error ?? 'Erreur lors du signalement'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
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
          height: MediaQuery.sizeOf(context).height * 1.0,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 110.0,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      child: Stack(
                        alignment: const AlignmentDirectional(-1.0, 0.0),
                        children: [
                          // Show slideshow if hasCoverVideo is false OR no valid video URL
                          if (!_shouldShowVideo())
                            Builder(
                              builder: (context) {
                                final portfolio = widget
                                        .proDetails?.slideshowImages
                                        .map((e) => e)
                                        .toList()
                                        .toList() ??
                                    [];

                                return SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: 350.0,
                                  child: Stack(
                                    children: [
                                      PageView.builder(
                                        controller: _model
                                                .pageViewController ??=
                                            PageController(
                                                initialPage: max(
                                                    0,
                                                    min(0,
                                                        portfolio.length - 1))),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: portfolio.length,
                                        itemBuilder: (context, portfolioIndex) {
                                          final portfolioItem =
                                              portfolio[portfolioIndex];
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: Image.network(
                                              valueOrDefault<String>(
                                                portfolioItem,
                                                'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/vq6j64n8aqw5/SCR-20250923-knqk.png',
                                              ),
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              height: 350.0,
                                              fit: BoxFit.cover,
                                              alignment: const Alignment(0.0, -1.0),
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Image.asset(
                                                'assets/images/error_image.png',
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                height: 350.0,
                                                fit: BoxFit.cover,
                                                alignment: const Alignment(0.0, -1.0),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      Align(
                                        alignment:
                                            const AlignmentDirectional(0.0, 1.0),
                                        child: Padding(
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 16.0),
                                          child: smooth_page_indicator
                                              .SmoothPageIndicator(
                                            controller: _model
                                                    .pageViewController ??=
                                                PageController(
                                                    initialPage: max(
                                                        0,
                                                        min(
                                                            0,
                                                            portfolio.length -
                                                                1))),
                                            count: portfolio.length,
                                            axisDirection: Axis.horizontal,
                                            onDotClicked: (i) async {
                                              await _model.pageViewController!
                                                  .animateToPage(
                                                i,
                                                duration:
                                                    const Duration(milliseconds: 500),
                                                curve: Curves.ease,
                                              );
                                              safeSetState(() {});
                                            },
                                            effect: smooth_page_indicator
                                                .SlideEffect(
                                              spacing: 8.0,
                                              radius: 8.0,
                                              dotWidth: 8.0,
                                              dotHeight: 8.0,
                                              dotColor:
                                                  FlutterFlowTheme.of(context)
                                                      .accent1,
                                              activeDotColor: Colors.white,
                                              paintStyle: PaintingStyle.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          // Slideshow navigation arrows (only when showing slideshow)
                          if (!_shouldShowVideo())
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    14.0, 0.0, 0.0, 0.0),
                                child: FlutterFlowIconButton(
                                  borderRadius: 99.0,
                                  buttonSize: 40.0,
                                  fillColor: const Color(0xE6F5F5F5),
                                  icon: Icon(
                                    Icons.arrow_back_ios_outlined,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 20.0,
                                  ),
                                  onPressed: () async {
                                    await _model.pageViewController
                                        ?.previousPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.ease,
                                    );
                                  },
                                ),
                              ),
                            ),
                          if (!_shouldShowVideo())
                            Align(
                              alignment: const AlignmentDirectional(1.0, 0.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 14.0, 0.0),
                                child: FlutterFlowIconButton(
                                  borderRadius: 99.0,
                                  buttonSize: 40.0,
                                  fillColor: const Color(0xE6F5F5F5),
                                  icon: Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    size: 20.0,
                                  ),
                                  onPressed: () async {
                                    await _model.pageViewController?.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.ease,
                                    );
                                  },
                                ),
                              ),
                            ),
                          // Show video player when hasCoverVideo is true and valid URL
                          if (_shouldShowVideo())
                            _buildVideoPlayer(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 24.0, 20.0, 110.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: Image.network(
                                  valueOrDefault<String>(
                                    widget.proDetails?.avatarUrl,
                                    'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png',
                                  ),
                                  width: 40.0,
                                  height: 40.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    valueOrDefault<String>(
                                      widget.proDetails?.fullName,
                                      'Name...',
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Haas Grot Text Trial',
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    valueOrDefault<String>(
                                      widget.proDetails?.profession?.name,
                                      'Profession...',
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Haas Grot Text Trial',
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ].divide(const SizedBox(width: 10.0)),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                child: Text(
                                  valueOrDefault<String>(
                                    widget.proDetails?.description,
                                    'Description...',
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Haas Grot Text Trial',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            thickness: 1.0,
                            color: FlutterFlowTheme.of(context).secondary,
                          ),
                          if (widget.proDetails!.portfolioImages.isNotEmpty)
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              height: 446.0,
                              child: custom_widgets.PortfolioGrid(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 446.0,
                                portfolioImages:
                                    widget.proDetails!.portfolioImages,
                                proDetails: widget.proDetails!,
                              ),
                            ),
                          if (widget.proDetails!.fixedLocations.isNotEmpty)
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LIVE POSITION',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Haas Grot Text Trial',
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Container(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: 300.0,
                                  decoration: const BoxDecoration(),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    height:
                                        MediaQuery.sizeOf(context).height * 1.0,
                                    child: custom_widgets.LynewedMiniMap(
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              1.0,
                                      initialZoom: 14.0,
                                      borderRadius: 0.0,
                                      center: widget.proDetails!.fixedLocations
                                          .firstOrNull!,
                                      markerStyle: MarkerStyleInfoStruct(
                                        avatarUrl:
                                            widget.proDetails?.avatarUrl,
                                        borderColorHex:
                                            functions.professionToStyle(
                                                widget.proDetails?.profession),
                                        isOwn: false,
                                      ),
                                      useLiteMode: false,
                                      onTap: () async {
                                        if (FFAppState().currentUserRole ==
                                            UserRole.bride) {
                                          context.pushNamed(
                                            MapBridesLargeWidget.routeName,
                                            queryParameters: {
                                              'initialCenter': serializeParam(
                                                widget
                                                    .proDetails
                                                    ?.fixedLocations
                                                    .firstOrNull,
                                                ParamType.LatLng,
                                              ),
                                            }.withoutNulls,
                                          );
                                        } else {
                                          context.pushNamed(
                                            MapProLargeWidget.routeName,
                                            queryParameters: {
                                              'initialCenter': serializeParam(
                                                widget
                                                    .proDetails
                                                    ?.fixedLocations
                                                    .firstOrNull,
                                                ParamType.LatLng,
                                              ),
                                            }.withoutNulls,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ].divide(const SizedBox(height: 14.0)),
                            ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 24.0, 0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: Image.network(
                                    valueOrDefault<String>(
                                      widget.proDetails?.avatarUrl,
                                      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png',
                                    ),
                                    width: 40.0,
                                    height: 40.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        valueOrDefault<String>(
                                          widget.proDetails?.fullName,
                                          'Name...',
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  'Haas Grot Text Trial',
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      Text(
                                        valueOrDefault<String>(
                                          widget.proDetails?.profession?.name,
                                          'Profession...',
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  'Haas Grot Text Trial',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    if (widget.proDetails?.instagramUrl !=
                                            null &&
                                        widget.proDetails?.instagramUrl != '')
                                      FlutterFlowIconButton(
                                        borderRadius: 100.0,
                                        buttonSize: 40.0,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .primary,
                                        icon: FaIcon(
                                          FontAwesomeIcons.instagram,
                                          color:
                                              FlutterFlowTheme.of(context).info,
                                          size: 22.0,
                                        ),
                                        onPressed: () async {
                                          await launchURL(
                                              valueOrDefault<String>(
                                            widget.proDetails?.instagramUrl,
                                            'https://www.lynewed.com/',
                                          ));
                                        },
                                      ),
                                    if (widget.proDetails?.websiteUrl !=
                                            null &&
                                        widget.proDetails?.websiteUrl != '')
                                      FlutterFlowIconButton(
                                        borderRadius: 100.0,
                                        buttonSize: 40.0,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .primary,
                                        icon: Icon(
                                          Icons.travel_explore_rounded,
                                          color:
                                              FlutterFlowTheme.of(context).info,
                                          size: 22.0,
                                        ),
                                        onPressed: () async {
                                          await launchURL(
                                              valueOrDefault<String>(
                                            widget.proDetails?.websiteUrl,
                                            'https://www.lynewed.com/',
                                          ));
                                        },
                                      ),
                                    // Upcoming Travels button - always visible
                                    FlutterFlowIconButton(
                                      borderRadius: 100.0,
                                      buttonSize: 40.0,
                                      fillColor: FlutterFlowTheme.of(context)
                                          .primary,
                                      icon: Icon(
                                        Icons.flight_takeoff,
                                        color:
                                            FlutterFlowTheme.of(context).info,
                                        size: 22.0,
                                      ),
                                      onPressed: () async {
                                        await UpcomingTravelsSheet.show(
                                          context: context,
                                          professionalName: widget.proDetails?.fullName ?? 'Professional',
                                        );
                                      },
                                    ),
                                  ].divide(const SizedBox(width: 10.0)),
                                ),
                              ].divide(const SizedBox(width: 10.0)),
                            ),
                          ),
                        ].divide(const SizedBox(height: 14.0)),
                      ),
                    ),
                  ].divide(const SizedBox(height: 0.0)),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Container(
                  width: double.infinity,
                  height: 110.0,
                  decoration: const BoxDecoration(
                    color: Color(0x65FFFFFF),
                  ),
                  child: Align(
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 2.0,
                          sigmaY: 4.0,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 110.0,
                          decoration: const BoxDecoration(
                            color: Color(0x67FFFFFF),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 14.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      20.0, 0.0, 20.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 40.0,
                                            height: 40.0,
                                            decoration: const BoxDecoration(),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                context.safePop();
                                              },
                                              child: Icon(
                                                Icons.arrow_back_ios_new,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                size: 24.0,
                                              ),
                                            ),
                                          ),
                                        ].divide(const SizedBox(width: 14.0)),
                                      ),
                                      Text(
                                        'LYNEWED',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  'Haas Grot Text Trial',
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          // Report button - always visible (except for own profile)
                                          if (widget.proDetails?.proProfileId != currentUserUid)
                                            Container(
                                              width: 40.0,
                                              height: 40.0,
                                              decoration: const BoxDecoration(),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onTap: () async {
                                                  await _showReportSheet();
                                                },
                                                child: Icon(
                                                  Icons.flag_outlined,
                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                  size: 24.0,
                                                ),
                                              ),
                                            ),
                                          // Only show favorite button for brides (adds to wishlist)
                                          if (FFAppState().currentUserRole == UserRole.bride)
                                            Align(
                                              alignment:
                                                  const AlignmentDirectional(0.0, 0.0),
                                              child: Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: const BoxDecoration(),
                                                child: ToggleIcon(
                                                  onPressed: () async {
                                                    // Toggle optimiste pour UI réactive
                                                    safeSetState(() =>
                                                        _model.fav = !_model.fav);
                                                    
                                                    _model.toggleResult =
                                                        await actions
                                                            .toggleWishlistAction(
                                                      widget.proDetails!
                                                          .proProfileId,
                                                    );
                                                    
                                                    // Mettre à jour avec le résultat réel du serveur
                                                    if (_model.toggleResult != null) {
                                                      _model.fav =
                                                          _model.toggleResult!;
                                                      safeSetState(() {});
                                                    }
                                                  },
                                                  value: _model.fav,
                                                  onIcon: Icon(
                                                    Icons.favorite_sharp,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    size: 24.0,
                                                  ),
                                                  offIcon: Icon(
                                                    Icons.favorite_border,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    size: 24.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ].divide(const SizedBox(width: 14.0)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: Container(
                  width: double.infinity,
                  height: 90.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if ((widget.proDetails?.canBeContactedByBride ==
                                    true) ||
                                (widget.proDetails?.proProfileId ==
                                    currentUserUid))
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 20.0, 0.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    await action_blocks.contactChatRoom(
                                      context,
                                      targetProfileID:
                                          widget.proDetails?.proProfileId,
                                    );
                                  },
                                  text: 'Contact',
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
                                          fontWeight: FontWeight.normal,
                                        ),
                                    elevation: 0.0,
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.0, -1.0),
                        child: Container(
                          width: double.infinity,
                          height: 1.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

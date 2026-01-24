import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/core/utils/video_url_helpers.dart';
import '/core/design/design.dart';
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
  
  // Scroll controller for blur effect
  final ScrollController _scrollController = ScrollController();
  bool _showBlur = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProDetailsModel());
    
    // Listen to scroll for blur effect
    _scrollController.addListener(_onScroll);

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
    }
  }

  void _onScroll() {
    // Show blur when scrolled past 20px
    final shouldShowBlur = _scrollController.offset > 20;
    if (shouldShowBlur != _showBlur) {
      setState(() {
        _showBlur = shouldShowBlur;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _model.dispose();

    super.dispose();
  }

  /// Check if video should be shown instead of slideshow
  /// Based on hasCoverVideo flag AND valid video URL
  bool _shouldShowVideo() {
    final proDetails = widget.proDetails;
    if (proDetails == null) {
      return false;
    }
    
    // Must have hasCoverVideo flag set to true
    if (!proDetails.hasCoverVideo) {
      return false;
    }
    
    // Must have a valid video URL
    final videoUrl = proDetails.profileVideoUrl;
    if (videoUrl.isEmpty) {
      return false;
    }
    
    // Check if it's a valid video URL (YouTube, Vimeo, or direct file)
    final isValid = VideoUrlHelpers.isValidVideoUrl(videoUrl);
    return isValid;
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
    
    // Vimeo URLs use VimeoPlayerWidget
    if (VideoUrlHelpers.isVimeoUrl(videoUrl)) {
      return SizedBox(
        width: double.infinity,
        height: 250.0,
        child: custom_widgets.VimeoPlayerWidget(
          width: double.infinity,
          height: 250.0,
          vimeoUrl: videoUrl,
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

  /// Show more menu with Report option (same as professional_details_sheet)
  void _showMoreMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 150,
        MediaQuery.of(context).padding.top + 50,
        20,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'report',
          child: Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                color: Color(0xFF757575),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Report',
                style: LynewedTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'report') {
        _showReportSheet();
      }
    });
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
        body: SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 1.0,
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Spacer for header (SafeArea top + header height ~68px)
                    SizedBox(
                      height: MediaQuery.of(context).padding.top + 68,
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
                                // Use V2 images if available (crop_1x1 for slideshow display)
                                final hasV2 = widget.proDetails?.hasSlideshowImagesV2() ?? false;
                                final v2Images = widget.proDetails?.slideshowImagesV2 ?? [];
                                
                                final portfolio = hasV2
                                    ? v2Images.map((img) => img.crop1x1.isNotEmpty ? img.crop1x1 : img.crop3x4).toList()
                                    : widget.proDetails?.slideshowImages.toList() ?? [];

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
                                            effect: const smooth_page_indicator
                                                .SlideEffect(
                                              spacing: 8.0,
                                              radius: 8.0,
                                              dotWidth: 8.0,
                                              dotHeight: 8.0,
                                              dotColor: LynewedColors.gray200,
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
                                  icon: const Icon(
                                    Icons.arrow_back_ios_outlined,
                                    color: LynewedColors.textPrimary,
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
                                  icon: const Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    color: LynewedColors.textPrimary,
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: LynewedTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    valueOrDefault<String>(
                                      widget.proDetails?.profession?.name,
                                      'Profession...',
                                    ),
                                    style: LynewedTextStyles.bodyMedium.copyWith(
                                          color: LynewedColors.textSecondary,
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
                                  style: LynewedTextStyles.bodyMedium.copyWith(
                                        color: LynewedColors.textSecondary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            thickness: 1.0,
                            color: LynewedColors.gray200,
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
                                  'Live Position',
                                  style: LynewedTextStyles.sectionTitle,
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
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: LynewedTextStyles.bodyMedium.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      Text(
                                        valueOrDefault<String>(
                                          widget.proDetails?.profession?.name,
                                          'Profession...',
                                        ),
                                        style: LynewedTextStyles.bodyMedium.copyWith(
                                              color: LynewedColors.textSecondary,
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
                                          professionalId: widget.proDetails?.proProfileId ?? '',
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
              // Header with dynamic blur on scroll
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: _showBlur 
                        ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                        : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Container(
                      color: _showBlur 
                          ? Colors.white.withValues(alpha: 0.4)
                          : Colors.white,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
                          child: Row(
                            children: [
                              // Back button - same as MessagesPage (44px tap target)
                              GestureDetector(
                                onTap: () => context.safePop(),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.chevron_left,
                                    size: 28,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 4),
                              
                              // Title - same style as MessagesPage
                              Expanded(
                                child: Text(
                                  'Profile',
                                  style: const TextStyle(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              
                              // Right actions - EXACT same as professional_details_sheet
                              // Favorite first, then more_vert, 10px spacing
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Favorite button - only for brides (same style as sheet)
                                  if (FFAppState().currentUserRole == UserRole.bride)
                                    GestureDetector(
                                      onTap: () async {
                                        safeSetState(() => _model.fav = !_model.fav);
                                        _model.toggleResult = await actions.toggleWishlistAction(
                                          widget.proDetails!.proProfileId,
                                        );
                                        if (_model.toggleResult != null) {
                                          _model.fav = _model.toggleResult!;
                                          safeSetState(() {});
                                        }
                                      },
                                      child: Icon(
                                        _model.fav ? Icons.favorite : Icons.favorite_border,
                                        color: _model.fav 
                                            ? Colors.black // Black when favorited
                                            : const Color(0xFF757575), // textSecondary
                                        size: 22,
                                      ),
                                    ),
                                  
                                  // 10px spacing between icons (same as sheet)
                                  if (FFAppState().currentUserRole == UserRole.bride &&
                                      widget.proDetails?.proProfileId != currentUserUid)
                                    const SizedBox(width: 10),
                                  
                                  // More menu - same style as sheet (no background)
                                  if (widget.proDetails?.proProfileId != currentUserUid)
                                    GestureDetector(
                                      onTap: () => _showMoreMenu(context),
                                      child: const Icon(
                                        Icons.more_vert,
                                        color: Color(0xFF757575), // textSecondary
                                        size: 22,
                                      ),
                                    ),
                                ],
                              ),
                            ],
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
                            // Contact button - hide for own profile
                            if ((widget.proDetails?.canBeContactedByBride == true) &&
                                (widget.proDetails?.proProfileId != currentUserUid))
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: LynewedButton(
                                    text: 'Contact',
                                    onPressed: () async {
                                      await action_blocks.contactChatRoom(
                                        context,
                                        targetProfileID: widget.proDetails?.proProfileId,
                                      );
                                    },
                                    type: LynewedButtonType.primary,
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
                          decoration: const BoxDecoration(
                            color: LynewedColors.gray200,
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

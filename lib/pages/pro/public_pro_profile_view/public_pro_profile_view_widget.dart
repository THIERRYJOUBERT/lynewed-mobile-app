import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'public_pro_profile_view_model.dart';
export 'public_pro_profile_view_model.dart';

class PublicProProfileViewWidget extends StatefulWidget {
  const PublicProProfileViewWidget({
    super.key,
    required this.proDetails,
  });

  final ProDetailsStruct? proDetails;

  static String routeName = 'PublicProProfileView';
  static String routePath = '/publicProProfileView';

  @override
  State<PublicProProfileViewWidget> createState() =>
      _PublicProProfileViewWidgetState();
}

class _PublicProProfileViewWidgetState
    extends State<PublicProProfileViewWidget> {
  late PublicProProfileViewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PublicProProfileViewModel());
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
                          if (widget.proDetails?.profession !=
                              Profession.FILMMAKER)
                            Builder(
                              builder: (context) {
                                // Utiliser slideshowImages en priorité, sinon portfolioImages en fallback
                                final slideshowImages = widget
                                        .proDetails?.slideshowImages
                                        .where((e) => e.isNotEmpty)
                                        .toList() ??
                                    [];
                                final portfolioImages = widget
                                        .proDetails?.portfolioImages
                                        .where((e) => e.isNotEmpty)
                                        .toList() ??
                                    [];
                                
                                // Si slideshowImages est vide, utiliser portfolioImages
                                final portfolio = slideshowImages.isNotEmpty
                                    ? slideshowImages
                                    : portfolioImages;

                                // Si aucune image disponible, afficher un placeholder
                                if (portfolio.isEmpty) {
                                  return Container(
                                    width: double.infinity,
                                    height: 350.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.image_outlined,
                                            size: 80.0,
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(
                                                0.0, 16.0, 0.0, 0.0),
                                            child: Text(
                                              'Aucune image de profil',
                                              style: FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Neue Haas Grotesk Text Pro',
                                                    color: FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                    useGoogleFonts: false,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return SizedBox(
                                  width: double.infinity,
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
                                              width: double.infinity,
                                              height: 350.0,
                                              fit: BoxFit.cover,
                                              alignment: const Alignment(0.0, -1.0),
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Image.asset(
                                                'assets/images/error_image.png',
                                                width: double.infinity,
                                                height: 350.0,
                                                fit: BoxFit.cover,
                                                alignment: const Alignment(0.0, -1.0),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (portfolio.length > 1)
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
                          if (widget.proDetails?.profession !=
                              Profession.FILMMAKER)
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
                          if (widget.proDetails?.profession !=
                              Profession.FILMMAKER)
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
                          if (widget.proDetails?.profession ==
                              Profession.FILMMAKER)
                            SizedBox(
                              width: double.infinity,
                              height: 250.0,
                              child: custom_widgets.VideoplayerFilmmaker(
                                width: double.infinity,
                                height: 250.0,
                                videoUrl: widget.proDetails!.profileVideoUrl,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 24.0, 20.0, 110.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
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
                                      mapStyle: MapStyleType.normal,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'PROFESSIONAL PROFILE ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  'Haas Grot Text Trial',
                                              fontSize: 18.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ].divide(const SizedBox(width: 14.0)),
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
                child: wrapWithModel(
                  model: _model.navBarProModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const NavBarProWidget(
                    number: 4,
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

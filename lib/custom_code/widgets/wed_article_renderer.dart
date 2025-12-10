// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
import '/custom_code/actions/index.dart' as actions;
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!


import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/core/utils/video_url_helpers.dart';
import '/custom_code/widgets/youtube_player_widget.dart';
import '/custom_code/widgets/vimeo_player_widget.dart';
import '/custom_code/widgets/videoplayer_filmmaker.dart';
import '/features/map/presentation/sheets/upcoming_travels_sheet.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/core/design/design.dart';

class WedArticleRenderer extends StatefulWidget {
  const WedArticleRenderer({
    super.key,
    this.width,
    this.height,
    this.article,
  });

  final double? width;
  final double? height;
  final WedArticleStruct? article;

  @override
  State<WedArticleRenderer> createState() => _WedArticleRendererState();
}

class _WedArticleRendererState extends State<WedArticleRenderer> {
  PageController? _pageViewController;
  List<String> _allArticleImages = [];

  @override
  void initState() {
    super.initState();
    _extractAllImages();
  }

  @override
  void didUpdateWidget(WedArticleRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.article != oldWidget.article) {
      _extractAllImages();
    }
  }

  void _extractAllImages() {
    if (widget.article == null) return;
    final article = widget.article!;
    final images = <String>[];
    images.addAll(article.coverImages);
    for (var block in article.contentBlocks) {
      if ((block.type == 'single_image' || block.type == 'gallery') &&
          block.imageUrls.isNotEmpty) {
        images.addAll(block.imageUrls);
      }
    }
    setState(() {
      _allArticleImages = images.toSet().toList();
    });
  }

  void _openImageViewer(String clickedImageUrl) {
    final initialIndex = _allArticleImages.indexOf(clickedImageUrl);
    if (initialIndex != -1 && widget.article?.professional != null) {
      context.pushNamed(
        'WowSimpleViewer',
        queryParameters: {
          'portfolioImages':
              serializeParam(_allArticleImages, ParamType.String, isList: true),
          'initialIndex': serializeParam(initialIndex, ParamType.int),
          'proInfo': serializeParam(
              widget.article!.professional, ParamType.DataStruct),
        }.withoutNulls,
      );
    }
  }

  @override
  void dispose() {
    _pageViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.article == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final article = widget.article!;
    _pageViewController ??= PageController(initialPage: 0);

    return ListView(
      padding: EdgeInsets.zero, // Bottom padding handled by last item
      children: [

        // Carrousel
        _buildCoverCarousel(context, article.coverImages),

        // --- MODIFICATION 3 : Alignement à gauche du nom du pro et de sa profession ---
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100), // Cercle parfait
                child: Image.network(
                  article.professional.avatarUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.professional.fullName,
                      style:
                          FlutterFlowTheme.of(context).titleMedium.override(
                                fontFamily: 'Haas Grot Text Trial',
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                    ),
                    Text(
                      article.professional.profession != null
                          ? article.professional.profession!.name
                          : 'Profession',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Haas Grot Text Trial',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 14,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Blocs de contenu
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          primary: false,
          shrinkWrap: true,
          itemCount: article.contentBlocks.length,
          separatorBuilder: (context, index) {
            // Use 8px spacing between image blocks, 20px otherwise
            final currentBlock = article.contentBlocks[index];
            final nextBlock = index + 1 < article.contentBlocks.length 
                ? article.contentBlocks[index + 1] 
                : null;
            final imageTypes = {'single_image', 'gallery'};
            final bothAreImages = imageTypes.contains(currentBlock.type) && 
                nextBlock != null && imageTypes.contains(nextBlock.type);
            return SizedBox(height: bothAreImages ? 8 : 20);
          },
          itemBuilder: (context, index) {
            return _buildContentBlock(context, article.contentBlocks[index]);
          },
        ),

        // Section Pro
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 114), // 84px navbar + 30px spacing
          child: _buildProfessionalSection(context, article.professional),
        ),
      ],
    );
  }

  Widget _buildContentBlock(BuildContext context, WedContentBlockStruct block) {
    switch (block.type) {
      case 'paragraph':
        return _buildParagraph(context, block.text);
      case 'single_image':
        return _buildSingleImage(context, block.imageUrls);
      case 'gallery':
        return _buildGallery(context, block);
      case 'video':
        return _VideoBlock(
            videoUrl:
                block.imageUrls.isNotEmpty ? block.imageUrls.first : null);
      default:
        return Text('Unknown block type: ${block.type}');
    }
  }

  Widget _buildGallery(BuildContext context, WedContentBlockStruct block) {
    if (block.imageUrls.isEmpty) return const SizedBox.shrink();

    int crossAxisCount;
    switch (block.layout) {
      case 'grid_2_cols':
        crossAxisCount = 2;
        break;
      case 'grid_3_cols':
        crossAxisCount = 3;
        break;
      default:
        crossAxisCount = 2;
    }

    if (block.layout == 'row' || block.layout == 'column') {
      List<Widget> children = [];
      for (int i = 0; i < block.imageUrls.length; i++) {
        Widget image = _buildImageItem(block.imageUrls[i]);
        children.add(block.layout == 'row' ? Expanded(child: image) : image);
        // Add 8px spacing between images (not after the last one)
        if (i < block.imageUrls.length - 1) {
          children.add(block.layout == 'row' 
              ? const SizedBox(width: 8) 
              : const SizedBox(height: 8));
        }
      }

      if (block.layout == 'row') {
        return Row(children: children);
      } else {
        return Column(children: children);
      }
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 6.0,
        mainAxisSpacing: 6.0,
        childAspectRatio: 1.0,
      ),
      primary: false,
      shrinkWrap: true,
      itemCount: block.imageUrls.length,
      itemBuilder: (context, index) => _buildImageItem(block.imageUrls[index]),
    );
  }

  Widget _buildImageItem(String url) {
    return GestureDetector(
      onTap: () => _openImageViewer(url),
      child: ClipRRect(
        // --- MODIFICATION 4 : Bords arrondis à 0px ---
        borderRadius: BorderRadius.circular(0.0),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              child: Center(
                  child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String? text) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Text(
      text,
      // --- MODIFICATION 5 : Taille de police des paragraphes à 12px ---
      style: FlutterFlowTheme.of(context).bodyLarge.override(
            fontFamily: 'Haas Grot Text Trial',
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: 14, // Taille de police changée à 12
            letterSpacing: 0.0,
            lineHeight: 1.2,
          ),
    );
  }

  Widget _buildSingleImage(BuildContext context, List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    return _buildImageItem(imageUrls.first);
  }

  Widget _buildCoverCarousel(BuildContext context, List<String> coverImages) {
    if (coverImages.isEmpty) {
      return const SizedBox(height: 110);
    }
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 350,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageViewController,
            itemCount: coverImages.length,
            itemBuilder: (context, index) {
              final imageUrl = coverImages[index];
              return GestureDetector(
                onTap: () => _openImageViewer(imageUrl),
                child: Image.network(imageUrl,
                    width: double.infinity, height: 350, fit: BoxFit.cover),
              );
            },
          ),
          if (coverImages.length > 1)
            Align(
              alignment: const AlignmentDirectional(0, 1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: smooth_page_indicator.SmoothPageIndicator(
                  controller: _pageViewController!,
                  count: coverImages.length,
                  effect: smooth_page_indicator.SlideEffect(
                    spacing: 8,
                    radius: 8,
                    dotWidth: 8,
                    dotHeight: 8,
                    dotColor: FlutterFlowTheme.of(context).accent1,
                    activeDotColor: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Professional section - unified UI with pro_details_widget.dart
  Widget _buildProfessionalSection(BuildContext context, ProDetailsStruct pro) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Image.network(
                pro.avatarUrl.isNotEmpty
                    ? pro.avatarUrl
                    : 'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png',
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 40),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pro.fullName.isNotEmpty ? pro.fullName : 'Name...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    pro.profession?.name ?? 'Profession...',
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
                if (pro.instagramUrl.isNotEmpty)
                  FlutterFlowIconButton(
                    borderRadius: 100.0,
                    buttonSize: 40.0,
                    fillColor: theme.primary,
                    icon: FaIcon(
                      FontAwesomeIcons.instagram,
                      color: theme.info,
                      size: 22.0,
                    ),
                    onPressed: () async {
                      await launchURL(pro.instagramUrl);
                    },
                  ),
                if (pro.websiteUrl.isNotEmpty)
                  FlutterFlowIconButton(
                    borderRadius: 100.0,
                    buttonSize: 40.0,
                    fillColor: theme.primary,
                    icon: Icon(
                      Icons.travel_explore_rounded,
                      color: theme.info,
                      size: 22.0,
                    ),
                    onPressed: () async {
                      await launchURL(pro.websiteUrl);
                    },
                  ),
                // Upcoming Travels button - always visible
                FlutterFlowIconButton(
                  borderRadius: 100.0,
                  buttonSize: 40.0,
                  fillColor: theme.primary,
                  icon: Icon(
                    Icons.flight_takeoff,
                    color: theme.info,
                    size: 22.0,
                  ),
                  onPressed: () async {
                    await UpcomingTravelsSheet.show(
                      context: context,
                      professionalId: pro.proProfileId,
                      professionalName: pro.fullName,
                    );
                  },
                ),
              ].divide(const SizedBox(width: 10.0)),
            ),
          ].divide(const SizedBox(width: 10.0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)),
                elevation: 0,
              ),
              onPressed: () async {
                if (pro.proProfileId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Unable to view this profile, please try again later.',
                        style: TextStyle(
                          color: theme.primaryText,
                        ),
                      ),
                      duration: const Duration(milliseconds: 2000),
                      backgroundColor: theme.warning,
                    ),
                  );
                  return;
                }

                // Charger les données complètes du professionnel
                final fullProDetails = await actions.getProItemDetailsAction(
                  pro.proProfileId,
                );

                if (!context.mounted) return;

                if (fullProDetails != null) {
                  context.pushNamed(
                    'ProDetails',
                    queryParameters: {
                      'proDetails': serializeParam(fullProDetails, ParamType.DataStruct)
                    }.withoutNulls,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Unable to load profile details, please try again later.',
                        style: TextStyle(
                          color: theme.primaryText,
                        ),
                      ),
                      duration: const Duration(milliseconds: 2000),
                      backgroundColor: theme.warning,
                    ),
                  );
                }
              },
              child: Text('More of this artist',
                  style: theme.bodyMedium.override(
                      fontFamily: 'Haas Grot Text Trial', color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Video block widget that handles YouTube, Vimeo, and direct video URLs
/// Uses the same video players as ProDetails for consistency
class _VideoBlock extends StatelessWidget {
  final String? videoUrl;
  const _VideoBlock({this.videoUrl});

  @override
  Widget build(BuildContext context) {
    if (videoUrl == null || videoUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    final url = videoUrl!;
    
    // YouTube URLs use YoutubePlayerWidget
    if (VideoUrlHelpers.isYouTubeUrl(url)) {
      return SizedBox(
        width: double.infinity,
        height: 250.0,
        child: YoutubePlayerWidget(
          width: double.infinity,
          height: 250.0,
          youtubeUrl: url,
        ),
      );
    }
    
    // Vimeo URLs use VimeoPlayerWidget
    if (VideoUrlHelpers.isVimeoUrl(url)) {
      return SizedBox(
        width: double.infinity,
        height: 250.0,
        child: VimeoPlayerWidget(
          width: double.infinity,
          height: 250.0,
          vimeoUrl: url,
        ),
      );
    }
    
    // Direct video files use VideoplayerFilmmaker
    return SizedBox(
      width: double.infinity,
      height: 250.0,
      child: VideoplayerFilmmaker(
        width: double.infinity,
        height: 250.0,
        videoUrl: url,
      ),
    );
  }
}

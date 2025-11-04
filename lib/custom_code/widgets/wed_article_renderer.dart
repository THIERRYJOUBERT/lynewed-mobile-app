// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!


import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

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
        'WowViewerCarrousel',
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
      padding: EdgeInsets.zero,
      children: [
        // --- MODIFICATION 1 : Espace blanc en haut ---
        const SizedBox(height: 110),

        // --- MODIFICATION 2 : Style du titre "Wedding Of The Week" ---
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Text(
            'WEDDING OF THE WEEK',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Haas Grot Text Trial',
                  fontSize: 16, // Taille de police changée à 16
                  fontWeight: FontWeight.w500, // Correspond à 'medium'
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
          ),
        ),

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
                  article.professional.avatarUrl ?? '',
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
                      article.professional.fullName ?? 'Name...',
                      style:
                          FlutterFlowTheme.of(context).titleMedium.override(
                                fontFamily: 'Haas Grot Text Trial',
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                    ),
                    Text(
                      article.professional.profession?.name ??
                          'profession...',
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
          separatorBuilder: (context, index) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            return _buildContentBlock(context, article.contentBlocks[index]);
          },
        ),

        // Section Pro
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
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
      List<Widget> children = block.imageUrls.map((url) {
        Widget image = _buildImageItem(url);
        return block.layout == 'row' ? Expanded(child: image) : image;
      }).toList();

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

  Widget _buildVideo(BuildContext context, List<String> videoUrls) {
    if (videoUrls.isEmpty) return const SizedBox.shrink();
    return _VideoBlock(videoUrl: videoUrls.first);
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

  Widget _buildProfessionalSection(BuildContext context, ProDetailsStruct pro) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                pro.avatarUrl ?? '',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 40),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pro.fullName ?? 'Name...',
                      style: theme.bodyMedium.override(
                          fontFamily: 'Haas Grot Text Trial',
                          fontWeight: FontWeight.w500)),
                  Text(pro.profession?.name ?? 'profession...',
                      style: theme.bodyMedium.override(
                          fontFamily: 'Haas Grot Text Trial',
                          color: theme.secondaryText)),
                ],
              ),
            ),
            if (pro.instagramUrl.isNotEmpty)
              IconButton(
                style: IconButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.black),
                icon: const FaIcon(FontAwesomeIcons.instagram, size: 22),
                onPressed: () => launchURL(pro.instagramUrl),
              ),
            const SizedBox(width: 10),
            if (pro.websiteUrl.isNotEmpty)
              IconButton(
                style: IconButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white),
                icon: const Icon(Icons.travel_explore_rounded, size: 22),
                onPressed: () => launchURL(pro.websiteUrl),
              ),
          ],
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
              onPressed: () => context.pushNamed(
                'ProDetails',
                queryParameters: {
                  'proDetails': serializeParam(pro, ParamType.DataStruct)
                }.withoutNulls,
              ),
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

class _VideoBlock extends StatefulWidget {
  final String? videoUrl;
  const _VideoBlock({this.videoUrl});

  @override
  State<_VideoBlock> createState() => _VideoBlockState();
}

class _VideoBlockState extends State<_VideoBlock> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
            ..initialize().then((_) {
              if (mounted) setState(() {});
            })
            ..setLooping(true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null) return;
    setState(() {
      _isPlaying = !_controller!.value.isPlaying;
      if (_isPlaying) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        height: 200,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return GestureDetector(
      onTap: _togglePlay,
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),
            if (!_isPlaying)
              Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle),
                child:
                    const Icon(Icons.play_arrow, color: Colors.white, size: 60),
              )
          ],
        ),
      ),
    );
  }
}

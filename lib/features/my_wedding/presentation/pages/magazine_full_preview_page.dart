/// Magazine Full Preview Page.
///
/// Displays the magazine pages in a full-screen read-only viewer
/// without editing overlays, simulating the final printed result.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/magazine_page.dart';
import '../widgets/magazine_cover.dart';
import '../widgets/magazine_double_page.dart';
import '../widgets/magazine_mosaic_page.dart';
import '../widgets/magazine_single_page.dart';

/// Full-screen magazine preview page.
class MagazineFullPreviewPage extends StatefulWidget {
  /// Creates a full-screen magazine preview.
  const MagazineFullPreviewPage({
    super.key,
    required this.pages,
    this.initialPage = 0,
    this.aspectRatio = 0.7,
  });

  /// The magazine pages to display.
  final List<MagazinePage> pages;

  /// The initial page to show.
  final int initialPage;

  /// Page aspect ratio (width / height) matching the magazine format.
  final double aspectRatio;

  /// Shows the full preview as a pushed route.
  static void show(
    BuildContext context, {
    required List<MagazinePage> pages,
    int initialPage = 0,
    double aspectRatio = 0.7,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => MagazineFullPreviewPage(
          pages: pages,
          initialPage: initialPage,
          aspectRatio: aspectRatio,
        ),
      ),
    );
  }

  @override
  State<MagazineFullPreviewPage> createState() =>
      _MagazineFullPreviewPageState();
}

class _MagazineFullPreviewPageState extends State<MagazineFullPreviewPage> {
  late PageController _controller;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _controller = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPage(MagazinePage page) {
    final child = switch (page) {
      CoverPage() => MagazineCover(page: page),
      SinglePage() => MagazineSinglePage(page: page),
      DoublePage() => MagazineDoublePage(page: page),
      MosaicPage() => MagazineMosaicPage(page: page),
      _ => const SizedBox.shrink(),
    };
    return Center(
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Page viewer
            PageView.builder(
              controller: _controller,
              itemCount: widget.pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => _buildPage(widget.pages[index]),
            ),
            // Close button
            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            // Page counter
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentPage + 1} / ${widget.pages.length}',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

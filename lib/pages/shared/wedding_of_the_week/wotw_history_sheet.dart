import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/design/design.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_util.dart';

/// WOTW History Sheet - Shows all past Wedding of the Week articles
class WotwHistorySheet extends StatefulWidget {
  const WotwHistorySheet({
    super.key,
    required this.onArticleSelected,
  });

  final void Function(String articleId) onArticleSelected;

  @override
  State<WotwHistorySheet> createState() => _WotwHistorySheetState();
}

class _WotwHistorySheetState extends State<WotwHistorySheet> {
  List<WedArticleSummaryStruct>? _articles;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final locale = FFAppState().currentUserPreferences.defaultLocale;
      final articles = await actions.getAllWedArticles(locale);
      
      if (!mounted) return;
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load history';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'History',
      onClose: () => Navigator.pop(context),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: LynewedColors.gray300,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              LynewedButton(
                text: 'Retry',
                onPressed: _loadArticles,
                type: LynewedButtonType.secondary,
              ),
            ],
          ),
        ),
      );
    }

    if (_articles == null || _articles!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.history,
                size: 48,
                color: LynewedColors.gray300,
              ),
              const SizedBox(height: 16),
              Text(
                'No past weddings',
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

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: _articles!.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        color: LynewedColors.gray200,
      ),
      itemBuilder: (context, index) {
        final article = _articles![index];
        return _WotwHistoryItem(
          article: article,
          onTap: () {
            Navigator.pop(context);
            widget.onArticleSelected(article.id);
          },
        );
      },
    );
  }
}

/// Single WOTW history item row
class _WotwHistoryItem extends StatelessWidget {
  const _WotwHistoryItem({
    required this.article,
    required this.onTap,
  });

  final WedArticleSummaryStruct article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 60,
                height: 60,
                child: article.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: article.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: LynewedColors.gray100,
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: LynewedColors.gray300,
                              size: 24,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: LynewedColors.gray100,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: LynewedColors.gray300,
                              size: 24,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: LynewedColors.gray100,
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: LynewedColors.gray300,
                            size: 24,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Title + Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (article.hasPublishedAt()) ...[
                    const SizedBox(height: 4),
                    Text(
                      article.publishedDateFormatted,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Chevron
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: LynewedColors.gray300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

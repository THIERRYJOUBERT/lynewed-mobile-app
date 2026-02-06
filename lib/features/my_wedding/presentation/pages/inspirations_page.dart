/// Inspirations Page - Albums list for wedding moodboards
///
/// Displays wedding albums (shared with pros) and private albums (bride only).
/// Allows creating, viewing, and managing inspiration albums.
/// Delegates grid rendering to [InspirationAlbumsGrid].
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../sheets/create_album_sheet.dart';
import '../widgets/inspiration_albums_grid.dart';

/// Inspirations Page
class InspirationsPage extends StatefulWidget {
  const InspirationsPage({
    super.key,
    required this.weddingId,
    this.isReadOnly = false,
  });

  final String weddingId;
  final bool isReadOnly;

  static const String routeName = 'inspirations';
  static const String routePath = '/inspirations';

  @override
  State<InspirationsPage> createState() => _InspirationsPageState();
}

class _InspirationsPageState extends State<InspirationsPage> {
  final _gridKey = GlobalKey<InspirationAlbumsGridState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            Expanded(
              child: InspirationAlbumsGrid(
                key: _gridKey,
                weddingId: widget.weddingId,
                isReadOnly: widget.isReadOnly,
                onCreateAlbum: widget.isReadOnly ? null : _openCreateAlbumSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Inspirations',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
          if (!widget.isReadOnly)
            GestureDetector(
              onTap: _openCreateAlbumSheet,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: LynewedColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 22,
                  color: LynewedColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openCreateAlbumSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAlbumSheet(
        weddingId: widget.weddingId,
        onCreated: () => _gridKey.currentState?.reload(),
      ),
    );
  }
}

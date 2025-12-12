/// Create Album Sheet - Form to create a new inspiration album
///
/// Allows bride to create wedding albums (shared with pros) or private albums.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';

/// Create Album Sheet
class CreateAlbumSheet extends StatefulWidget {
  const CreateAlbumSheet({
    super.key,
    required this.weddingId,
    required this.onCreated,
  });

  final String weddingId;
  final VoidCallback onCreated;

  @override
  State<CreateAlbumSheet> createState() => _CreateAlbumSheetState();
}

class _CreateAlbumSheetState extends State<CreateAlbumSheet> {
  late MyWeddingRepository _repository;
  final _nameController = TextEditingController();
  
  bool _isPrivate = false;
  AlbumCategory _category = AlbumCategory.general;
  bool _isLoading = false;
  String? _error;

  static const List<AlbumCategory> _categories = [
    AlbumCategory.general,
    AlbumCategory.dress,
    AlbumCategory.decor,
    AlbumCategory.flowers,
    AlbumCategory.venue,
    AlbumCategory.beauty,
    AlbumCategory.photos,
    AlbumCategory.stationery,
  ];

  @override
  void initState() {
    super.initState();
    _repository = MyWeddingRepositoryImpl();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getCategoryDisplayName(AlbumCategory category) {
    switch (category) {
      case AlbumCategory.general:
        return 'General';
      case AlbumCategory.dress:
        return 'Dress';
      case AlbumCategory.decor:
        return 'Decor';
      case AlbumCategory.flowers:
        return 'Flowers';
      case AlbumCategory.venue:
        return 'Venue';
      case AlbumCategory.beauty:
        return 'Beauty';
      case AlbumCategory.photos:
        return 'Photos';
      case AlbumCategory.stationery:
        return 'Stationery';
      case AlbumCategory.custom:
        return 'Custom';
    }
  }

  Future<void> _createAlbum() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter an album name');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.createInspirationAlbum(
      weddingId: widget.weddingId,
      name: name,
      category: _category.name,
      isPrivate: _isPrivate,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      widget.onCreated();
      Navigator.pop(context);
    } else {
      setState(() {
        _error = result.error ?? 'Failed to create album';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Create Album',
      onClose: () => Navigator.pop(context),
      bottomAction: LynewedButton(
        text: 'Create Album',
        onPressed: _isLoading ? null : _createAlbum,
        isLoading: _isLoading,
        width: double.infinity,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error banner
          if (_error != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: LynewedComponentStyles.errorBannerDecoration(),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: LynewedColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: LynewedColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Album Name
          _buildSectionTitle('Album Name *'),
          LynewedTextField(
            controller: _nameController,
            hint: 'e.g., Wedding Dress Ideas',
          ),
          const SizedBox(height: 30),

          // Category
          _buildSectionTitle('Category'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              return LynewedChip(
                label: _getCategoryDisplayName(category),
                selected: _category == category,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _category = category);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),

          // Visibility
          _buildSectionTitle('Visibility'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildVisibilityOption(
                  isPrivate: false,
                  icon: Icons.groups_outlined,
                  title: 'Wedding',
                  subtitle: 'Visible to pros',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVisibilityOption(
                  isPrivate: true,
                  icon: Icons.lock_outline,
                  title: 'Private',
                  subtitle: 'Only you',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: LynewedTextStyles.sectionTitle),
    );
  }

  Widget _buildVisibilityOption({
    required bool isPrivate,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _isPrivate == isPrivate;
    return InkWell(
      onTap: () => setState(() => _isPrivate = isPrivate),
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : LynewedColors.gray200,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : LynewedColors.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: LynewedTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.black : LynewedColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

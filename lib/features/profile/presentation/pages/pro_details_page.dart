/// Professional details page.
///
/// Displays detailed information about a professional user.
/// Loads data asynchronously based on the profile ID.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/design/design.dart';

/// A page that displays detailed information about a professional.
///
/// Fetches professional data based on [profileId] and displays:
/// - Profile header with avatar and name
/// - Profession and company information
/// - Bio and description
/// - Portfolio images (if available)
class ProDetailsPage extends StatefulWidget {
  /// Route name for navigation.
  static const String routeName = 'proDetails';

  /// Route path for navigation.
  static const String routePath = '/pro/:profileId';

  /// The profile ID of the professional to display.
  final String profileId;

  /// Creates a professional details page.
  const ProDetailsPage({
    super.key,
    required this.profileId,
  });

  @override
  State<ProDetailsPage> createState() => _ProDetailsPageState();
}

class _ProDetailsPageState extends State<ProDetailsPage> {
  bool _isLoading = true;
  String? _error;
  _ProDetails? _details;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (widget.profileId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Invalid profile ID';
      });
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('profiles')
          .select('''
            id, full_name, avatar_url, bio,
            professional_details (
              business_name, profession, description, portfolio_images,
              instagram_url, website_url, location_label
            )
          ''')
          .eq('id', widget.profileId)
          .maybeSingle();

      if (!mounted) return;

      if (data != null) {
        final details = data['professional_details'] as Map<String, dynamic>?;
        setState(() {
          _details = _ProDetails(
            id: data['id'] as String,
            displayName: data['full_name'] as String?,
            avatarUrl: data['avatar_url'] as String?,
            bio: data['bio'] as String?,
            profession: details?['profession'] as String?,
            companyName: details?['business_name'] as String?,
            description: details?['description'] as String?,
            portfolioImages: (details?['portfolio_images'] as List?)?.cast<String>(),
            instagramUrl: details?['instagram_url'] as String?,
            websiteUrl: details?['website_url'] as String?,
            locationLabel: details?['location_label'] as String?,
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Profile not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading profile';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      appBar: AppBar(
        backgroundColor: LynewedColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: LynewedColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _details?.displayName ?? 'Professional',
          style: LynewedTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48.0,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 16.0),
            Text(
              _error!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            LynewedButton(
              text: 'Retry',
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadProfile();
              },
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    if (_details == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          _buildHeader(),
          const Divider(height: 1.0, color: LynewedColors.gray200),
          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (_details!.description != null &&
                    _details!.description!.isNotEmpty) ...[
                  const Text('About', style: LynewedTextStyles.sectionTitle),
                  const SizedBox(height: 8.0),
                  Text(
                    _details!.description!,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
                // Location
                if (_details!.locationLabel != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18.0,
                        color: LynewedColors.textSecondary,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        _details!.locationLabel!,
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                ],
                // Portfolio
                if (_details!.portfolioImages != null &&
                    _details!.portfolioImages!.isNotEmpty) ...[
                  const Text('Portfolio', style: LynewedTextStyles.sectionTitle),
                  const SizedBox(height: 12.0),
                  _buildPortfolioGrid(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
      child: Column(
        children: [
          // Avatar
          _buildAvatar(),
          const SizedBox(height: 16.0),
          // Name
          Text(
            _details!.displayName ?? 'Professional',
            style: LynewedTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          // Profession
          if (_details!.profession != null) ...[
            const SizedBox(height: 4.0),
            Text(
              _details!.profession!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          // Company
          if (_details!.companyName != null) ...[
            const SizedBox(height: 2.0),
            Text(
              _details!.companyName!,
              style: LynewedTextStyles.labelMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          // Bio
          if (_details!.bio != null && _details!.bio!.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            Text(
              _details!.bio!,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    const double size = 80.0;

    if (_details!.avatarUrl != null && _details!.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: _details!.avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildAvatarPlaceholder(size),
          errorWidget: (_, __, ___) => _buildAvatarPlaceholder(size),
        ),
      );
    }

    return _buildAvatarPlaceholder(size);
  }

  Widget _buildAvatarPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: LynewedColors.gray200,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: const Icon(
        Icons.person,
        size: 40.0,
        color: LynewedColors.gray300,
      ),
    );
  }

  Widget _buildPortfolioGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: _details!.portfolioImages!.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: CachedNetworkImage(
            imageUrl: _details!.portfolioImages![index],
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: LynewedColors.gray200,
            ),
            errorWidget: (_, __, ___) => Container(
              color: LynewedColors.gray200,
              child: const Icon(
                Icons.broken_image,
                color: LynewedColors.gray300,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Internal data class for professional details.
class _ProDetails {
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? profession;
  final String? companyName;
  final String? description;
  final List<String>? portfolioImages;
  final String? instagramUrl;
  final String? websiteUrl;
  final String? locationLabel;

  _ProDetails({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.profession,
    this.companyName,
    this.description,
    this.portfolioImages,
    this.instagramUrl,
    this.websiteUrl,
    this.locationLabel,
  });
}

/// Public professional profile page.
///
/// Displays the professional's profile as it appears to brides.
/// Uses AuthCubit to get the current professional's profile data.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '/core/design/design.dart';
import '/core/navigation/routes.dart';
import '/features/auth/domain/entities/entities.dart';
import '/features/auth/presentation/bloc/auth_cubit.dart';
import '/features/auth/presentation/bloc/auth_state.dart';

/// A page that displays the professional's public profile.
///
/// Shows how brides see the professional's profile:
/// - Avatar and display name
/// - Profession and company name
/// - Bio
/// - Portfolio images
/// - Hint card explaining the preview purpose
class PublicProProfilePage extends StatefulWidget {
  /// Route name for navigation.
  static const String routeName = 'PublicProProfile';

  /// Route path for navigation.
  static const String routePath = '/publicProProfile';

  /// Creates a public professional profile page.
  const PublicProProfilePage({super.key});

  @override
  State<PublicProProfilePage> createState() => _PublicProProfilePageState();
}

class _PublicProProfilePageState extends State<PublicProProfilePage> {
  /// Avatar size constant
  static const double _avatarSize = 80.0;

  /// Avatar icon size constant
  static const double _avatarIconSize = 40.0;

  /// Portfolio grid spacing
  static const double _gridSpacing = 4.0;

  List<String>? _portfolioImages;
  bool _isLoadingPortfolio = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPortfolio();
    });
  }

  Future<void> _loadPortfolio() async {
    if (!mounted) return;

    setState(() {
      _isLoadingPortfolio = true;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! Authenticated || authState.profile == null) {
        if (mounted) {
          setState(() {
            _isLoadingPortfolio = false;
            _portfolioImages = [];
          });
        }
        return;
      }

      final profileId = authState.profile!.id;
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from('professional_details')
          .select('portfolio_images')
          .eq('profile_id', profileId)
          .maybeSingle();

      if (!mounted) return;

      if (data != null) {
        final images = (data['portfolio_images'] as List?)?.cast<String>();
        setState(() {
          _portfolioImages = images;
          _isLoadingPortfolio = false;
        });
      } else {
        setState(() {
          _portfolioImages = [];
          _isLoadingPortfolio = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _portfolioImages = [];
          _isLoadingPortfolio = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return Scaffold(
            backgroundColor: LynewedColors.background,
            body: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
              ),
            ),
          );
        }

        if (state is! Authenticated || state.profile == null) {
          return Scaffold(
            backgroundColor: LynewedColors.background,
            body: const Center(
              child: Text('Not authenticated'),
            ),
          );
        }

        final profile = state.profile!;

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
              'My Public Profile',
              style: LynewedTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: LynewedColors.textPrimary,
                ),
                onPressed: () => _navigateToEditProfile(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header section
                _buildProfileHeader(profile),
                const Divider(height: 1.0, color: LynewedColors.gray200),
                // Portfolio section
                _buildPortfolioSection(),
                // Hint card
                _buildHintCard(),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
      child: Column(
        children: [
          // Avatar
          _buildAvatar(profile.avatarUrl),
          const SizedBox(height: 16.0),
          // Display name
          Text(
            profile.displayName ?? 'Professional',
            style: LynewedTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          // Profession
          if (profile.profession != null && profile.profession!.isNotEmpty) ...[
            const SizedBox(height: 4.0),
            Text(
              profile.profession!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          // Company name
          if (profile.companyName != null && profile.companyName!.isNotEmpty) ...[
            const SizedBox(height: 2.0),
            Text(
              profile.companyName!,
              style: LynewedTextStyles.labelMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            Text(
              profile.bio!,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: _avatarSize / 2,
        backgroundColor: LynewedColors.gray200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_avatarSize / 2),
          child: CachedNetworkImage(
            imageUrl: avatarUrl,
            width: _avatarSize,
            height: _avatarSize,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildAvatarPlaceholder(),
            errorWidget: (_, __, ___) => _buildAvatarPlaceholder(),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: _avatarSize / 2,
      backgroundColor: LynewedColors.gray200,
      child: const Icon(
        Icons.person,
        size: _avatarIconSize,
        color: LynewedColors.gray300,
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: LynewedColors.gray200,
        borderRadius: BorderRadius.circular(_avatarSize / 2),
      ),
      child: const Icon(
        Icons.person,
        size: _avatarIconSize,
        color: LynewedColors.gray300,
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Portfolio', style: LynewedTextStyles.sectionTitle),
              TextButton(
                onPressed: () => _navigateToEditProfile(context),
                child: Text(
                  'Edit',
                  style: LynewedTextStyles.labelMedium.copyWith(
                    color: LynewedColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          _buildPortfolioContent(),
        ],
      ),
    );
  }

  Widget _buildPortfolioContent() {
    if (_isLoadingPortfolio) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
          ),
        ),
      );
    }

    if (_portfolioImages == null || _portfolioImages!.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 48.0,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 8.0),
            Text(
              'No portfolio items yet',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12.0),
            LynewedButton(
              text: 'Add Photos',
              type: LynewedButtonType.secondary,
              onPressed: () => _navigateToEditProfile(context),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: _gridSpacing,
        mainAxisSpacing: _gridSpacing,
      ),
      itemCount: _portfolioImages!.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: CachedNetworkImage(
            imageUrl: _portfolioImages![index],
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

  Widget _buildHintCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: LynewedColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: LynewedColors.primary,
              size: 24.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                'This is how brides see your profile. Keep it updated!',
                style: LynewedTextStyles.bodySmall.copyWith(
                  color: LynewedColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    // Navigate to profile settings page (legacy profile edit for pros)
    context.pushNamed(RouteNames.profileBridesAndPro);
  }
}

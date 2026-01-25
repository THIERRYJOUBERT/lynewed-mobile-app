/// Profile page.
///
/// Displays the current user's profile with header and menu items.
/// Shows different menus for bride vs professional users.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/design/design.dart';
import '/features/auth/domain/entities/entities.dart';
import '/features/auth/presentation/bloc/auth_cubit.dart';
import '/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/profile_menu_item.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item_widget.dart';

/// The main profile page showing user info and menu options.
///
/// Displays:
/// - Profile header with avatar, name, and bio
/// - Menu items based on user role (bride or professional)
/// - Settings and sign out options
class ProfilePage extends StatelessWidget {
  /// Route name for navigation.
  static const String routeName = 'profile';

  /// Route path for navigation.
  static const String routePath = '/profile';

  /// Creates a profile page.
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return switch (state) {
            Authenticated(:final profile) when profile != null =>
              _buildAuthenticatedContent(context, profile),
            Authenticated() => _buildLoadingContent(),
            AuthLoading() => _buildLoadingContent(),
            AuthInitial() => _buildLoadingContent(),
            Unauthenticated() => _buildUnauthenticatedContent(),
            AuthError(:final message) => _buildErrorContent(message),
          };
        },
      ),
    );
  }

  Widget _buildLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
      ),
    );
  }

  Widget _buildUnauthenticatedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person_off,
            size: 64.0,
            color: LynewedColors.gray300,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Not signed in',
            style: LynewedTextStyles.headlineSmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String message) {
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
            message,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedContent(
    BuildContext context,
    UserProfile profile,
  ) {
    final menuItems = profile.isProfessional
        ? _buildProfessionalMenuItems(context)
        : _buildBrideMenuItems(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            ProfileHeader(profile: profile),
            const Divider(height: 1.0, color: LynewedColors.gray200),
            // Menu items
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: menuItems
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ProfileMenuItemWidget(data: item),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ProfileMenuItemData> _buildBrideMenuItems(BuildContext context) {
    return [
      ProfileMenuItemData(
        icon: Icons.settings_outlined,
        title: 'Settings',
        subtitle: 'App preferences',
        onTap: () => _navigateToSettings(context),
      ),
      ProfileMenuItemData(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'Get assistance',
        onTap: () => _navigateToHelp(context),
      ),
      ProfileMenuItemData(
        icon: Icons.logout,
        title: 'Sign Out',
        subtitle: 'Log out of your account',
        onTap: () => _signOut(context),
      ),
    ];
  }

  List<ProfileMenuItemData> _buildProfessionalMenuItems(BuildContext context) {
    return [
      ProfileMenuItemData(
        icon: Icons.edit_outlined,
        title: 'Edit Profile',
        subtitle: 'Update your information',
        onTap: () => _navigateToEditProfile(context),
      ),
      ProfileMenuItemData(
        icon: Icons.settings_outlined,
        title: 'Settings',
        subtitle: 'App preferences',
        onTap: () => _navigateToSettings(context),
      ),
      ProfileMenuItemData(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'Get assistance',
        onTap: () => _navigateToHelp(context),
      ),
      ProfileMenuItemData(
        icon: Icons.logout,
        title: 'Sign Out',
        subtitle: 'Log out of your account',
        onTap: () => _signOut(context),
      ),
    ];
  }

  void _navigateToSettings(BuildContext context) {
    // TODO: Navigate to settings page
  }

  void _navigateToEditProfile(BuildContext context) {
    // TODO: Navigate to edit profile page
  }

  void _navigateToHelp(BuildContext context) {
    // TODO: Navigate to help page
  }

  void _signOut(BuildContext context) {
    context.read<AuthCubit>().signOut();
  }
}

/// Edit profile page for brides.
///
/// Allows brides to edit their profile information including:
/// - Avatar image
/// - Full name
/// - Email (read-only)
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '/core/core.dart';
import '/core/design/design.dart';
import '/features/auth/domain/entities/entities.dart';
import '/features/auth/domain/repositories/auth_repository.dart';
import '/features/auth/presentation/bloc/auth_cubit.dart';
import '/features/auth/presentation/bloc/auth_state.dart';
import '../widgets/avatar_picker.dart';

/// Page for editing bride profile information.
///
/// Uses AuthCubit for state management and AuthRepository for data operations.
/// Supports avatar upload and profile field updates.
class EditProfileBridesPage extends StatefulWidget {
  /// Route name for navigation.
  static const String routeName = 'editProfileBrides';

  /// Route path for navigation.
  static const String routePath = '/editProfileBrides';

  /// Creates an edit profile brides page.
  const EditProfileBridesPage({super.key});

  @override
  State<EditProfileBridesPage> createState() => _EditProfileBridesPageState();
}

class _EditProfileBridesPageState extends State<EditProfileBridesPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  String? _localAvatarPath;
  bool _isLoading = false;
  bool _isAvatarLoading = false;
  bool _hasInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initializeControllers(AuthState state) {
    if (_hasInitialized) return;

    if (state is Authenticated) {
      final profile = state.profile;
      _nameController.text = profile?.displayName ?? '';
      _emailController.text = state.user.email;
      _hasInitialized = true;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _localAvatarPath = image.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cubit = context.read<AuthCubit>();
      String? newAvatarUrl;

      // Upload avatar if a new one was selected
      if (_localAvatarPath != null && _localAvatarPath!.isNotEmpty) {
        setState(() => _isAvatarLoading = true);

        final file = File(_localAvatarPath!);
        final bytes = await file.readAsBytes();
        final fileName =
            'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final uploadResult = await cubit.uploadAvatar(bytes, fileName);
        switch (uploadResult) {
          case Success(:final data):
            newAvatarUrl = data;
          case Failure(:final failure):
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to upload avatar: ${failure.message}'),
                  backgroundColor: LynewedColors.error,
                ),
              );
            }
            setState(() {
              _isLoading = false;
              _isAvatarLoading = false;
            });
            return;
        }
        setState(() => _isAvatarLoading = false);
      }

      // Update profile
      final params = UpdateProfileParams(
        displayName: _nameController.text.trim(),
        avatarUrl: newAvatarUrl,
      );

      final result = await cubit.updateProfile(params);
      switch (result) {
        case Success():
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: LynewedColors.success,
              ),
            );
            Navigator.of(context).pop();
          }
        case Failure(:final failure):
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update profile: ${failure.message}'),
                backgroundColor: LynewedColors.error,
              ),
            );
          }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isAvatarLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          _initializeControllers(state);

          return switch (state) {
            Authenticated(:final profile, :final user) =>
              _buildContent(profile, user),
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
            size: 64,
            color: LynewedColors.gray300,
          ),
          const SizedBox(height: 16),
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
            size: 48,
            color: LynewedColors.error,
          ),
          const SizedBox(height: 16),
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

  Widget _buildContent(UserProfile? profile, AuthUser user) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 130),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar picker
                  Center(
                    child: AvatarPicker(
                      currentAvatarUrl: profile?.avatarUrl,
                      localImagePath: _localAvatarPath,
                      isLoading: _isAvatarLoading,
                      helperText: 'Change your profile picture',
                      onTap: _pickImage,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name field
                  _buildNameField(),
                  const SizedBox(height: 24),

                  // Email field (read-only)
                  _buildEmailField(),
                  const SizedBox(height: 32),

                  // Save button
                  LynewedButton(
                    text: 'Save',
                    onPressed: _isLoading ? null : _saveProfile,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
        _buildHeader(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: const BoxDecoration(
        color: LynewedColors.background,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: LynewedColors.textPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'EDIT MY PROFILE',
                  style: LynewedTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 1,
            color: LynewedColors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full name',
            labelStyle: LynewedTextStyles.labelLarge,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: LynewedColors.border),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: LynewedColors.textPrimary),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: LynewedColors.error),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: LynewedColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          style: LynewedTextStyles.bodyMedium,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Name is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _emailController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Email address',
            labelStyle: LynewedTextStyles.labelLarge,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: LynewedColors.border),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: LynewedColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

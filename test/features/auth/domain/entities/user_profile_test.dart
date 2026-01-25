/// Tests for UserProfile entity.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/domain/entities/user_profile.dart';
import 'package:lynewed_beta/features/auth/domain/entities/user_role.dart';

void main() {
  group('UserProfile', () {
    final now = DateTime(2024, 1, 15, 10, 30);
    final updatedAt = DateTime(2024, 1, 20, 14, 0);

    group('constructor', () {
      test('should create UserProfile with required fields', () {
        final profile = UserProfile(
          id: 'profile-123',
          authUserId: 'auth-user-456',
          role: UserRole.bride,
          createdAt: now,
        );

        expect(profile.id, 'profile-123');
        expect(profile.authUserId, 'auth-user-456');
        expect(profile.role, UserRole.bride);
        expect(profile.createdAt, now);
        expect(profile.displayName, isNull);
        expect(profile.avatarUrl, isNull);
        expect(profile.profession, isNull);
        expect(profile.companyName, isNull);
        expect(profile.bio, isNull);
        expect(profile.isOnboardingComplete, false);
        expect(profile.onboardingStep, isNull);
        expect(profile.updatedAt, isNull);
      });

      test('should create UserProfile with all fields (bride)', () {
        final profile = UserProfile(
          id: 'profile-123',
          authUserId: 'auth-user-456',
          displayName: 'Marie Dupont',
          avatarUrl: 'https://example.com/avatar.jpg',
          role: UserRole.bride,
          bio: 'Planning my dream wedding!',
          isOnboardingComplete: true,
          onboardingStep: 5,
          createdAt: now,
          updatedAt: updatedAt,
        );

        expect(profile.id, 'profile-123');
        expect(profile.displayName, 'Marie Dupont');
        expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
        expect(profile.role, UserRole.bride);
        expect(profile.bio, 'Planning my dream wedding!');
        expect(profile.isOnboardingComplete, true);
        expect(profile.onboardingStep, 5);
        expect(profile.updatedAt, updatedAt);
      });

      test('should create UserProfile with all fields (professional)', () {
        final profile = UserProfile(
          id: 'profile-789',
          authUserId: 'auth-user-321',
          displayName: 'Jean Photographe',
          avatarUrl: 'https://example.com/pro-avatar.jpg',
          role: UserRole.professional,
          profession: 'Photographe',
          companyName: 'Studio Jean',
          bio: 'Professional wedding photographer',
          isOnboardingComplete: true,
          onboardingStep: 10,
          createdAt: now,
          updatedAt: updatedAt,
        );

        expect(profile.role, UserRole.professional);
        expect(profile.profession, 'Photographe');
        expect(profile.companyName, 'Studio Jean');
      });
    });

    group('role helpers', () {
      test('isBride should return true for bride role', () {
        final profile = UserProfile(
          id: 'id',
          authUserId: 'auth-id',
          role: UserRole.bride,
          createdAt: now,
        );

        expect(profile.isBride, true);
        expect(profile.isProfessional, false);
        expect(profile.isAdmin, false);
      });

      test('isProfessional should return true for professional role', () {
        final profile = UserProfile(
          id: 'id',
          authUserId: 'auth-id',
          role: UserRole.professional,
          createdAt: now,
        );

        expect(profile.isBride, false);
        expect(profile.isProfessional, true);
        expect(profile.isAdmin, false);
      });

      test('isAdmin should return true for admin role', () {
        final profile = UserProfile(
          id: 'id',
          authUserId: 'auth-id',
          role: UserRole.admin,
          createdAt: now,
        );

        expect(profile.isBride, false);
        expect(profile.isProfessional, false);
        expect(profile.isAdmin, true);
      });
    });

    group('copyWith', () {
      test('should create copy with updated displayName', () {
        final profile = UserProfile(
          id: 'id',
          authUserId: 'auth-id',
          displayName: 'Old Name',
          role: UserRole.bride,
          createdAt: now,
        );

        final updated = profile.copyWith(displayName: 'New Name');

        expect(updated.displayName, 'New Name');
        expect(updated.id, profile.id);
        expect(updated.role, profile.role);
      });

      test('should create copy with updated role', () {
        final profile = UserProfile(
          id: 'id',
          authUserId: 'auth-id',
          role: UserRole.bride,
          createdAt: now,
        );

        final updated = profile.copyWith(role: UserRole.professional);

        expect(updated.role, UserRole.professional);
        expect(updated.isProfessional, true);
      });

      test('should create copy with all fields updated', () {
        final profile = UserProfile(
          id: 'id',
          authUserId: 'auth-id',
          role: UserRole.bride,
          createdAt: now,
        );

        final updated = profile.copyWith(
          id: 'new-id',
          authUserId: 'new-auth-id',
          displayName: 'New Name',
          avatarUrl: 'https://new.url',
          role: UserRole.professional,
          profession: 'DJ',
          companyName: 'DJ Corp',
          bio: 'New bio',
          isOnboardingComplete: true,
          onboardingStep: 3,
          createdAt: updatedAt,
          updatedAt: updatedAt,
        );

        expect(updated.id, 'new-id');
        expect(updated.authUserId, 'new-auth-id');
        expect(updated.displayName, 'New Name');
        expect(updated.avatarUrl, 'https://new.url');
        expect(updated.role, UserRole.professional);
        expect(updated.profession, 'DJ');
        expect(updated.companyName, 'DJ Corp');
        expect(updated.bio, 'New bio');
        expect(updated.isOnboardingComplete, true);
        expect(updated.onboardingStep, 3);
        expect(updated.createdAt, updatedAt);
        expect(updated.updatedAt, updatedAt);
      });

      test('should return same values when copyWith called with no arguments', () {
        final profile = UserProfile(
          id: 'id',
          authUserId: 'auth-id',
          displayName: 'Name',
          avatarUrl: 'https://url.com',
          role: UserRole.professional,
          profession: 'Photographer',
          companyName: 'Photo Co',
          bio: 'Bio text',
          isOnboardingComplete: true,
          onboardingStep: 5,
          createdAt: now,
          updatedAt: updatedAt,
        );

        final copy = profile.copyWith();

        expect(copy.id, profile.id);
        expect(copy.authUserId, profile.authUserId);
        expect(copy.displayName, profile.displayName);
        expect(copy.avatarUrl, profile.avatarUrl);
        expect(copy.role, profile.role);
        expect(copy.profession, profile.profession);
        expect(copy.companyName, profile.companyName);
        expect(copy.bio, profile.bio);
        expect(copy.isOnboardingComplete, profile.isOnboardingComplete);
        expect(copy.onboardingStep, profile.onboardingStep);
        expect(copy.createdAt, profile.createdAt);
        expect(copy.updatedAt, profile.updatedAt);
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        final profile1 = UserProfile(
          id: 'id',
          authUserId: 'auth-id',
          role: UserRole.bride,
          createdAt: now,
        );

        final profile2 = UserProfile(
          id: 'id',
          authUserId: 'auth-id',
          role: UserRole.bride,
          createdAt: now,
        );

        expect(profile1, equals(profile2));
        expect(profile1.hashCode, equals(profile2.hashCode));
      });

      test('should not be equal when id differs', () {
        final profile1 = UserProfile(
          id: 'id-1',
          authUserId: 'auth-id',
          role: UserRole.bride,
          createdAt: now,
        );

        final profile2 = UserProfile(
          id: 'id-2',
          authUserId: 'auth-id',
          role: UserRole.bride,
          createdAt: now,
        );

        expect(profile1, isNot(equals(profile2)));
      });

      test('should not be equal when role differs', () {
        final profile1 = UserProfile(
          id: 'id',
          authUserId: 'auth-id',
          role: UserRole.bride,
          createdAt: now,
        );

        final profile2 = UserProfile(
          id: 'id',
          authUserId: 'auth-id',
          role: UserRole.professional,
          createdAt: now,
        );

        expect(profile1, isNot(equals(profile2)));
      });
    });

    group('toString', () {
      test('should return readable string representation', () {
        final profile = UserProfile(
          id: 'profile-123',
          authUserId: 'auth-456',
          displayName: 'Marie',
          role: UserRole.bride,
          createdAt: now,
        );

        expect(profile.toString(), contains('UserProfile'));
        expect(profile.toString(), contains('profile-123'));
        expect(profile.toString(), contains('Marie'));
        expect(profile.toString(), contains('bride'));
      });
    });
  });
}

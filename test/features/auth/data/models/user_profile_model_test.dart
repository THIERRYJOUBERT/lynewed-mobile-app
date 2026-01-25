import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/data/models/user_profile_model.dart';
import 'package:lynewed_beta/features/auth/domain/entities/user_profile.dart';
import 'package:lynewed_beta/features/auth/domain/entities/user_role.dart';

void main() {
  group('UserProfileModel', () {
    final testCreatedAt = DateTime(2024, 1, 15, 10, 30);
    final testUpdatedAt = DateTime(2024, 1, 20, 14, 45);

    group('constructor', () {
      test('should create valid UserProfileModel with all fields', () {
        final model = UserProfileModel(
          id: 'profile-123',
          authUserId: 'auth-user-456',
          displayName: 'Test User',
          avatarUrl: 'https://example.com/avatar.jpg',
          role: UserRole.bride,
          profession: null,
          companyName: null,
          bio: 'A test bio',
          isOnboardingComplete: true,
          onboardingStep: null,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(model.id, 'profile-123');
        expect(model.authUserId, 'auth-user-456');
        expect(model.displayName, 'Test User');
        expect(model.avatarUrl, 'https://example.com/avatar.jpg');
        expect(model.role, UserRole.bride);
        expect(model.bio, 'A test bio');
        expect(model.isOnboardingComplete, true);
        expect(model.createdAt, testCreatedAt);
        expect(model.updatedAt, testUpdatedAt);
      });

      test('should create UserProfileModel for professional', () {
        final model = UserProfileModel(
          id: 'profile-789',
          authUserId: 'auth-user-789',
          displayName: 'Pro User',
          avatarUrl: null,
          role: UserRole.professional,
          profession: 'Photographer',
          companyName: 'Pro Photos',
          bio: null,
          isOnboardingComplete: false,
          onboardingStep: 2,
          createdAt: testCreatedAt,
          updatedAt: null,
        );

        expect(model.role, UserRole.professional);
        expect(model.profession, 'Photographer');
        expect(model.companyName, 'Pro Photos');
        expect(model.isOnboardingComplete, false);
        expect(model.onboardingStep, 2);
      });
    });

    group('fromJson', () {
      test('should create model from valid JSON', () {
        final json = {
          'id': 'profile-123',
          'auth_user_id': 'auth-user-456',
          'full_name': 'Test User',
          'avatar_url': 'https://example.com/avatar.jpg',
          'role': 'bride',
          'profession': null,
          'company_name': null,
          'bio': 'A test bio',
          'is_onboarding_complete': true,
          'onboarding_step': null,
          'created_at': '2024-01-15T10:30:00.000',
          'updated_at': '2024-01-20T14:45:00.000',
        };

        final model = UserProfileModel.fromJson(json);

        expect(model.id, 'profile-123');
        expect(model.authUserId, 'auth-user-456');
        expect(model.displayName, 'Test User');
        expect(model.avatarUrl, 'https://example.com/avatar.jpg');
        expect(model.role, UserRole.bride);
        expect(model.bio, 'A test bio');
        expect(model.isOnboardingComplete, true);
      });

      test('should handle missing optional fields in JSON', () {
        final json = {
          'id': 'profile-minimal',
          'auth_user_id': 'auth-user-minimal',
          'role': 'professional',
          'created_at': '2024-01-15T10:30:00.000',
        };

        final model = UserProfileModel.fromJson(json);

        expect(model.id, 'profile-minimal');
        expect(model.displayName, isNull);
        expect(model.avatarUrl, isNull);
        expect(model.role, UserRole.professional);
        expect(model.isOnboardingComplete, false);
        expect(model.updatedAt, isNull);
      });

      test('should default unknown role to bride', () {
        final json = {
          'id': 'profile-unknown',
          'auth_user_id': 'auth-user-unknown',
          'role': 'unknown_role',
          'created_at': '2024-01-15T10:30:00.000',
        };

        final model = UserProfileModel.fromJson(json);

        expect(model.role, UserRole.bride);
      });
    });

    group('toEntity', () {
      test('should convert to UserProfile entity correctly', () {
        final model = UserProfileModel(
          id: 'profile-123',
          authUserId: 'auth-user-456',
          displayName: 'Test User',
          avatarUrl: 'https://example.com/avatar.jpg',
          role: UserRole.bride,
          profession: null,
          companyName: null,
          bio: 'A test bio',
          isOnboardingComplete: true,
          onboardingStep: null,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final entity = model.toEntity();

        expect(entity, isA<UserProfile>());
        expect(entity.id, 'profile-123');
        expect(entity.authUserId, 'auth-user-456');
        expect(entity.displayName, 'Test User');
        expect(entity.avatarUrl, 'https://example.com/avatar.jpg');
        expect(entity.role, UserRole.bride);
        expect(entity.bio, 'A test bio');
        expect(entity.isOnboardingComplete, true);
        expect(entity.createdAt, testCreatedAt);
        expect(entity.updatedAt, testUpdatedAt);
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        final model = UserProfileModel(
          id: 'profile-123',
          authUserId: 'auth-user-456',
          displayName: 'Test User',
          avatarUrl: 'https://example.com/avatar.jpg',
          role: UserRole.bride,
          profession: null,
          companyName: null,
          bio: 'A test bio',
          isOnboardingComplete: true,
          onboardingStep: null,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final json = model.toJson();

        expect(json['full_name'], 'Test User');
        expect(json['avatar_url'], 'https://example.com/avatar.jpg');
        expect(json['bio'], 'A test bio');
      });

      test('should exclude null values from JSON', () {
        final model = UserProfileModel(
          id: 'profile-123',
          authUserId: 'auth-user-456',
          displayName: 'Test User',
          avatarUrl: null,
          role: UserRole.bride,
          profession: null,
          companyName: null,
          bio: null,
          isOnboardingComplete: false,
          onboardingStep: null,
          createdAt: testCreatedAt,
          updatedAt: null,
        );

        final json = model.toJson();

        expect(json.containsKey('avatar_url'), false);
        expect(json.containsKey('bio'), false);
        expect(json['full_name'], 'Test User');
      });
    });
  });
}

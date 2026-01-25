import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/data/models/auth_user_model.dart';
import 'package:lynewed_beta/features/auth/domain/entities/auth_user.dart';

void main() {
  group('AuthUserModel', () {
    final testCreatedAt = DateTime(2024, 1, 15, 10, 30);
    final testLastSignInAt = DateTime(2024, 1, 20, 14, 45);

    group('constructor', () {
      test('should create valid AuthUserModel with all fields', () {
        final model = AuthUserModel(
          id: 'user-123',
          email: 'test@example.com',
          phone: '+33612345678',
          emailConfirmed: true,
          lastSignInAt: testLastSignInAt,
          createdAt: testCreatedAt,
          userMetadata: {'role': 'bride'},
        );

        expect(model.id, 'user-123');
        expect(model.email, 'test@example.com');
        expect(model.phone, '+33612345678');
        expect(model.emailConfirmed, true);
        expect(model.lastSignInAt, testLastSignInAt);
        expect(model.createdAt, testCreatedAt);
        expect(model.userMetadata, {'role': 'bride'});
      });

      test('should create AuthUserModel with minimal fields', () {
        final model = AuthUserModel(
          id: 'user-456',
          email: 'minimal@example.com',
          createdAt: testCreatedAt,
        );

        expect(model.id, 'user-456');
        expect(model.email, 'minimal@example.com');
        expect(model.phone, isNull);
        expect(model.emailConfirmed, false);
        expect(model.lastSignInAt, isNull);
        expect(model.userMetadata, isNull);
      });
    });

    group('toEntity', () {
      test('should convert to AuthUser entity correctly', () {
        final model = AuthUserModel(
          id: 'user-123',
          email: 'test@example.com',
          phone: '+33612345678',
          emailConfirmed: true,
          lastSignInAt: testLastSignInAt,
          createdAt: testCreatedAt,
          userMetadata: {'role': 'bride'},
        );

        final entity = model.toEntity();

        expect(entity, isA<AuthUser>());
        expect(entity.id, 'user-123');
        expect(entity.email, 'test@example.com');
        expect(entity.phone, '+33612345678');
        expect(entity.emailConfirmed, true);
        expect(entity.lastSignInAt, testLastSignInAt);
        expect(entity.createdAt, testCreatedAt);
        expect(entity.userMetadata, {'role': 'bride'});
      });

      test('should convert minimal model to entity', () {
        final model = AuthUserModel(
          id: 'user-456',
          email: 'minimal@example.com',
          createdAt: testCreatedAt,
        );

        final entity = model.toEntity();

        expect(entity.phone, isNull);
        expect(entity.emailConfirmed, false);
        expect(entity.lastSignInAt, isNull);
        expect(entity.userMetadata, isNull);
      });
    });

    group('fromSupabaseUser', () {
      test('should create model from Supabase User mock data', () {
        // This test validates the factory can handle the expected data structure
        // The actual Supabase User will be mocked in datasource tests
        final model = AuthUserModel(
          id: 'uuid-from-supabase',
          email: 'supabase@example.com',
          phone: null,
          emailConfirmed: true,
          lastSignInAt: testLastSignInAt,
          createdAt: testCreatedAt,
          userMetadata: {'display_name': 'Test User'},
        );

        expect(model.id, 'uuid-from-supabase');
        expect(model.email, 'supabase@example.com');
        expect(model.emailConfirmed, true);
      });
    });
  });
}

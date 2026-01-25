import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lynewed_beta/features/auth/data/models/auth_user_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

class MockPostgrestClient extends Mock implements PostgrestClient {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

class MockUser extends Mock implements User {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUserResponse extends Mock implements UserResponse {}

class MockSession extends Mock implements Session {}

// Fake classes for mocktail
class FakeUserAttributes extends Fake implements UserAttributes {}

void main() {
  late AuthRemoteDatasource datasource;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockSupabaseStorageClient mockStorageClient;
  late MockStorageFileApi mockStorageFileApi;
  late MockFunctionsClient mockFunctionsClient;

  setUpAll(() {
    registerFallbackValue(FakeUserAttributes());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockStorageClient = MockSupabaseStorageClient();
    mockStorageFileApi = MockStorageFileApi();
    mockFunctionsClient = MockFunctionsClient();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockSupabaseClient.storage).thenReturn(mockStorageClient);
    when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);

    datasource = AuthRemoteDatasourceImpl(mockSupabaseClient);
  });

  group('AuthRemoteDatasource', () {
    group('signInWithEmail', () {
      test('should return AuthUserModel on successful sign in', () async {
        // Arrange
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('user-123');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.phone).thenReturn(null);
        when(() => mockUser.emailConfirmedAt).thenReturn('2024-01-15T10:00:00');
        when(() => mockUser.lastSignInAt).thenReturn('2024-01-20T14:00:00');
        when(() => mockUser.createdAt).thenReturn('2024-01-15T10:00:00');
        when(() => mockUser.userMetadata).thenReturn({});

        when(() => mockResponse.user).thenReturn(mockUser);

        when(() => mockGoTrueClient.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await datasource.signInWithEmail(
          'test@example.com',
          'password123',
        );

        // Assert
        expect(result, isA<AuthUserModel>());
        expect(result.id, 'user-123');
        expect(result.email, 'test@example.com');
        verify(() => mockGoTrueClient.signInWithPassword(
              email: 'test@example.com',
              password: 'password123',
            )).called(1);
      });

      test('should throw AuthException when sign in fails', () async {
        // Arrange
        final mockResponse = MockAuthResponse();
        when(() => mockResponse.user).thenReturn(null);

        when(() => mockGoTrueClient.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => datasource.signInWithEmail('test@example.com', 'wrong'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('signUpWithEmail', () {
      test('should return AuthUserModel on successful sign up', () async {
        // Arrange
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('new-user-123');
        when(() => mockUser.email).thenReturn('new@example.com');
        when(() => mockUser.phone).thenReturn(null);
        when(() => mockUser.emailConfirmedAt).thenReturn(null);
        when(() => mockUser.lastSignInAt).thenReturn('2024-01-20T14:00:00');
        when(() => mockUser.createdAt).thenReturn('2024-01-20T14:00:00');
        when(() => mockUser.userMetadata).thenReturn({'role': 'bride'});

        when(() => mockResponse.user).thenReturn(mockUser);

        when(() => mockGoTrueClient.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await datasource.signUpWithEmail(
          'new@example.com',
          'password123',
          metadata: {'role': 'bride'},
        );

        // Assert
        expect(result, isA<AuthUserModel>());
        expect(result.id, 'new-user-123');
        expect(result.email, 'new@example.com');
      });

      test('should throw AuthException when sign up fails', () async {
        // Arrange
        final mockResponse = MockAuthResponse();
        when(() => mockResponse.user).thenReturn(null);

        when(() => mockGoTrueClient.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => datasource.signUpWithEmail('test@example.com', 'pass'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('signOut', () {
      test('should call supabase signOut', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(null);
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

        // Act
        await datasource.signOut();

        // Assert
        verify(() => mockGoTrueClient.signOut()).called(1);
      });
    });

    group('sendPasswordResetEmail', () {
      test('should call supabase resetPasswordForEmail', () async {
        // Arrange
        when(() => mockGoTrueClient.resetPasswordForEmail(any()))
            .thenAnswer((_) async {});

        // Act
        await datasource.sendPasswordResetEmail('test@example.com');

        // Assert
        verify(() => mockGoTrueClient.resetPasswordForEmail('test@example.com'))
            .called(1);
      });
    });

    group('updatePassword', () {
      test('should call supabase updateUser with new password', () async {
        // Arrange
        final mockUserResponse = MockUserResponse();
        when(() => mockGoTrueClient.updateUser(any()))
            .thenAnswer((_) async => mockUserResponse);

        // Act
        await datasource.updatePassword('newPassword123');

        // Assert
        verify(() => mockGoTrueClient.updateUser(any())).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return AuthUserModel when user is logged in', () {
        // Arrange
        final mockUser = MockUser();

        when(() => mockUser.id).thenReturn('user-123');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.phone).thenReturn(null);
        when(() => mockUser.emailConfirmedAt).thenReturn('2024-01-15T10:00:00');
        when(() => mockUser.lastSignInAt).thenReturn('2024-01-20T14:00:00');
        when(() => mockUser.createdAt).thenReturn('2024-01-15T10:00:00');
        when(() => mockUser.userMetadata).thenReturn({});

        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        // Act
        final result = datasource.getCurrentUser();

        // Assert
        expect(result, isA<AuthUserModel>());
        expect(result?.id, 'user-123');
      });

      test('should return null when no user is logged in', () {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(null);

        // Act
        final result = datasource.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('deleteAccount', () {
      test('should call edge function account_delete', () async {
        // Arrange
        final mockResponse = FunctionResponse(status: 200, data: null);
        when(() => mockFunctionsClient.invoke(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => mockResponse);

        // Act
        await datasource.deleteAccount();

        // Assert
        verify(() => mockFunctionsClient.invoke(
              'account_delete',
              headers: any(named: 'headers'),
            )).called(1);
      });

      test('should throw when edge function fails', () async {
        // Arrange
        final mockResponse = FunctionResponse(status: 500, data: null);
        when(() => mockFunctionsClient.invoke(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => mockResponse);

        // Act & Assert
        expect(
          () => datasource.deleteAccount(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('uploadAvatar', () {
      test('should upload avatar and return public URL', () async {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const userId = 'user-123';
        const expectedUrl = 'https://storage.example.com/avatars/user-123/profile.jpg';

        when(() => mockStorageClient.from('avatars'))
            .thenReturn(mockStorageFileApi);
        when(() => mockStorageFileApi.uploadBinary(any(), any()))
            .thenAnswer((_) async => 'avatars/user-123/profile.jpg');
        when(() => mockStorageFileApi.getPublicUrl(any()))
            .thenReturn(expectedUrl);

        // Act
        final result = await datasource.uploadAvatar(
          userId,
          bytes,
          'profile.jpg',
        );

        // Assert
        expect(result, expectedUrl);
        verify(() => mockStorageFileApi.uploadBinary(
              any(that: contains(userId)),
              bytes,
            )).called(1);
      });

      test('should use default jpg extension when filename has no extension', () async {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const userId = 'user-123';
        const expectedUrl = 'https://storage.example.com/avatars/user-123/profile.jpg';

        when(() => mockStorageClient.from('avatars'))
            .thenReturn(mockStorageFileApi);
        when(() => mockStorageFileApi.uploadBinary(any(), any()))
            .thenAnswer((_) async => 'avatars/user-123/profile.jpg');
        when(() => mockStorageFileApi.getPublicUrl(any()))
            .thenReturn(expectedUrl);

        // Act
        final result = await datasource.uploadAvatar(
          userId,
          bytes,
          'avatar', // No extension
        );

        // Assert
        expect(result, expectedUrl);
        verify(() => mockStorageFileApi.uploadBinary(
              any(that: contains('.jpg')),
              bytes,
            )).called(1);
      });
    });
  });
}

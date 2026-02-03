/// Tests for UploadGuestMediaUseCase.
///
/// Verifies media validation and upload logic for guest albums.
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/error/failures.dart';
import 'package:lynewed_beta/core/utils/result.dart';
import 'package:lynewed_beta/features/guest/domain/repositories/guest_album_repository.dart';
import 'package:lynewed_beta/features/guest/domain/usecases/upload_guest_media_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockGuestAlbumRepository extends Mock implements GuestAlbumRepository {}

class MockFile extends Mock implements File {}

class FakeFile extends Fake implements File {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  late UploadGuestMediaUseCase useCase;
  late MockGuestAlbumRepository mockRepository;
  late MockFile mockFile;

  setUp(() {
    mockRepository = MockGuestAlbumRepository();
    mockFile = MockFile();
    useCase = UploadGuestMediaUseCase(mockRepository);

    // Default file behavior
    when(() => mockFile.lengthSync()).thenReturn(1024 * 1024); // 1MB
    when(() => mockFile.path).thenReturn('/path/to/test.jpg');
  });

  group('UploadGuestMediaUseCase', () {
    const tWeddingId = 'wedding-123';
    const tMediaId = 'media-456';

    group('Photo Upload', () {
      test('should upload photo successfully when valid', () async {
        // Arrange
        when(() => mockRepository.uploadMedia(
              file: any(named: 'file'),
              weddingId: any(named: 'weddingId'),
              mediaType: any(named: 'mediaType'),
              caption: any(named: 'caption'),
              durationSeconds: any(named: 'durationSeconds'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async => const Success(tMediaId));

        // Act
        final result = await useCase.call(
          file: mockFile,
          weddingId: tWeddingId,
          mediaType: 'photo',
        );

        // Assert
        expect(result, isA<Success<String>>());
        expect((result as Success<String>).data, equals(tMediaId));
        verify(() => mockRepository.uploadMedia(
              file: mockFile,
              weddingId: tWeddingId,
              mediaType: 'photo',
              caption: null,
              durationSeconds: null,
              onProgress: null,
            )).called(1);
      });

      test('should fail when photo exceeds 20MB', () async {
        // Arrange
        when(() => mockFile.lengthSync()).thenReturn(21 * 1024 * 1024); // 21MB

        // Act
        final result = await useCase.call(
          file: mockFile,
          weddingId: tWeddingId,
          mediaType: 'photo',
        );

        // Assert
        expect(result, isA<Failure<String>>());
        final failure = (result as Failure<String>).failure;
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('20'));
        verifyNever(() => mockRepository.uploadMedia(
              file: any(named: 'file'),
              weddingId: any(named: 'weddingId'),
              mediaType: any(named: 'mediaType'),
              caption: any(named: 'caption'),
              durationSeconds: any(named: 'durationSeconds'),
              onProgress: any(named: 'onProgress'),
            ));
      });

      test('should upload photo with caption', () async {
        // Arrange
        const tCaption = 'Beautiful moment!';
        when(() => mockRepository.uploadMedia(
              file: any(named: 'file'),
              weddingId: any(named: 'weddingId'),
              mediaType: any(named: 'mediaType'),
              caption: any(named: 'caption'),
              durationSeconds: any(named: 'durationSeconds'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async => const Success(tMediaId));

        // Act
        final result = await useCase.call(
          file: mockFile,
          weddingId: tWeddingId,
          mediaType: 'photo',
          caption: tCaption,
        );

        // Assert
        expect(result, isA<Success<String>>());
        verify(() => mockRepository.uploadMedia(
              file: mockFile,
              weddingId: tWeddingId,
              mediaType: 'photo',
              caption: tCaption,
              durationSeconds: null,
              onProgress: null,
            )).called(1);
      });
    });

    group('Video Upload', () {
      test('should upload video successfully when valid', () async {
        // Arrange
        when(() => mockFile.path).thenReturn('/path/to/test.mp4');
        when(() => mockFile.lengthSync()).thenReturn(50 * 1024 * 1024); // 50MB
        when(() => mockRepository.uploadMedia(
              file: any(named: 'file'),
              weddingId: any(named: 'weddingId'),
              mediaType: any(named: 'mediaType'),
              caption: any(named: 'caption'),
              durationSeconds: any(named: 'durationSeconds'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async => const Success(tMediaId));

        // Act
        final result = await useCase.call(
          file: mockFile,
          weddingId: tWeddingId,
          mediaType: 'video',
          durationSeconds: 300, // 5 minutes
        );

        // Assert
        expect(result, isA<Success<String>>());
      });

      test('should fail when video exceeds 10 minutes', () async {
        // Arrange
        when(() => mockFile.path).thenReturn('/path/to/test.mp4');
        when(() => mockFile.lengthSync()).thenReturn(100 * 1024 * 1024); // 100MB

        // Act
        final result = await useCase.call(
          file: mockFile,
          weddingId: tWeddingId,
          mediaType: 'video',
          durationSeconds: 700, // 11+ minutes
        );

        // Assert
        expect(result, isA<Failure<String>>());
        final failure = (result as Failure<String>).failure;
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('10 minutes'));
        verifyNever(() => mockRepository.uploadMedia(
              file: any(named: 'file'),
              weddingId: any(named: 'weddingId'),
              mediaType: any(named: 'mediaType'),
              caption: any(named: 'caption'),
              durationSeconds: any(named: 'durationSeconds'),
              onProgress: any(named: 'onProgress'),
            ));
      });

      test('should fail when video exceeds 500MB', () async {
        // Arrange
        when(() => mockFile.path).thenReturn('/path/to/test.mp4');
        when(() => mockFile.lengthSync())
            .thenReturn(600 * 1024 * 1024); // 600MB

        // Act
        final result = await useCase.call(
          file: mockFile,
          weddingId: tWeddingId,
          mediaType: 'video',
          durationSeconds: 300, // 5 minutes (valid)
        );

        // Assert
        expect(result, isA<Failure<String>>());
        final failure = (result as Failure<String>).failure;
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('500'));
        verifyNever(() => mockRepository.uploadMedia(
              file: any(named: 'file'),
              weddingId: any(named: 'weddingId'),
              mediaType: any(named: 'mediaType'),
              caption: any(named: 'caption'),
              durationSeconds: any(named: 'durationSeconds'),
              onProgress: any(named: 'onProgress'),
            ));
      });
    });

    group('Caption Validation', () {
      test('should fail when caption exceeds 500 characters', () async {
        // Arrange
        final longCaption = 'a' * 501;

        // Act
        final result = await useCase.call(
          file: mockFile,
          weddingId: tWeddingId,
          mediaType: 'photo',
          caption: longCaption,
        );

        // Assert
        expect(result, isA<Failure<String>>());
        final failure = (result as Failure<String>).failure;
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('500'));
      });

      test('should allow empty caption', () async {
        // Arrange
        when(() => mockRepository.uploadMedia(
              file: any(named: 'file'),
              weddingId: any(named: 'weddingId'),
              mediaType: any(named: 'mediaType'),
              caption: any(named: 'caption'),
              durationSeconds: any(named: 'durationSeconds'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async => const Success(tMediaId));

        // Act
        final result = await useCase.call(
          file: mockFile,
          weddingId: tWeddingId,
          mediaType: 'photo',
          caption: '',
        );

        // Assert
        expect(result, isA<Success<String>>());
      });

      test('should allow caption at exactly 500 characters', () async {
        // Arrange
        final maxCaption = 'a' * 500;
        when(() => mockRepository.uploadMedia(
              file: any(named: 'file'),
              weddingId: any(named: 'weddingId'),
              mediaType: any(named: 'mediaType'),
              caption: any(named: 'caption'),
              durationSeconds: any(named: 'durationSeconds'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async => const Success(tMediaId));

        // Act
        final result = await useCase.call(
          file: mockFile,
          weddingId: tWeddingId,
          mediaType: 'photo',
          caption: maxCaption,
        );

        // Assert
        expect(result, isA<Success<String>>());
      });
    });

    group('Progress Callback', () {
      test('should forward progress callback to repository', () async {
        // Arrange
        final progressValues = <double>[];
        void onProgress(double progress) => progressValues.add(progress);

        when(() => mockRepository.uploadMedia(
              file: any(named: 'file'),
              weddingId: any(named: 'weddingId'),
              mediaType: any(named: 'mediaType'),
              caption: any(named: 'caption'),
              durationSeconds: any(named: 'durationSeconds'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async => const Success(tMediaId));

        // Act
        await useCase.call(
          file: mockFile,
          weddingId: tWeddingId,
          mediaType: 'photo',
          onProgress: onProgress,
        );

        // Assert
        verify(() => mockRepository.uploadMedia(
              file: mockFile,
              weddingId: tWeddingId,
              mediaType: 'photo',
              caption: null,
              durationSeconds: null,
              onProgress: onProgress,
            )).called(1);
      });
    });

    group('Repository Errors', () {
      test('should propagate repository failure', () async {
        // Arrange
        when(() => mockRepository.uploadMedia(
              file: any(named: 'file'),
              weddingId: any(named: 'weddingId'),
              mediaType: any(named: 'mediaType'),
              caption: any(named: 'caption'),
              durationSeconds: any(named: 'durationSeconds'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer(
            (_) async => const Failure(ServerFailure('Upload failed')));

        // Act
        final result = await useCase.call(
          file: mockFile,
          weddingId: tWeddingId,
          mediaType: 'photo',
        );

        // Assert
        expect(result, isA<Failure<String>>());
        final failure = (result as Failure<String>).failure;
        expect(failure, isA<ServerFailure>());
        expect(failure.message, equals('Upload failed'));
      });
    });
  });
}

/// Tests for DownloadMediaUseCase
///
/// Tests single and multiple media download functionality.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/error/failures.dart';
import 'package:lynewed_beta/core/utils/result.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/download_media_use_case.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockDownloadDataSource extends Mock implements DownloadDataSource {}

class MockFile extends Mock implements File {}

void main() {
  late DownloadMediaUseCase useCase;
  late MockDownloadDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDownloadDataSource();
    useCase = DownloadMediaUseCase(mockDataSource);
  });

  group('DownloadMediaUseCase', () {
    group('downloadSingle', () {
      const testStorageUrl = 'https://example.com/wedding-albums/photo.jpg';
      const testFileName = 'photo.jpg';

      test('should return File on successful download', () async {
        // Arrange
        final mockFile = MockFile();
        when(() => mockDataSource.downloadFile(
              storageUrl: any(named: 'storageUrl'),
              fileName: any(named: 'fileName'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async => Success(mockFile));

        // Act
        final result = await useCase.downloadSingle(
          storageUrl: testStorageUrl,
          fileName: testFileName,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), mockFile);
        verify(() => mockDataSource.downloadFile(
              storageUrl: testStorageUrl,
              fileName: testFileName,
              onProgress: null,
            )).called(1);
      });

      test('should return Failure when download fails', () async {
        // Arrange
        when(() => mockDataSource.downloadFile(
              storageUrl: any(named: 'storageUrl'),
              fileName: any(named: 'fileName'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer(
            (_) async => Failure(const NetworkFailure('Download failed')));

        // Act
        final result = await useCase.downloadSingle(
          storageUrl: testStorageUrl,
          fileName: testFileName,
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'Download failed');
      });

      test('should call onProgress callback during download', () async {
        // Arrange
        final mockFile = MockFile();
        final progressValues = <double>[];

        when(() => mockDataSource.downloadFile(
              storageUrl: any(named: 'storageUrl'),
              fileName: any(named: 'fileName'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((invocation) async {
          // Simulate progress callback
          final onProgress =
              invocation.namedArguments[#onProgress] as Function(double)?;
          onProgress?.call(0.25);
          onProgress?.call(0.50);
          onProgress?.call(0.75);
          onProgress?.call(1.0);
          return Success(mockFile);
        });

        // Act
        await useCase.downloadSingle(
          storageUrl: testStorageUrl,
          fileName: testFileName,
          onProgress: (progress) => progressValues.add(progress),
        );

        // Assert
        expect(progressValues, [0.25, 0.50, 0.75, 1.0]);
      });
    });

    group('downloadMultiple', () {
      final testMediaList = [
        const MediaDownloadInfo(
          mediaId: '1',
          storageUrl: 'https://example.com/photo1.jpg',
          fileName: 'photo1.jpg',
          fileSizeBytes: 1024 * 1024, // 1MB
        ),
        const MediaDownloadInfo(
          mediaId: '2',
          storageUrl: 'https://example.com/photo2.jpg',
          fileName: 'photo2.jpg',
          fileSizeBytes: 2 * 1024 * 1024, // 2MB
        ),
      ];
      const testWeddingId = 'wedding123';

      test('should return zip File on successful multi-download', () async {
        // Arrange
        final mockZipFile = MockFile();
        when(() => mockDataSource.downloadAndZipClientSide(
              mediaList: any(named: 'mediaList'),
              weddingId: any(named: 'weddingId'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((_) async => Success(mockZipFile));

        // Act
        final result = await useCase.downloadMultiple(
          mediaList: testMediaList,
          weddingId: testWeddingId,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull(), mockZipFile);
      });

      test('should return Failure when multi-download fails', () async {
        // Arrange
        when(() => mockDataSource.downloadAndZipClientSide(
              mediaList: any(named: 'mediaList'),
              weddingId: any(named: 'weddingId'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer(
            (_) async => Failure(const ServerFailure('Zip creation failed')));

        // Act
        final result = await useCase.downloadMultiple(
          mediaList: testMediaList,
          weddingId: testWeddingId,
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'Zip creation failed');
      });

      test('should call onProgress callback during multi-download', () async {
        // Arrange
        final mockZipFile = MockFile();
        final progressValues = <double>[];

        when(() => mockDataSource.downloadAndZipClientSide(
              mediaList: any(named: 'mediaList'),
              weddingId: any(named: 'weddingId'),
              onProgress: any(named: 'onProgress'),
            )).thenAnswer((invocation) async {
          final onProgress =
              invocation.namedArguments[#onProgress] as Function(double)?;
          onProgress?.call(0.33);
          onProgress?.call(0.66);
          onProgress?.call(1.0);
          return Success(mockZipFile);
        });

        // Act
        await useCase.downloadMultiple(
          mediaList: testMediaList,
          weddingId: testWeddingId,
          onProgress: (progress) => progressValues.add(progress),
        );

        // Assert
        expect(progressValues, [0.33, 0.66, 1.0]);
      });
    });
  });

  group('MediaDownloadInfo', () {
    test('should create MediaDownloadInfo with required fields', () {
      // Act
      const info = MediaDownloadInfo(
        mediaId: '123',
        storageUrl: 'https://example.com/photo.jpg',
        fileName: 'photo.jpg',
      );

      // Assert
      expect(info.mediaId, '123');
      expect(info.storageUrl, 'https://example.com/photo.jpg');
      expect(info.fileName, 'photo.jpg');
      expect(info.fileSizeBytes, null);
    });

    test('should create MediaDownloadInfo with optional fileSizeBytes', () {
      // Act
      const info = MediaDownloadInfo(
        mediaId: '123',
        storageUrl: 'https://example.com/photo.jpg',
        fileName: 'photo.jpg',
        fileSizeBytes: 1024,
      );

      // Assert
      expect(info.fileSizeBytes, 1024);
    });

    test('should implement equality based on mediaId', () {
      // Act
      const info1 = MediaDownloadInfo(
        mediaId: '123',
        storageUrl: 'url1',
        fileName: 'file1.jpg',
      );
      const info2 = MediaDownloadInfo(
        mediaId: '123',
        storageUrl: 'url2',
        fileName: 'file2.jpg',
      );
      const info3 = MediaDownloadInfo(
        mediaId: '456',
        storageUrl: 'url1',
        fileName: 'file1.jpg',
      );

      // Assert
      expect(info1, equals(info2));
      expect(info1, isNot(equals(info3)));
    });
  });
}

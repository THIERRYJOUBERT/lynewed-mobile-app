/// Tests for DownloadDataSourceImpl
///
/// Tests the data source implementation for downloading media files.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lynewed_beta/features/my_wedding/data/datasources/download_data_source_impl.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/download_media_use_case.dart';
import 'package:mocktail/mocktail.dart';

// Mock HTTP client
class MockHttpClient extends Mock implements http.Client {}

class MockStreamedResponse extends Mock implements http.StreamedResponse {}

void main() {
  setUpAll(() {
    // Register fallback values
    registerFallbackValue(http.Request('GET', Uri.parse('https://example.com')));
  });

  group('DownloadDataSourceImpl', () {
    group('downloadFile', () {
      test('should return Failure on HTTP error', () async {
        // Arrange
        final mockClient = MockHttpClient();
        final mockResponse = MockStreamedResponse();

        when(() => mockClient.send(any())).thenAnswer((_) async => mockResponse);
        when(() => mockResponse.statusCode).thenReturn(404);

        final dataSource = DownloadDataSourceImpl(httpClient: mockClient);

        // Act
        final result = await dataSource.downloadFile(
          storageUrl: 'https://example.com/photo.jpg',
          fileName: 'photo.jpg',
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, contains('HTTP 404'));
      });

      test('should return Failure on network error', () async {
        // Arrange
        final mockClient = MockHttpClient();

        when(() => mockClient.send(any())).thenThrow(
          const SocketException('No internet'),
        );

        final dataSource = DownloadDataSourceImpl(httpClient: mockClient);

        // Act
        final result = await dataSource.downloadFile(
          storageUrl: 'https://example.com/photo.jpg',
          fileName: 'photo.jpg',
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'No internet connection');
      });
    });

    group('downloadAndZipClientSide', () {
      test('should return Failure when first download fails', () async {
        // Arrange
        final mockClient = MockHttpClient();
        final mockResponse = MockStreamedResponse();

        when(() => mockClient.send(any())).thenAnswer((_) async => mockResponse);
        when(() => mockResponse.statusCode).thenReturn(500);

        final dataSource = DownloadDataSourceImpl(httpClient: mockClient);

        final mediaList = [
          const MediaDownloadInfo(
            mediaId: '1',
            storageUrl: 'https://example.com/photo1.jpg',
            fileName: 'photo1.jpg',
          ),
        ];

        // Act
        final result = await dataSource.downloadAndZipClientSide(
          mediaList: mediaList,
          weddingId: 'wedding123',
        );

        // Assert
        expect(result.isFailure, true);
      });

      test('should return Failure on network error during multi-download',
          () async {
        // Arrange
        final mockClient = MockHttpClient();

        when(() => mockClient.send(any())).thenThrow(
          const SocketException('No internet'),
        );

        final dataSource = DownloadDataSourceImpl(httpClient: mockClient);

        final mediaList = [
          const MediaDownloadInfo(
            mediaId: '1',
            storageUrl: 'https://example.com/photo1.jpg',
            fileName: 'photo1.jpg',
          ),
        ];

        // Act
        final result = await dataSource.downloadAndZipClientSide(
          mediaList: mediaList,
          weddingId: 'wedding123',
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.failureOrNull()?.message, 'No internet connection');
      });
    });
  });
}

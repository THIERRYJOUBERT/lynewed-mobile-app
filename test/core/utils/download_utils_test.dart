/// Tests for DownloadUtils
///
/// Tests utility functions for file downloads and zip creation.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/utils/download_utils.dart';

void main() {
  group('DownloadUtils', () {
    group('generateUniqueFileName', () {
      test('should add timestamp to filename with extension', () {
        // Act
        final result = DownloadUtils.generateUniqueFileName('photo.jpg');

        // Assert
        expect(result, matches(RegExp(r'^photo_\d+\.jpg$')));
      });

      test('should add timestamp to filename without extension', () {
        // Act
        final result = DownloadUtils.generateUniqueFileName('photo');

        // Assert
        expect(result, matches(RegExp(r'^photo_\d+$')));
      });

      test('should handle filename with multiple dots', () {
        // Act
        final result = DownloadUtils.generateUniqueFileName('my.photo.2024.jpg');

        // Assert
        expect(result, matches(RegExp(r'^my\.photo\.2024_\d+\.jpg$')));
      });

      test('should generate different names for subsequent calls', () async {
        // Act
        final result1 = DownloadUtils.generateUniqueFileName('photo.jpg');
        await Future.delayed(const Duration(milliseconds: 2));
        final result2 = DownloadUtils.generateUniqueFileName('photo.jpg');

        // Assert - timestamps should be different
        expect(result1, isNot(equals(result2)));
      });
    });

    group('getFileExtension', () {
      test('should return extension for jpg file', () {
        // Act
        final result = DownloadUtils.getFileExtension('photo.jpg');

        // Assert
        expect(result, 'jpg');
      });

      test('should return extension for png file', () {
        // Act
        final result = DownloadUtils.getFileExtension('image.png');

        // Assert
        expect(result, 'png');
      });

      test('should return extension for mp4 file', () {
        // Act
        final result = DownloadUtils.getFileExtension('video.mp4');

        // Assert
        expect(result, 'mp4');
      });

      test('should return empty string for file without extension', () {
        // Act
        final result = DownloadUtils.getFileExtension('photo');

        // Assert
        expect(result, '');
      });

      test('should handle file with multiple dots', () {
        // Act
        final result = DownloadUtils.getFileExtension('my.photo.2024.jpg');

        // Assert
        expect(result, 'jpg');
      });

      test('should return lowercase extension', () {
        // Act
        final result = DownloadUtils.getFileExtension('PHOTO.JPG');

        // Assert
        expect(result, 'jpg');
      });
    });

    group('isVideoFile', () {
      test('should return true for mp4 files', () {
        expect(DownloadUtils.isVideoFile('video.mp4'), true);
      });

      test('should return true for mov files', () {
        expect(DownloadUtils.isVideoFile('video.mov'), true);
      });

      test('should return true for m4v files', () {
        expect(DownloadUtils.isVideoFile('video.m4v'), true);
      });

      test('should return true for avi files', () {
        expect(DownloadUtils.isVideoFile('video.avi'), true);
      });

      test('should return false for jpg files', () {
        expect(DownloadUtils.isVideoFile('photo.jpg'), false);
      });

      test('should return false for png files', () {
        expect(DownloadUtils.isVideoFile('image.png'), false);
      });

      test('should be case insensitive', () {
        expect(DownloadUtils.isVideoFile('video.MP4'), true);
        expect(DownloadUtils.isVideoFile('video.MOV'), true);
      });
    });

    group('generateZipFileName', () {
      test('should create zip filename with wedding ID and timestamp', () {
        // Act
        final result = DownloadUtils.generateZipFileName('wedding123');

        // Assert
        expect(result, matches(RegExp(r'^wedding123_media_\d+\.zip$')));
      });

      test('should generate different names for subsequent calls', () async {
        // Act
        final result1 = DownloadUtils.generateZipFileName('wedding123');
        await Future.delayed(const Duration(milliseconds: 2));
        final result2 = DownloadUtils.generateZipFileName('wedding123');

        // Assert
        expect(result1, isNot(equals(result2)));
      });
    });

    group('formatFileSize', () {
      test('should format bytes correctly', () {
        expect(DownloadUtils.formatFileSize(500), '500 B');
      });

      test('should format kilobytes correctly', () {
        expect(DownloadUtils.formatFileSize(1024), '1.0 KB');
        expect(DownloadUtils.formatFileSize(1536), '1.5 KB');
      });

      test('should format megabytes correctly', () {
        expect(DownloadUtils.formatFileSize(1024 * 1024), '1.0 MB');
        expect(DownloadUtils.formatFileSize(1024 * 1024 * 5), '5.0 MB');
      });

      test('should format gigabytes correctly', () {
        expect(DownloadUtils.formatFileSize(1024 * 1024 * 1024), '1.0 GB');
      });

      test('should return 0 B for 0 bytes', () {
        expect(DownloadUtils.formatFileSize(0), '0 B');
      });

      test('should return 0 B for negative values', () {
        expect(DownloadUtils.formatFileSize(-100), '0 B');
      });
    });
  });
}

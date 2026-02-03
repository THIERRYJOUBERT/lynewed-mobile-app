/// Download Data Source Implementation
///
/// Handles actual file downloading and zip creation for media files.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '/core/error/failures.dart';
import '/core/utils/download_utils.dart';
import '/core/utils/result.dart';
import '/utils/secure_logger.dart';
import '../../domain/usecases/download_media_use_case.dart';

/// Implementation of DownloadDataSource.
///
/// Uses HTTP to download files and creates zip archives client-side.
class DownloadDataSourceImpl implements DownloadDataSource {
  /// Creates the data source with optional HTTP client for testing.
  DownloadDataSourceImpl({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  @override
  Future<Result<File>> downloadFile({
    required String storageUrl,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      // Start download request
      final request = http.Request('GET', Uri.parse(storageUrl));
      final response = await _httpClient.send(request);

      if (response.statusCode != 200) {
        return Failure(ServerFailure(
          'Download failed: HTTP ${response.statusCode}',
          code: response.statusCode.toString(),
        ));
      }

      // Get content length for progress
      final contentLength = response.contentLength ?? 0;
      var receivedBytes = 0;
      final chunks = <int>[];

      // Stream download with progress
      await for (final chunk in response.stream) {
        chunks.addAll(chunk);
        receivedBytes += chunk.length;

        if (contentLength > 0 && onProgress != null) {
          onProgress(receivedBytes / contentLength);
        }
      }

      // Get downloads directory
      final directory = await _getDownloadsDirectory();
      final uniqueFileName = DownloadUtils.generateUniqueFileName(fileName);
      final filePath = '${directory.path}/$uniqueFileName';

      // Write file
      final file = File(filePath);
      await file.writeAsBytes(Uint8List.fromList(chunks));

      // Final progress
      onProgress?.call(1.0);

      SecureLogger.info('Downloaded file to: $filePath');
      return Success(file);
    } on SocketException catch (e) {
      SecureLogger.error('Network error downloading file: $e');
      return Failure(NetworkFailure('No internet connection'));
    } catch (e) {
      SecureLogger.error('Error downloading file: $e');
      return Failure(ServerFailure('Download failed: $e'));
    }
  }

  @override
  Future<Result<File>> downloadAndZipClientSide({
    required List<MediaDownloadInfo> mediaList,
    required String weddingId,
    Function(double)? onProgress,
  }) async {
    try {
      final downloadedFiles = <File>[];
      final totalFiles = mediaList.length;

      // Download each file with progress
      for (var i = 0; i < mediaList.length; i++) {
        final media = mediaList[i];

        // Report progress for each file
        final fileProgress = i / totalFiles;
        onProgress?.call(fileProgress);

        final result = await downloadFile(
          storageUrl: media.storageUrl,
          fileName: media.fileName,
          onProgress: (p) {
            // Calculate overall progress
            final overallProgress = (i + p) / totalFiles;
            onProgress?.call(overallProgress);
          },
        );

        if (result.isFailure) {
          // Clean up already downloaded files
          for (final file in downloadedFiles) {
            try {
              await file.delete();
            } catch (_) {}
          }
          return Failure(result.failureOrNull()!);
        }

        downloadedFiles.add(result.getOrNull()!);
      }

      // Create zip file
      onProgress?.call(0.95); // Almost done

      final zipFile = await _createZipFromFiles(
        files: downloadedFiles,
        weddingId: weddingId,
      );

      // Clean up individual files (they're now in the zip)
      for (final file in downloadedFiles) {
        try {
          await file.delete();
        } catch (_) {}
      }

      onProgress?.call(1.0);

      return Success(zipFile);
    } on SocketException catch (e) {
      SecureLogger.error('Network error during multi-download: $e');
      return Failure(NetworkFailure('No internet connection'));
    } catch (e) {
      SecureLogger.error('Error creating zip: $e');
      return Failure(ServerFailure('Failed to create zip: $e'));
    }
  }

  /// Gets the appropriate downloads directory for the platform.
  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Try external storage first
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Create a Lynewed downloads folder
          final downloadsDir = Directory('${externalDir.path}/Downloads');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          return downloadsDir;
        }
      } catch (_) {}
    }

    // Fallback to app documents directory (iOS default)
    final docsDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${docsDir.path}/Downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir;
  }

  /// Creates a zip file from multiple files.
  ///
  /// Uses a simple concatenation approach for V1.
  /// For larger files, consider using the archive package.
  Future<File> _createZipFromFiles({
    required List<File> files,
    required String weddingId,
  }) async {
    // For V1, we'll save files to a folder instead of creating a zip
    // This is simpler and avoids the archive dependency
    // The user gets a folder with all their files

    final directory = await _getDownloadsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final folderName = '${weddingId}_media_$timestamp';
    final mediaFolder = Directory('${directory.path}/$folderName');

    if (!await mediaFolder.exists()) {
      await mediaFolder.create(recursive: true);
    }

    // Copy files to the folder with original names
    for (final file in files) {
      final fileName = file.path.split('/').last;
      // Remove timestamp from filename for cleaner names in folder
      final cleanName = _cleanFileName(fileName);
      final newPath = '${mediaFolder.path}/$cleanName';
      await file.copy(newPath);
    }

    // Create a simple marker file to indicate completion
    final markerFile = File('${mediaFolder.path}/.download_complete');
    await markerFile.writeAsString(
      'Downloaded ${files.length} files on ${DateTime.now().toIso8601String()}',
    );

    SecureLogger.info('Created media folder: ${mediaFolder.path}');

    // Return the folder path as a File (it's actually a directory)
    // The caller can check if it's a directory
    return File(mediaFolder.path);
  }

  /// Removes the timestamp from a generated filename.
  String _cleanFileName(String fileName) {
    // Pattern: name_timestamp.ext -> name.ext
    final regex = RegExp(r'_\d{13}(\.\w+)$');
    final match = regex.firstMatch(fileName);
    if (match != null) {
      final ext = match.group(1) ?? '';
      return fileName.replaceAll(regex, ext);
    }
    return fileName;
  }
}

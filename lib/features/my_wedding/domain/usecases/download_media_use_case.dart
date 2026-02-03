/// Download Media Use Case - handles downloading photos and videos.
///
/// Supports single file download with progress tracking and multiple file
/// download with client-side zip creation.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import '/core/utils/result.dart';

/// Data source interface for download operations.
///
/// Implemented by the data layer to perform actual file downloads.
abstract class DownloadDataSource {
  /// Downloads a single file from storage.
  ///
  /// [storageUrl] - Full URL to the file in storage.
  /// [fileName] - Name to save the file as.
  /// [onProgress] - Optional callback for download progress (0.0 to 1.0).
  Future<Result<File>> downloadFile({
    required String storageUrl,
    required String fileName,
    Function(double)? onProgress,
  });

  /// Downloads multiple files and creates a zip archive.
  ///
  /// [mediaList] - List of media items to download.
  /// [weddingId] - Wedding ID for naming the zip file.
  /// [onProgress] - Optional callback for overall progress (0.0 to 1.0).
  Future<Result<File>> downloadAndZipClientSide({
    required List<MediaDownloadInfo> mediaList,
    required String weddingId,
    Function(double)? onProgress,
  });
}

/// Use case for downloading media files.
///
/// Provides methods for single and multiple file downloads with
/// progress tracking support.
class DownloadMediaUseCase {
  /// Creates the use case with the required data source.
  const DownloadMediaUseCase(this._dataSource);

  final DownloadDataSource _dataSource;

  /// Downloads a single media file.
  ///
  /// Returns a [File] pointing to the downloaded file on success.
  /// Progress is reported via [onProgress] callback (0.0 to 1.0).
  Future<Result<File>> downloadSingle({
    required String storageUrl,
    required String fileName,
    Function(double)? onProgress,
  }) {
    return _dataSource.downloadFile(
      storageUrl: storageUrl,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  /// Downloads multiple media files as a zip archive.
  ///
  /// For small batches (<= 10 files, < 50MB total), creates zip client-side.
  /// Returns a [File] pointing to the zip file on success.
  Future<Result<File>> downloadMultiple({
    required List<MediaDownloadInfo> mediaList,
    required String weddingId,
    Function(double)? onProgress,
  }) {
    return _dataSource.downloadAndZipClientSide(
      mediaList: mediaList,
      weddingId: weddingId,
      onProgress: onProgress,
    );
  }
}

/// Information about a media file to download.
///
/// Contains all necessary data to download and identify a media file.
@immutable
class MediaDownloadInfo {
  /// Creates a MediaDownloadInfo.
  const MediaDownloadInfo({
    required this.mediaId,
    required this.storageUrl,
    required this.fileName,
    this.fileSizeBytes,
  });

  /// Unique identifier for the media.
  final String mediaId;

  /// Full URL to download the file from.
  final String storageUrl;

  /// Original filename for saving.
  final String fileName;

  /// File size in bytes (optional, used for progress calculation).
  final int? fileSizeBytes;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaDownloadInfo && other.mediaId == mediaId;
  }

  @override
  int get hashCode => mediaId.hashCode;

  @override
  String toString() => 'MediaDownloadInfo($mediaId, $fileName)';
}

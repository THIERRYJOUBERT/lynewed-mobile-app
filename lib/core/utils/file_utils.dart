import 'dart:convert';
import 'dart:typed_data' show Uint8List;

/// Represents an uploaded file with optional metadata.
///
/// This is a Clean Architecture replacement for FlutterFlow's FFUploadedFile.
/// Provides an immutable representation of a file with serialization support.
///
/// Example:
/// ```dart
/// final file = UploadedFile(
///   name: 'photo.jpg',
///   bytes: imageBytes,
///   width: 1920.0,
///   height: 1080.0,
/// );
///
/// if (file.isNotEmpty) {
///   // Process the file
/// }
/// ```
class UploadedFile {
  /// The file name with extension.
  final String? name;

  /// The file content as bytes.
  final Uint8List? bytes;

  /// The height of the file (for images).
  final double? height;

  /// The width of the file (for images).
  final double? width;

  /// The BlurHash of the file (for images).
  final String? blurHash;

  /// Creates an uploaded file.
  const UploadedFile({
    this.name,
    this.bytes,
    this.height,
    this.width,
    this.blurHash,
  });

  /// Returns true if the file has no content.
  bool get isEmpty => bytes == null || bytes!.isEmpty;

  /// Returns true if the file has content.
  bool get isNotEmpty => !isEmpty;

  /// Creates a copy of this file with the given fields replaced.
  UploadedFile copyWith({
    String? name,
    Uint8List? bytes,
    double? height,
    double? width,
    String? blurHash,
  }) {
    return UploadedFile(
      name: name ?? this.name,
      bytes: bytes ?? this.bytes,
      height: height ?? this.height,
      width: width ?? this.width,
      blurHash: blurHash ?? this.blurHash,
    );
  }

  /// Serializes this file to a JSON string.
  String serialize() => jsonEncode({
        'name': name,
        'bytes': bytes,
        'height': height,
        'width': width,
        'blurHash': blurHash,
      });

  /// Deserializes an uploaded file from a JSON string.
  static UploadedFile deserialize(String val) {
    final serializedData = jsonDecode(val) as Map<String, dynamic>;
    final data = {
      'name': serializedData['name'] ?? '',
      'bytes': serializedData['bytes'] ?? <int>[],
      'height': serializedData['height'],
      'width': serializedData['width'],
      'blurHash': serializedData['blurHash'],
    };
    return UploadedFile(
      name: data['name'] as String,
      bytes: Uint8List.fromList((data['bytes'] as List).cast<int>().toList()),
      height: data['height'] as double?,
      width: data['width'] as double?,
      blurHash: data['blurHash'] as String?,
    );
  }

  @override
  String toString() =>
      'UploadedFile(name: $name, bytes: ${bytes?.length ?? 0}, height: $height, width: $width, blurHash: $blurHash,)';

  @override
  int get hashCode => Object.hash(
        name,
        bytes,
        height,
        width,
        blurHash,
      );

  @override
  bool operator ==(Object other) =>
      other is UploadedFile &&
      name == other.name &&
      bytes == other.bytes &&
      height == other.height &&
      width == other.width &&
      blurHash == other.blurHash;
}

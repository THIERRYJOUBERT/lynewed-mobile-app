import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/utils/file_utils.dart';

void main() {
  group('UploadedFile', () {
    group('constructor', () {
      test('should create UploadedFile with all fields', () {
        final bytes = Uint8List.fromList([1, 2, 3]);
        final file = UploadedFile(
          name: 'test.jpg',
          bytes: bytes,
          height: 100.0,
          width: 200.0,
          blurHash: 'L6PZfSi_.AyE_3t7t7R**0o#DgR4',
        );

        expect(file.name, 'test.jpg');
        expect(file.bytes, bytes);
        expect(file.height, 100.0);
        expect(file.width, 200.0);
        expect(file.blurHash, 'L6PZfSi_.AyE_3t7t7R**0o#DgR4');
      });

      test('should allow null fields', () {
        const file = UploadedFile();

        expect(file.name, isNull);
        expect(file.bytes, isNull);
        expect(file.height, isNull);
        expect(file.width, isNull);
        expect(file.blurHash, isNull);
      });
    });

    group('toString', () {
      test('should return formatted string with bytes length', () {
        final file = UploadedFile(
          name: 'test.jpg',
          bytes: Uint8List.fromList([1, 2, 3]),
          height: 100.0,
          width: 200.0,
        );

        final str = file.toString();
        expect(str, contains('test.jpg'));
        expect(str, contains('3')); // bytes length
        expect(str, contains('100.0')); // height
        expect(str, contains('200.0')); // width
      });

      test('should handle null bytes in toString', () {
        const file = UploadedFile(name: 'test.jpg');

        final str = file.toString();
        expect(str, contains('0')); // bytes length should be 0
      });
    });

    group('serialize/deserialize', () {
      test('should serialize to JSON string', () {
        final file = UploadedFile(
          name: 'test.jpg',
          bytes: Uint8List.fromList([1, 2, 3]),
          height: 100.0,
          width: 200.0,
          blurHash: 'hash123',
        );

        final serialized = file.serialize();
        final decoded = jsonDecode(serialized);

        expect(decoded['name'], 'test.jpg');
        expect(decoded['height'], 100.0);
        expect(decoded['width'], 200.0);
        expect(decoded['blurHash'], 'hash123');
      });

      test('should deserialize from JSON string', () {
        final original = UploadedFile(
          name: 'test.jpg',
          bytes: Uint8List.fromList([1, 2, 3]),
          height: 100.0,
          width: 200.0,
          blurHash: 'hash123',
        );

        final serialized = original.serialize();
        final deserialized = UploadedFile.deserialize(serialized);

        expect(deserialized.name, 'test.jpg');
        expect(deserialized.bytes, Uint8List.fromList([1, 2, 3]));
        expect(deserialized.height, 100.0);
        expect(deserialized.width, 200.0);
        expect(deserialized.blurHash, 'hash123');
      });

      test('should handle missing optional fields in deserialization', () {
        const json = '{"name": "test.jpg", "bytes": [1, 2]}';
        final file = UploadedFile.deserialize(json);

        expect(file.name, 'test.jpg');
        expect(file.bytes, Uint8List.fromList([1, 2]));
        expect(file.height, isNull);
        expect(file.width, isNull);
        expect(file.blurHash, isNull);
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        final bytes = Uint8List.fromList([1, 2, 3]);
        final file1 = UploadedFile(
          name: 'test.jpg',
          bytes: bytes,
          height: 100.0,
          width: 200.0,
        );
        final file2 = UploadedFile(
          name: 'test.jpg',
          bytes: bytes,
          height: 100.0,
          width: 200.0,
        );

        expect(file1, equals(file2));
      });

      test('should not be equal for different names', () {
        final bytes = Uint8List.fromList([1, 2, 3]);
        final file1 = UploadedFile(name: 'test1.jpg', bytes: bytes);
        final file2 = UploadedFile(name: 'test2.jpg', bytes: bytes);

        expect(file1, isNot(equals(file2)));
      });

      test('should have same hashCode for equal objects', () {
        final bytes = Uint8List.fromList([1, 2, 3]);
        final file1 = UploadedFile(
          name: 'test.jpg',
          bytes: bytes,
          height: 100.0,
          width: 200.0,
        );
        final file2 = UploadedFile(
          name: 'test.jpg',
          bytes: bytes,
          height: 100.0,
          width: 200.0,
        );

        expect(file1.hashCode, equals(file2.hashCode));
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final original = UploadedFile(
          name: 'original.jpg',
          bytes: Uint8List.fromList([1, 2, 3]),
          height: 100.0,
          width: 200.0,
        );

        final copy = original.copyWith(name: 'modified.jpg');

        expect(copy.name, 'modified.jpg');
        expect(copy.bytes, original.bytes);
        expect(copy.height, original.height);
        expect(copy.width, original.width);
      });

      test('should keep original values when not specified', () {
        final original = UploadedFile(
          name: 'test.jpg',
          bytes: Uint8List.fromList([1, 2, 3]),
        );

        final copy = original.copyWith();

        expect(copy.name, original.name);
        expect(copy.bytes, original.bytes);
      });
    });

    group('isEmpty', () {
      test('should return true when bytes is null', () {
        const file = UploadedFile(name: 'test.jpg');
        expect(file.isEmpty, isTrue);
      });

      test('should return true when bytes is empty', () {
        final file = UploadedFile(
          name: 'test.jpg',
          bytes: Uint8List(0),
        );
        expect(file.isEmpty, isTrue);
      });

      test('should return false when bytes has content', () {
        final file = UploadedFile(
          name: 'test.jpg',
          bytes: Uint8List.fromList([1, 2, 3]),
        );
        expect(file.isEmpty, isFalse);
      });
    });

    group('isNotEmpty', () {
      test('should return false when bytes is null', () {
        const file = UploadedFile(name: 'test.jpg');
        expect(file.isNotEmpty, isFalse);
      });

      test('should return true when bytes has content', () {
        final file = UploadedFile(
          name: 'test.jpg',
          bytes: Uint8List.fromList([1, 2, 3]),
        );
        expect(file.isNotEmpty, isTrue);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/models/lat_lng.dart';

void main() {
  group('LatLng', () {
    group('constructor', () {
      test('should create LatLng with latitude and longitude', () {
        const latLng = LatLng(48.8566, 2.3522);

        expect(latLng.latitude, 48.8566);
        expect(latLng.longitude, 2.3522);
      });

      test('should handle zero coordinates', () {
        const latLng = LatLng(0.0, 0.0);

        expect(latLng.latitude, 0.0);
        expect(latLng.longitude, 0.0);
      });

      test('should handle negative coordinates', () {
        const latLng = LatLng(-33.8688, 151.2093);

        expect(latLng.latitude, -33.8688);
        expect(latLng.longitude, 151.2093);
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        const latLng = LatLng(48.8566, 2.3522);

        expect(latLng.toString(), 'LatLng(lat: 48.8566, lng: 2.3522)');
      });
    });

    group('serialize', () {
      test('should return comma-separated coordinates', () {
        const latLng = LatLng(48.8566, 2.3522);

        expect(latLng.serialize(), '48.8566,2.3522');
      });
    });

    group('deserialize', () {
      test('should parse comma-separated coordinates', () {
        final latLng = LatLng.deserialize('48.8566,2.3522');

        expect(latLng.latitude, 48.8566);
        expect(latLng.longitude, 2.3522);
      });

      test('should handle negative coordinates', () {
        final latLng = LatLng.deserialize('-33.8688,151.2093');

        expect(latLng.latitude, -33.8688);
        expect(latLng.longitude, 151.2093);
      });

      test('should handle whitespace in coordinates', () {
        final latLng = LatLng.deserialize(' 48.8566 , 2.3522 ');

        expect(latLng.latitude, 48.8566);
        expect(latLng.longitude, 2.3522);
      });

      test('should throw FormatException for malformed input', () {
        expect(
          () => LatLng.deserialize('invalid'),
          throwsA(isA<FormatException>()),
        );
      });

      test('should throw FormatException for missing comma', () {
        expect(
          () => LatLng.deserialize('48.8566'),
          throwsA(isA<FormatException>()),
        );
      });

      test('should throw FormatException for non-numeric values', () {
        expect(
          () => LatLng.deserialize('abc,def'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('equality', () {
      test('should be equal for same coordinates', () {
        const latLng1 = LatLng(48.8566, 2.3522);
        const latLng2 = LatLng(48.8566, 2.3522);

        expect(latLng1, equals(latLng2));
      });

      test('should not be equal for different coordinates', () {
        const latLng1 = LatLng(48.8566, 2.3522);
        const latLng2 = LatLng(40.7128, -74.0060);

        expect(latLng1, isNot(equals(latLng2)));
      });

      test('should have same hashCode for equal objects', () {
        const latLng1 = LatLng(48.8566, 2.3522);
        const latLng2 = LatLng(48.8566, 2.3522);

        expect(latLng1.hashCode, equals(latLng2.hashCode));
      });
    });
  });
}

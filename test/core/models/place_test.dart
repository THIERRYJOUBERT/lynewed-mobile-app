import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/models/lat_lng.dart';
import 'package:lynewed_beta/core/models/place.dart';

void main() {
  group('Place', () {
    group('constructor', () {
      test('should create Place with all fields', () {
        const place = Place(
          latLng: LatLng(48.8566, 2.3522),
          name: 'Eiffel Tower',
          address: '5 Avenue Anatole France',
          city: 'Paris',
          state: 'Ile-de-France',
          country: 'France',
          zipCode: '75007',
        );

        expect(place.latLng.latitude, 48.8566);
        expect(place.latLng.longitude, 2.3522);
        expect(place.name, 'Eiffel Tower');
        expect(place.address, '5 Avenue Anatole France');
        expect(place.city, 'Paris');
        expect(place.state, 'Ile-de-France');
        expect(place.country, 'France');
        expect(place.zipCode, '75007');
      });

      test('should use default values', () {
        const place = Place();

        expect(place.latLng.latitude, 0.0);
        expect(place.latLng.longitude, 0.0);
        expect(place.name, '');
        expect(place.address, '');
        expect(place.city, '');
        expect(place.state, '');
        expect(place.country, '');
        expect(place.zipCode, '');
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        const place = Place(
          latLng: LatLng(48.8566, 2.3522),
          name: 'Test Place',
          address: 'Test Address',
          city: 'Test City',
          state: 'Test State',
          country: 'Test Country',
          zipCode: '12345',
        );

        final str = place.toString();
        expect(str, contains('Place'));
        expect(str, contains('Test Place'));
        expect(str, contains('Test Address'));
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        const original = Place(
          latLng: LatLng(48.8566, 2.3522),
          name: 'Original',
          city: 'Paris',
        );

        final copy = original.copyWith(
          name: 'Modified',
          city: 'Lyon',
        );

        expect(copy.latLng, original.latLng);
        expect(copy.name, 'Modified');
        expect(copy.city, 'Lyon');
        expect(copy.address, original.address);
      });

      test('should keep original values when not specified', () {
        const original = Place(
          latLng: LatLng(48.8566, 2.3522),
          name: 'Original',
          address: 'Original Address',
        );

        final copy = original.copyWith();

        expect(copy.latLng, original.latLng);
        expect(copy.name, original.name);
        expect(copy.address, original.address);
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        const place1 = Place(
          latLng: LatLng(48.8566, 2.3522),
          name: 'Test',
          city: 'Paris',
        );
        const place2 = Place(
          latLng: LatLng(48.8566, 2.3522),
          name: 'Test',
          city: 'Paris',
        );

        expect(place1, equals(place2));
      });

      test('should not be equal for different values', () {
        const place1 = Place(name: 'Place 1');
        const place2 = Place(name: 'Place 2');

        expect(place1, isNot(equals(place2)));
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/utils/form_utils.dart';

void main() {
  group('FormFieldController', () {
    group('constructor', () {
      test('should initialize with value', () {
        final controller = FormFieldController<String>('initial');

        expect(controller.value, 'initial');
        expect(controller.initialValue, 'initial');
      });

      test('should allow null initial value', () {
        final controller = FormFieldController<String>(null);

        expect(controller.value, isNull);
        expect(controller.initialValue, isNull);
      });
    });

    group('reset', () {
      test('should reset to initial value', () {
        final controller = FormFieldController<String>('initial');
        controller.value = 'modified';

        controller.reset();

        expect(controller.value, 'initial');
      });

      test('should reset to null if initial was null', () {
        final controller = FormFieldController<String>(null);
        controller.value = 'modified';

        controller.reset();

        expect(controller.value, isNull);
      });
    });

    group('update', () {
      test('should notify listeners', () {
        final controller = FormFieldController<String>('initial');
        var notified = false;
        controller.addListener(() => notified = true);

        controller.update();

        expect(notified, isTrue);
      });
    });

    group('value setter', () {
      test('should update value', () {
        final controller = FormFieldController<String>('initial');

        controller.value = 'new value';

        expect(controller.value, 'new value');
      });

      test('should notify listeners on value change', () {
        final controller = FormFieldController<int>(0);
        var notified = false;
        controller.addListener(() => notified = true);

        controller.value = 42;

        expect(notified, isTrue);
      });
    });

    group('dispose', () {
      test('should dispose without error', () {
        final controller = FormFieldController<String>('test');

        expect(() => controller.dispose(), returnsNormally);
      });
    });
  });

  group('FormListFieldController', () {
    group('constructor', () {
      test('should initialize with list value', () {
        final controller = FormListFieldController<String>(['a', 'b', 'c']);

        expect(controller.value, ['a', 'b', 'c']);
      });

      test('should create defensive copy of initial value', () {
        final original = ['a', 'b'];
        final controller = FormListFieldController<String>(original);

        // Modify original should not affect controller's initial value
        original.add('c');

        controller.reset();
        expect(controller.value, ['a', 'b']);
      });

      test('should handle null initial value', () {
        final controller = FormListFieldController<String>(null);

        expect(controller.value, isNull);
      });
    });

    group('reset', () {
      test('should reset to initial list value', () {
        final controller = FormListFieldController<int>([1, 2, 3]);
        controller.value = [4, 5, 6];

        controller.reset();

        expect(controller.value, [1, 2, 3]);
      });

      test('should create new list instance on reset', () {
        final controller = FormListFieldController<int>([1, 2, 3]);
        final original = controller.value;
        controller.value = [4, 5, 6];

        controller.reset();

        // Should be equal but not the same instance
        expect(controller.value, [1, 2, 3]);
        expect(identical(controller.value, original), isFalse);
      });
    });

    group('value modification', () {
      test('should allow adding items to value', () {
        final controller = FormListFieldController<String>(['a']);
        controller.value = [...controller.value ?? [], 'b'];

        expect(controller.value, ['a', 'b']);
      });

      test('should notify listeners on modification', () {
        final controller = FormListFieldController<int>([1]);
        var notified = false;
        controller.addListener(() => notified = true);

        controller.value = [1, 2];

        expect(notified, isTrue);
      });
    });
  });
}

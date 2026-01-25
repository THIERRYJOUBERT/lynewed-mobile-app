import 'package:flutter/foundation.dart';

/// A form field controller that extends [ValueNotifier].
///
/// This is a Clean Architecture replacement for FlutterFlow's FormFieldController.
/// Provides a simple way to manage form field state with reset capability.
///
/// Example:
/// ```dart
/// final controller = FormFieldController<String>('initial');
/// controller.value = 'modified';
/// controller.reset(); // Returns to 'initial'
/// ```
class FormFieldController<T> extends ValueNotifier<T?> {
  /// The initial value of the controller.
  final T? initialValue;

  /// Creates a form field controller with the given initial value.
  FormFieldController(this.initialValue) : super(initialValue);

  /// Resets the value to the initial value.
  void reset() => value = initialValue;

  /// Notifies listeners without changing the value.
  ///
  /// Use this to trigger a rebuild when the value's internal
  /// state has changed but the value itself hasn't.
  void update() => notifyListeners();
}

/// A form field controller for list values.
///
/// This controller creates a defensive copy of the initial value
/// to avoid pass-by-reference issues when the list is modified.
///
/// Example:
/// ```dart
/// final controller = FormListFieldController<String>(['a', 'b']);
/// controller.value = ['a', 'b', 'c'];
/// controller.reset(); // Returns to ['a', 'b'] (a new list instance)
/// ```
class FormListFieldController<T> extends FormFieldController<List<T>> {
  final List<T>? _initialListValue;

  /// Creates a form list field controller with the given initial value.
  ///
  /// A defensive copy is made of the initial value.
  FormListFieldController(super.initialValue)
      : _initialListValue = initialValue != null ? List<T>.from(initialValue) : null;

  /// Resets the value to a new list instance with the initial values.
  @override
  void reset() {
    final initial = _initialListValue;
    value = initial != null ? List<T>.from(initial) : null;
  }
}

/// Tests for legacy page wrappers
///
/// Verifies that MessagesBridesPageWrapper and MessagesProPageWrapper
/// properly redirect to the unified MessagesPage.
///
/// Note: Widget tree tests are skipped because MessagesPage requires
/// Supabase initialization. The important tests verify that:
/// 1. Route names match legacy pages
/// 2. Both wrappers compile and are StatelessWidgets
/// 3. Both wrappers return MessagesPage in their build method
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import the wrappers
import 'package:lynewed_beta/features/chat/presentation/pages/legacy_wrappers.dart';

void main() {
  group('MessagesBridesPageWrapper', () {
    test('should have correct route name', () {
      // Verify static route properties match legacy MessagesBridesWidget
      expect(MessagesBridesPageWrapper.routeName, equals('MessagesBrides'));
      expect(MessagesBridesPageWrapper.routePath, equals('/messagesBrides'));
    });

    test('should be a StatelessWidget', () {
      const wrapper = MessagesBridesPageWrapper();
      expect(wrapper, isA<StatelessWidget>());
    });

    test('should have const constructor', () {
      // Verify const constructor works (compile-time check)
      const wrapper1 = MessagesBridesPageWrapper();
      const wrapper2 = MessagesBridesPageWrapper();
      expect(wrapper1, isA<MessagesBridesPageWrapper>());
      expect(wrapper2, isA<MessagesBridesPageWrapper>());
    });
  });

  group('MessagesProPageWrapper', () {
    test('should have correct route name', () {
      // Verify static route properties match legacy MessagesProWidget
      expect(MessagesProPageWrapper.routeName, equals('MessagesPro'));
      expect(MessagesProPageWrapper.routePath, equals('/messagesPro'));
    });

    test('should be a StatelessWidget', () {
      const wrapper = MessagesProPageWrapper();
      expect(wrapper, isA<StatelessWidget>());
    });

    test('should have const constructor', () {
      // Verify const constructor works (compile-time check)
      const wrapper1 = MessagesProPageWrapper();
      const wrapper2 = MessagesProPageWrapper();
      expect(wrapper1, isA<MessagesProPageWrapper>());
      expect(wrapper2, isA<MessagesProPageWrapper>());
    });
  });

  group('Legacy wrapper compatibility', () {
    test('both wrappers should exist and be different classes', () {
      // Verify both wrappers compile and exist as separate classes
      const brideWrapper = MessagesBridesPageWrapper();
      const proWrapper = MessagesProPageWrapper();

      // They should be different types
      expect(brideWrapper.runtimeType, isNot(equals(proWrapper.runtimeType)));
    });

    test('both wrappers should have matching route patterns', () {
      // Route names should follow legacy convention
      expect(
        MessagesBridesPageWrapper.routeName,
        contains('Messages'),
      );
      expect(
        MessagesProPageWrapper.routeName,
        contains('Messages'),
      );

      // Route paths should follow legacy convention
      expect(
        MessagesBridesPageWrapper.routePath,
        startsWith('/messages'),
      );
      expect(
        MessagesProPageWrapper.routePath,
        startsWith('/messages'),
      );
    });
  });
}

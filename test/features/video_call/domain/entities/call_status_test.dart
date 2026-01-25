/// Tests for CallStatus enum.
///
/// Tests covering:
/// - All expected values exist
/// - Computed properties work correctly
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/video_call/domain/entities/call_status.dart';

void main() {
  group('CallStatus', () {
    test('should have all expected values', () {
      expect(CallStatus.values, contains(CallStatus.initial));
      expect(CallStatus.values, contains(CallStatus.connecting));
      expect(CallStatus.values, contains(CallStatus.ringing));
      expect(CallStatus.values, contains(CallStatus.connected));
      expect(CallStatus.values, contains(CallStatus.ended));
      expect(CallStatus.values, contains(CallStatus.error));
    });

    test('should have 6 values', () {
      expect(CallStatus.values.length, 6);
    });

    group('isActive', () {
      test('should return true for connecting status', () {
        expect(CallStatus.connecting.isActive, true);
      });

      test('should return true for ringing status', () {
        expect(CallStatus.ringing.isActive, true);
      });

      test('should return true for connected status', () {
        expect(CallStatus.connected.isActive, true);
      });

      test('should return false for initial status', () {
        expect(CallStatus.initial.isActive, false);
      });

      test('should return false for ended status', () {
        expect(CallStatus.ended.isActive, false);
      });

      test('should return false for error status', () {
        expect(CallStatus.error.isActive, false);
      });
    });

    group('canEndCall', () {
      test('should return true for connecting status', () {
        expect(CallStatus.connecting.canEndCall, true);
      });

      test('should return true for ringing status', () {
        expect(CallStatus.ringing.canEndCall, true);
      });

      test('should return true for connected status', () {
        expect(CallStatus.connected.canEndCall, true);
      });

      test('should return false for initial status', () {
        expect(CallStatus.initial.canEndCall, false);
      });

      test('should return false for ended status', () {
        expect(CallStatus.ended.canEndCall, false);
      });

      test('should return false for error status', () {
        expect(CallStatus.error.canEndCall, false);
      });
    });

    group('isTerminal', () {
      test('should return true for ended status', () {
        expect(CallStatus.ended.isTerminal, true);
      });

      test('should return true for error status', () {
        expect(CallStatus.error.isTerminal, true);
      });

      test('should return false for initial status', () {
        expect(CallStatus.initial.isTerminal, false);
      });

      test('should return false for connecting status', () {
        expect(CallStatus.connecting.isTerminal, false);
      });

      test('should return false for ringing status', () {
        expect(CallStatus.ringing.isTerminal, false);
      });

      test('should return false for connected status', () {
        expect(CallStatus.connected.isTerminal, false);
      });
    });

    group('displayName', () {
      test('should return Initializing for initial', () {
        expect(CallStatus.initial.displayName, 'Initializing...');
      });

      test('should return Connecting for connecting', () {
        expect(CallStatus.connecting.displayName, 'Connecting...');
      });

      test('should return Ringing for ringing', () {
        expect(CallStatus.ringing.displayName, 'Ringing...');
      });

      test('should return Connected for connected', () {
        expect(CallStatus.connected.displayName, 'Connected');
      });

      test('should return Call Ended for ended', () {
        expect(CallStatus.ended.displayName, 'Call Ended');
      });

      test('should return Error for error', () {
        expect(CallStatus.error.displayName, 'Error');
      });
    });
  });
}

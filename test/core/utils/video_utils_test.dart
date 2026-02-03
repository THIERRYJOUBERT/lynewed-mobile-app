import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/utils/video_utils.dart';

void main() {
  group('VideoConstants', () {
    test('maxDurationSeconds should be 600 (10 minutes)', () {
      expect(VideoConstants.maxDurationSeconds, 600);
    });

    test('maxFileSizeBytes should be 524288000 (500 MB)', () {
      expect(VideoConstants.maxFileSizeBytes, 524288000);
    });

    test('allowedExtensions should contain mp4, mov, m4v', () {
      expect(VideoConstants.allowedExtensions, contains('mp4'));
      expect(VideoConstants.allowedExtensions, contains('mov'));
      expect(VideoConstants.allowedExtensions, contains('m4v'));
      expect(VideoConstants.allowedExtensions.length, 3);
    });

    test('maxDurationFormatted should return 10 minutes', () {
      expect(VideoConstants.maxDurationFormatted, '10 minutes');
    });

    test('maxFileSizeFormatted should return 500 MB', () {
      expect(VideoConstants.maxFileSizeFormatted, '500 MB');
    });
  });

  group('VideoValidationResult', () {
    group('valid', () {
      test('should create valid result with duration and file size', () {
        const result = VideoValidationResult.valid(
          durationSeconds: 300,
          fileSizeBytes: 100000000,
        );

        expect(result.isValid, true);
        expect(result.error, isNull);
        expect(result.durationSeconds, 300);
        expect(result.fileSizeBytes, 100000000);
      });
    });

    group('invalid', () {
      test('should create invalid result with error message', () {
        const result = VideoValidationResult.invalid(
          'Video must be 10 minutes or less',
        );

        expect(result.isValid, false);
        expect(result.error, 'Video must be 10 minutes or less');
        expect(result.durationSeconds, isNull);
        expect(result.fileSizeBytes, isNull);
      });
    });
  });

  group('validateVideoExtension', () {
    test('should accept mp4 extension', () {
      final result = validateVideoExtension('video.mp4');
      expect(result.isValid, true);
    });

    test('should accept mov extension', () {
      final result = validateVideoExtension('video.mov');
      expect(result.isValid, true);
    });

    test('should accept m4v extension', () {
      final result = validateVideoExtension('video.m4v');
      expect(result.isValid, true);
    });

    test('should accept uppercase extensions', () {
      final result = validateVideoExtension('video.MP4');
      expect(result.isValid, true);
    });

    test('should accept mixed case extensions', () {
      final result = validateVideoExtension('video.MoV');
      expect(result.isValid, true);
    });

    test('should reject invalid extension avi', () {
      final result = validateVideoExtension('video.avi');
      expect(result.isValid, false);
      expect(result.error, 'Please select an MP4, MOV, or M4V video');
    });

    test('should reject invalid extension mkv', () {
      final result = validateVideoExtension('video.mkv');
      expect(result.isValid, false);
      expect(result.error, 'Please select an MP4, MOV, or M4V video');
    });

    test('should reject file without extension', () {
      final result = validateVideoExtension('video');
      expect(result.isValid, false);
      expect(result.error, 'Please select an MP4, MOV, or M4V video');
    });

    test('should handle path with multiple dots', () {
      final result = validateVideoExtension('/path/to/my.video.file.mp4');
      expect(result.isValid, true);
    });
  });

  group('validateVideoFileSize', () {
    test('should accept file size under 500 MB', () {
      final result = validateVideoFileSize(100000000); // 100 MB
      expect(result.isValid, true);
    });

    test('should accept file size exactly 500 MB', () {
      final result = validateVideoFileSize(524288000);
      expect(result.isValid, true);
    });

    test('should reject file size over 500 MB', () {
      final result = validateVideoFileSize(524288001); // 500 MB + 1 byte
      expect(result.isValid, false);
      expect(result.error, 'Video must be 500 MB or less');
    });

    test('should accept zero file size', () {
      final result = validateVideoFileSize(0);
      expect(result.isValid, true);
    });

    test('should reject very large file size', () {
      final result = validateVideoFileSize(1073741824); // 1 GB
      expect(result.isValid, false);
      expect(result.error, 'Video must be 500 MB or less');
    });
  });

  group('validateVideoDuration', () {
    test('should accept duration under 10 minutes', () {
      final result = validateVideoDuration(300); // 5 minutes
      expect(result.isValid, true);
    });

    test('should accept duration exactly 10 minutes', () {
      final result = validateVideoDuration(600);
      expect(result.isValid, true);
    });

    test('should reject duration over 10 minutes', () {
      final result = validateVideoDuration(601); // 10 min + 1 sec
      expect(result.isValid, false);
      expect(result.error, 'Video must be 10 minutes or less');
    });

    test('should accept zero duration', () {
      final result = validateVideoDuration(0);
      expect(result.isValid, true);
    });

    test('should reject very long duration', () {
      final result = validateVideoDuration(3600); // 1 hour
      expect(result.isValid, false);
      expect(result.error, 'Video must be 10 minutes or less');
    });
  });

  group('isVideoExtension', () {
    test('should return true for mp4', () {
      expect(isVideoExtension('mp4'), true);
    });

    test('should return true for mov', () {
      expect(isVideoExtension('mov'), true);
    });

    test('should return true for m4v', () {
      expect(isVideoExtension('m4v'), true);
    });

    test('should return false for jpg', () {
      expect(isVideoExtension('jpg'), false);
    });

    test('should return false for png', () {
      expect(isVideoExtension('png'), false);
    });

    test('should be case insensitive', () {
      expect(isVideoExtension('MP4'), true);
      expect(isVideoExtension('MOV'), true);
      expect(isVideoExtension('M4V'), true);
    });
  });

  group('getExtension', () {
    test('should extract extension from simple filename', () {
      expect(getExtension('video.mp4'), 'mp4');
    });

    test('should extract extension from path with dots', () {
      expect(getExtension('/path/to/my.video.file.mov'), 'mov');
    });

    test('should return empty string for no extension', () {
      expect(getExtension('video'), '');
    });

    test('should handle empty string', () {
      expect(getExtension(''), '');
    });

    test('should handle file ending with dot', () {
      expect(getExtension('video.'), '');
    });
  });

  group('formatDuration', () {
    test('should format seconds only', () {
      expect(formatDuration(45), '0:45');
    });

    test('should format minutes and seconds', () {
      expect(formatDuration(125), '2:05');
    });

    test('should format exactly 10 minutes', () {
      expect(formatDuration(600), '10:00');
    });

    test('should handle zero', () {
      expect(formatDuration(0), '0:00');
    });

    test('should format single digit seconds with leading zero', () {
      expect(formatDuration(61), '1:01');
    });
  });

  group('formatFileSize', () {
    test('should format bytes', () {
      expect(formatFileSize(500), '500 B');
    });

    test('should format kilobytes', () {
      expect(formatFileSize(1536), '1.5 KB');
    });

    test('should format megabytes', () {
      expect(formatFileSize(5242880), '5.0 MB');
    });

    test('should format 500 MB', () {
      expect(formatFileSize(524288000), '500.0 MB');
    });

    test('should format gigabytes', () {
      expect(formatFileSize(1073741824), '1.0 GB');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bili/app/service/video_service.dart';

void main() {
  late VideoService service;

  setUp(() {
    service = VideoService.i;
  });

  group('VideoService.selectBestQuality', () {
    test('returns 80 (default) for empty list', () {
      expect(service.selectBestQuality([]), 80);
    });

    test('returns 116 for single-element list [116]', () {
      expect(service.selectBestQuality([116]), 116);
    });

    test('returns 32 (higher priority) from [32, 16]', () {
      expect(service.selectBestQuality([32, 16]), 32);
    });

    test('returns 116 (highest priority) from full list [116, 80, 64, 32, 16]', () {
      expect(service.selectBestQuality([116, 80, 64, 32, 16]), 116);
    });

    test('returns 64 for single-element list [64]', () {
      expect(service.selectBestQuality([64]), 64);
    });

    test('returns 80 when 116 is not available but 80 is', () {
      expect(service.selectBestQuality([80, 64, 32]), 80);
    });

    test('returns 16 when only 16 is available', () {
      expect(service.selectBestQuality([16]), 16);
    });

    test('priority order: 116 > 80 > 64 > 32 > 16', () {
      // Verify each step of the priority chain
      expect(service.selectBestQuality([80, 64]), 80);
      expect(service.selectBestQuality([64, 32]), 64);
      expect(service.selectBestQuality([32, 16]), 32);
    });
  });
}

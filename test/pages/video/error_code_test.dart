import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bili/feature/video/video_detail_page.dart';

void main() {
  group('mapErrorCode', () {
    test('-404 maps to string containing "不存在" or "已被删除"', () {
      final result = mapErrorCode(-404, null);
      expect(
        result.contains('不存在') || result.contains('已被删除'),
        isTrue,
        reason: 'Expected "$result" to contain "不存在" or "已被删除"',
      );
    });

    test('87008 maps to string containing "专属" or "充电"', () {
      final result = mapErrorCode(87008, null);
      expect(
        result.contains('专属') || result.contains('充电'),
        isTrue,
        reason: 'Expected "$result" to contain "专属" or "充电"',
      );
    });

    test('code 0 with message returns non-empty string', () {
      final result = mapErrorCode(0, 'success');
      expect(result.isNotEmpty, isTrue);
    });

    test('null code with message returns the message', () {
      final result = mapErrorCode(null, '自定义错误');
      expect(result, '自定义错误');
    });

    test('unknown code with null message returns non-empty fallback', () {
      final result = mapErrorCode(99999, null);
      expect(result.isNotEmpty, isTrue);
    });
  });
}

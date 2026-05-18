import 'dart:convert';
import 'dart:io';

void main() async {
  final env = {
    '此环境变量由脚本自动生成': '请勿编辑',
    'ENABLE_FLEX_OVERFLOW': false
  };
  File('./.vscode/env.json')
    ..createSync(recursive: true)
    ..writeAsStringSync(jsonEncode(env));
}

// // 获取 Git 提交数量作为版本号
// Future<int> _getGitCommitCount() async {
//   try {
//     final result = await Process.run('git', ['rev-list', '--count', 'HEAD']);
//     if (result.exitCode == 0) {
//       return int.tryParse(result.stdout.toString().trim()) ?? 0;
//     }
//   } catch (e) {
//     print('获取 Git 提交数量失败: $e');
//   }
//   return 0;
// }

// // 获取 Git 提交哈希值
// Future<String> _getGitCommitHash() async {
//   try {
//     final result = await Process.run('git', ['rev-parse', 'HEAD']);
//     if (result.exitCode == 0) {
//       return result.stdout.toString().trim();
//     }
//   } catch (e) {
//     print('获取 Git 提交哈希值失败: $e');
//   }
//   return '';
// }

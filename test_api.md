# API 412错误修复说明

## 问题原因
412 Precondition Failed 错误通常是因为B站服务器检测到请求缺少必要的请求头，特别是：
- `user-agent`: 浏览器标识
- `referer`: 来源页面

## 修复方案
在 `lib/http/request.dart` 中添加了必要的请求头：

```dart
headers: {
  'user-agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
  'referer': 'https://www.bilibili.com',
},
```

## 参考
这个修复参考了 PiliPlus 项目的实现：
- PiliPlus/lib/http/init.dart 中的请求头配置
- 使用标准的浏览器 User-Agent
- 添加 referer 表明请求来源

## 测试
修复后，推荐视频接口应该能正常返回数据，不再出现412错误。

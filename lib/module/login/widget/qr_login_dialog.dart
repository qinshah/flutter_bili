import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';

import '../../../core/http/loading_state.dart';
import '../../../core/http/login_http.dart';
import '../../../service/auth_s.dart';
import 'qr_code_poller.dart';

class QrLoginDialog extends StatefulWidget {
  const QrLoginDialog({super.key});

  @override
  State<QrLoginDialog> createState() => _QrLoginDialogState();
}

class _QrLoginDialogState extends State<QrLoginDialog> {
  String? _qrUrl;
  bool _loading = false;
  String? _error;
  bool _expired = false;
  QrCodePoller? _poller;

  @override
  void initState() {
    super.initState();
    unawaited(_loadQrCode());
  }

  @override
  void dispose() {
    _poller?.dispose();
    super.dispose();
  }

  Future<void> _loadQrCode() async {
    _poller?.dispose();
    _poller = null;

    setState(() {
      _loading = true;
      _error = null;
      _expired = false;
      _qrUrl = null;
    });

    final result = await LoginHttp.getAuthCode();

    if (!mounted) return;

    switch (result) {
      case Success(:final response):
        final authService = Provider.of<AuthS>(context, listen: false);
        _poller = QrCodePoller(
          authService: authService,
          onExpired: () {
            if (mounted) setState(() => _expired = true);
          },
          onError: (msg) {
            if (mounted) setState(() => _error = msg);
          },
          onSuccess: () async {
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        );
        _poller!.start(response.authCode);

        setState(() {
          _qrUrl = response.url;
          _loading = false;
        });

      case Error(:final message):
        setState(() {
          _error = message ?? '获取二维码失败';
          _loading = false;
        });
    }
  }

  Widget _buildQrContent() {
    if (_loading) {
      return const SizedBox(
        width: 200,
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_expired) {
      return SizedBox(
        width: 200,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            const Text(
              '二维码已过期，请刷新',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadQrCode,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('刷新'),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        width: 200,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadQrCode,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_qrUrl != null) {
      return Container(
        width: 200,
        height: 200,
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: PrettyQrView.data(
          data: _qrUrl!,
          decoration: const PrettyQrDecoration(
            shape: PrettyQrSquaresSymbol(
              color: Colors.black87,
            ),
          ),
        ),
      );
    }

    return const SizedBox(width: 200, height: 200);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('扫码登录'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '请使用哔哩哔哩 App 扫码',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildQrContent(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }
}

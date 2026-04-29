import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';

import '../../core/http/loading_state.dart';
import '../../core/http/login_http.dart';
import '../../service/auth_service.dart';
import 'widget/qr_code_poller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _qrUrl;
  bool _loading = false;
  String? _error;
  bool _expired = false;
  QrCodePoller? _poller;

  @override
  void initState() {
    super.initState();
    _loadQrCode();
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
        // 直接保存URL字符串，不创建QrCode和QrImage
        final authService = Provider.of<AuthService>(context, listen: false);
        _poller = QrCodePoller(
          authService: authService,
          onExpired: () {
            if (mounted) setState(() => _expired = true);
          },
          onError: (msg) {
            if (mounted) setState(() => _error = msg);
          },
          onSuccess: () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');
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
        width: 240,
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_expired) {
      return SizedBox(
        width: 240,
        height: 240,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              '二维码已过期，请刷新',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadQrCode,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新'),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        width: 240,
        height: 240,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadQrCode,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_qrUrl != null) {
      return Container(
        width: 240,
        height: 240,
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

    return const SizedBox(width: 240, height: 240);
  }

  Widget _buildNarrowLayout() {
    return Scaffold(
      appBar: AppBar(title: const Text('扫码登录')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '请使用哔哩哔哩 App 扫码登录',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildQrContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: SizedBox(
                width: 320,
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '扫码登录',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '请使用哔哩哔哩 App 扫码',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      _buildQrContent(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 添加关闭按钮
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: '关闭',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return _buildWideLayout();
        } else {
          return _buildNarrowLayout();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';

class NotFoundPV extends StatelessWidget {
  const NotFoundPV(this.reason, {super.key});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 100, color: Colors.orange),
            const Text('页面未找到'),
            Text(reason),
          ],
        ),
      ),
    );
  }
}

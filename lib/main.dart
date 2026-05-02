import 'package:flutter/material.dart';
import 'package:flutter_bili/core/router.dart';
import 'package:flutter_bili/module/dynamic/dynamic_page_vm.dart';
import 'package:flutter_bili/module/home/recommend_vm.dart';
import 'package:flutter_bili/module/video/video_page_vm.dart';
import 'package:flutter_bili/service/auth_s.dart';
import 'package:flutter_bili/service/media_s.dart';
import 'package:flutter_bili/service/storage_s.dart';
import 'package:provider/provider.dart';
import 'package:rinf/rinf.dart';
import 'package:u_service/u_service.dart';
import 'src/bindings/bindings.dart';

Future<void> main() async {
  await initializeRust(assignRustSignal);
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([StorageS.init(), USystemS.initWindowManager()]);
  MediaS.initLib();
  AuthS.i.loadLocalCredential();

  runApp(const BiliApp());
}

class BiliApp extends StatelessWidget {
  const BiliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MediaS>.value(value: MediaS.i),
        ChangeNotifierProvider<AuthS>.value(value: AuthS.i),
        ChangeNotifierProvider<RecommendVm>.value(
          value: RecommendVm.i,
        ),
        ChangeNotifierProvider<DynamicPageVm>.value(
          value: DynamicPageVm.i,
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFFB7299),
        ),
      ),
    );
  }
}

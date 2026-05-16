import 'package:flutter_bili/route/my_route.dart';

/// 路由监听器单例
// ignore: non_constant_identifier_names
final RO = GlobalRO._i;

class GlobalRO extends MyRouteObserver {
  GlobalRO._();

  static final _i = GlobalRO._();

  // @override
  // void didPop(Route route, Route? previousRoute) {
  //   super.didPop(route, previousRoute);
  //   print(
  //     'route: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}',
  //   );
  // }
}

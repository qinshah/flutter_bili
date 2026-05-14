import 'package:flutter/widgets.dart';

class RouterObserver extends NavigatorObserver {
  factory RouterObserver() => _i;
  RouterObserver._();

  static final _i = RouterObserver._();

  @override
  void didPop(Route route, Route? previousRoute) {
    // print(
    //   'route: ${route.settings.name}, previousRoute: ${previousRoute?.settings.name}',
    // );
  }
}

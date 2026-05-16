import 'package:flutter/widgets.dart';

/// A [Navigator] observer that notifies [MyRouteAware]s of changes to the
/// state of their [Route].
///
/// [MyRouteObserver] informs subscribers whenever a route of type `R` is pushed
/// on top of their own route of type `R` or popped from it. This is for example
/// useful to keep track of page transitions, e.g. a `RouteObserver<PageRoute>`
/// will inform subscribed [MyRouteAware]s whenever the user navigates away from
/// the current page route to another page route.
///
/// To be informed about route changes of any type, consider instantiating a
/// `RouteObserver<Route>`.
///
/// ## Type arguments
///
/// When using more aggressive [lints](https://dart.dev/lints),
/// in particular lints such as `always_specify_types`,
/// the Dart analyzer will require that certain types
/// be given with their type arguments. Since the [Route] class and its
/// subclasses have a type argument, this includes the arguments passed to this
/// class. Consider using `dynamic` to specify the entire class of routes rather
/// than only specific subtypes. For example, to watch for all [ModalRoute]
/// variants, the `RouteObserver<ModalRoute<dynamic>>` type may be used.
///
/// {@tool dartpad}
/// This example demonstrates how to implement a [MyRouteObserver] that notifies
/// [MyRouteAware] widget of changes to the state of their [Route].
///
/// ** See code in examples/api/lib/widgets/routes/route_observer.0.dart **
/// {@end-tool}
///
/// See also:
///  * [MyRouteAware], this is used with [MyRouteObserver] to make a widget aware
///   of changes to the [Navigator]'s session history.
class MyRouteObserver<R extends Route<dynamic>> extends NavigatorObserver {
  final Map<R, Set<MyRouteAware>> _listeners = <R, Set<MyRouteAware>>{};

  /// Whether this observer is managing changes for the specified route.
  ///
  /// If asserts are disabled, this method will throw an exception.
  @visibleForTesting
  bool debugObservingRoute(R route) {
    late bool contained;
    assert(() {
      contained = _listeners.containsKey(route);
      return true;
    }());
    return contained;
  }

  /// Subscribe [routeAware] to be informed about changes to [route].
  ///
  /// Going forward, [routeAware] will be informed about qualifying changes
  /// to [route], e.g. when [route] is covered by another route or when [route]
  /// is popped off the [Navigator] stack.
  void subscribe(MyRouteAware routeAware, R route) {
    final Set<MyRouteAware> subscribers = _listeners.putIfAbsent(
      route,
      () => <MyRouteAware>{},
    );
    if (subscribers.add(routeAware)) {
      routeAware.didPush();
    }
  }

  /// Unsubscribe [routeAware].
  ///
  /// [routeAware] is no longer informed about changes to its route. If the given argument was
  /// subscribed to multiple types, this will unregister it (once) from each type.
  void unsubscribe(MyRouteAware routeAware) {
    final List<R> routes = _listeners.keys.toList();
    for (final route in routes) {
      final Set<MyRouteAware>? subscribers = _listeners[route];
      if (subscribers != null) {
        subscribers.remove(routeAware);
        if (subscribers.isEmpty) {
          _listeners.remove(route);
        }
      }
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is R && previousRoute is R) {
      final List<MyRouteAware>? previousSubscribers = _listeners[previousRoute]
          ?.toList();

      if (previousSubscribers != null) {
        for (final MyRouteAware routeAware in previousSubscribers) {
          routeAware.didPopNext(route);
        }
      }

      final List<MyRouteAware>? subscribers = _listeners[route]?.toList();

      if (subscribers != null) {
        for (final MyRouteAware routeAware in subscribers) {
          routeAware.didPop(previousRoute);
        }
      }
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is R && previousRoute is R) {
      final Set<MyRouteAware>? previousSubscribers = _listeners[previousRoute];

      if (previousSubscribers != null) {
        for (final MyRouteAware routeAware in previousSubscribers) {
          routeAware.didPushNext(route);
        }
      }
    }
  }
}

/// An interface for objects that are aware of their current [Route].
///
/// This is used with [MyRouteObserver] to make a widget aware of changes to the
/// [Navigator]'s session history.
abstract mixin class MyRouteAware {
  /// 下一个页面弹出，回到本页面
  ///
  /// Called when the top route has been popped off, and the current route
  /// shows up.
  void didPopNext(Route<dynamic> nextRoute) {}

  /// 本页面被压入
  ///
  /// Called when the current route has been pushed.
  void didPush() {}

  /// 弹出本页面，回到之前的页面
  ///
  /// Called when the current route has been popped off.
  void didPop(Route<dynamic> previousRoute) {}

  /// 在本页面压入下一个页面
  ///
  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  void didPushNext(Route<dynamic> nextRoute) {}
}

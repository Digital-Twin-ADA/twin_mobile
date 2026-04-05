import 'package:ada_project/features/test/screens/test_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';
import '../../shared/screens/loading_screen.dart';
import '../../shared/widgets/layout.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // final AsyncValue<UserAccount> account = ref.watch(authenticationProvider);
  // final AsyncValue<profile_model.Profile> profile = ref.watch(profileProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/auth',
    routes: <RouteBase>[
      // GoRoute(
      //     path: '/auth',
      //     name: 'Auth',
      //     builder: (context, state) => const AuthenticationScreen(),
      //     redirect: (context, state) {
      //       if (state.uri.toString() == '/auth') {
      //         final accountState = account;
      //         var isAuthenticated = accountState.value?.isAuthenticated;
      //         return isAuthenticated ?? false ? '/home' : null;
      //       }
      //     }
      // ),
      GoRoute(
        path: '/loading',
        name: 'Loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Layout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              name: 'Home',
              builder: (context, state) => const MyApp(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/test',
              name: 'Test',
              builder: (context, state) => TestScreen(),
            ),
          ]),
        ],
      ),
    ],
    // redirect: (context, state) {
    //   // final accountState = account;
    //   // final profileState = profile;
    //
    //   // if (accountState is AsyncLoading || profileState is AsyncLoading) {
    //   //   return '/loading';
    //   // }
    //   //
    //   // if (accountState is AsyncError || profileState is AsyncError) {
    //   //   return '/error';
    //   // }
    //   //
    //   // var isAuthenticated = accountState.value?.isAuthenticated;
    //   // var profileExists = profileState.value?.id != null;
    //
    //   // if (isAuthenticated == null) {
    //   //   return '/loading';
    //   // }
    //   //
    //   // if (!isAuthenticated) {
    //   //   return '/auth';
    //   }
    //
    //   // if (isAuthenticated && !profileExists) {
    //   //   return '/create-profile';
    //   // }
    //
    //   // return null;
    // },
  );
});
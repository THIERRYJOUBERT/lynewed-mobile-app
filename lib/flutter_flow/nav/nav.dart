import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/backend/schema/structs/index.dart';

import '/auth/base_auth_user_provider.dart';

import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';
import '/features/chat/presentation/pages/chat_details_page.dart';
import '/features/notifications/presentation/bloc/notifications_cubit.dart';
import '/features/wishlist/presentation/pages/wishlist_pro_page.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => appStateNotifier.loggedIn
          ? const StartupGateWidget()
          : const AuthWelcomePageWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.loggedIn
              ? const StartupGateWidget()
              : const AuthWelcomePageWidget(),
        ),
        FFRoute(
          name: SignUpEmailPageWidget.routeName,
          path: SignUpEmailPageWidget.routePath,
          builder: (context, params) => const SignUpEmailPageWidget(),
        ),
        FFRoute(
          name: SignInEmailPageWidget.routeName,
          path: SignInEmailPageWidget.routePath,
          builder: (context, params) => const SignInEmailPageWidget(),
        ),
        FFRoute(
          name: ForgotPasswordPageWidget.routeName,
          path: ForgotPasswordPageWidget.routePath,
          builder: (context, params) => const ForgotPasswordPageWidget(),
        ),
        FFRoute(
          name: AuthWelcomePageWidget.routeName,
          path: AuthWelcomePageWidget.routePath,
          builder: (context, params) => const AuthWelcomePageWidget(),
        ),
        FFRoute(
          name: ProDetailsWidget.routeName,
          path: ProDetailsWidget.routePath,
          builder: (context, params) => ProDetailsWidget(
            proDetails: params.getParam(
              'proDetails',
              ParamType.DataStruct,
              isList: false,
              structBuilder: ProDetailsStruct.fromSerializableMap,
            ),
          ),
        ),
        FFRoute(
          name: HomeBridesWidget.routeName,
          path: HomeBridesWidget.routePath,
          builder: (context, params) => const HomeBridesWidget(),
        ),
        FFRoute(
          name: FeedBridesWidget.routeName,
          path: FeedBridesWidget.routePath,
          builder: (context, params) => const FeedBridesWidget(),
        ),
        FFRoute(
          name: MessagesBridesPageWrapper.routeName,
          path: MessagesBridesPageWrapper.routePath,
          builder: (context, params) => const MessagesBridesPageWrapper(),
        ),
        FFRoute(
          name: MapBridesLargeWidget.routeName,
          path: MapBridesLargeWidget.routePath,
          builder: (context, params) => MapBridesLargeWidget(
            initialCenter: params.getParam(
              'initialCenter',
              ParamType.LatLng,
            ),
          ),
        ),
        FFRoute(
          name: DashboardProWidget.routeName,
          path: DashboardProWidget.routePath,
          builder: (context, params) => const DashboardProWidget(),
        ),
        FFRoute(
          name: ProfileBridesAndProWidget.routeName,
          path: ProfileBridesAndProWidget.routePath,
          builder: (context, params) => const ProfileBridesAndProWidget(),
        ),
        FFRoute(
          name: EditProfileBridesWidget.routeName,
          path: EditProfileBridesWidget.routePath,
          builder: (context, params) => const EditProfileBridesWidget(),
        ),
        FFRoute(
          name: NotificationSettingsPage.routeName,
          path: NotificationSettingsPage.routePath,
          builder: (context, params) => const NotificationSettingsPage(),
        ),
        FFRoute(
          name: PreferenceWidget.routeName,
          path: PreferenceWidget.routePath,
          builder: (context, params) => const PreferenceWidget(),
        ),
        FFRoute(
          name: SettingsPermissionsWidget.routeName,
          path: SettingsPermissionsWidget.routePath,
          builder: (context, params) => const SettingsPermissionsWidget(),
        ),
        FFRoute(
          name: WeddingOfTheWeekWidget.routeName,
          path: WeddingOfTheWeekWidget.routePath,
          builder: (context, params) => const WeddingOfTheWeekWidget(),
        ),
        FFRoute(
          name: MapProLargeWidget.routeName,
          path: MapProLargeWidget.routePath,
          builder: (context, params) => MapProLargeWidget(
            initialCenter: params.getParam(
              'initialCenter',
              ParamType.LatLng,
            ),
          ),
        ),
        FFRoute(
          name: OnboardingBridesWizardWidget.routeName,
          path: OnboardingBridesWizardWidget.routePath,
          builder: (context, params) => const OnboardingBridesWizardWidget(),
        ),
        FFRoute(
          name: SupportWidget.routeName,
          path: SupportWidget.routePath,
          builder: (context, params) => const SupportWidget(),
        ),
        // ChatDetailsWidget route removed - use ChatDetailsPage from features/chat instead
        FFRoute(
          name: ContentReplayWidget.routeName,
          path: ContentReplayWidget.routePath,
          builder: (context, params) => const ContentReplayWidget(),
        ),
        FFRoute(
          name: ReplayPlayerPageWidget.routeName,
          path: ReplayPlayerPageWidget.routePath,
          builder: (context, params) => ReplayPlayerPageWidget(
            videoUrl: params.getParam(
              'videoUrl',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: PortfolioImageViewerWidget.routeName,
          path: PortfolioImageViewerWidget.routePath,
          builder: (context, params) => PortfolioImageViewerWidget(
            portfolioImages: params.getParam<String>(
              'portfolioImages',
              ParamType.String,
              isList: true,
            ),
            initialIndex: params.getParam(
              'initialIndex',
              ParamType.int,
            ),
            proInfo: params.getParam(
              'proInfo',
              ParamType.DataStruct,
              isList: false,
              structBuilder: ProDetailsStruct.fromSerializableMap,
            ),
          ),
        ),
        FFRoute(
          name: FeedDetailViewerWidget.routeName,
          path: FeedDetailViewerWidget.routePath,
          builder: (context, params) => FeedDetailViewerWidget(
            feedInfosPro: params.getParam(
              'feedInfosPro',
              ParamType.DataStruct,
              isList: false,
              structBuilder: FeedImageItemStruct.fromSerializableMap,
            ),
          ),
        ),
        FFRoute(
          name: MessagesProPageWrapper.routeName,
          path: MessagesProPageWrapper.routePath,
          builder: (context, params) => const MessagesProPageWrapper(),
        ),
        FFRoute(
          name: ResetPasswordNewPageWidget.routeName,
          path: ResetPasswordNewPageWidget.routePath,
          builder: (context, params) => const ResetPasswordNewPageWidget(),
        ),
        FFRoute(
          name: SignInEmailPageProWidget.routeName,
          path: SignInEmailPageProWidget.routePath,
          builder: (context, params) => const SignInEmailPageProWidget(),
        ),
        FFRoute(
          name: SetPasswordPageProWidget.routeName,
          path: SetPasswordPageProWidget.routePath,
          builder: (context, params) => const SetPasswordPageProWidget(),
        ),
        FFRoute(
          name: StartupGateWidget.routeName,
          path: StartupGateWidget.routePath,
          builder: (context, params) => const StartupGateWidget(),
        ),
        FFRoute(
          name: VideoCallPageWidget.routeName,
          path: VideoCallPageWidget.routePath,
          builder: (context, params) => VideoCallPageWidget(
            videoSessionId: params.getParam(
              'videoSessionId',
              ParamType.String,
            ),
            channelName: params.getParam(
              'channelName',
              ParamType.String,
            ),
            agoraToken: params.getParam(
              'agoraToken',
              ParamType.String,
            ),
            isInitiator: params.getParam(
              'isInitiator',
              ParamType.bool,
            ),
          ),
        ),
        FFRoute(
          name: FavProListWidget.routeName,
          path: FavProListWidget.routePath,
          builder: (context, params) => const FavProListWidget(),
        ),
        FFRoute(
          name: WishlistProPage.routeName,
          path: WishlistProPage.routePath,
          builder: (context, params) => const WishlistProPage(),
        ),
        FFRoute(
          name: NotificationsPage.routeName,
          path: NotificationsPage.routePath,
          builder: (context, params) => ChangeNotifierProvider(
            create: (_) => NotificationsNotifier()..loadNotifications(),
            child: const NotificationsPage(),
          ),
        ),
        FFRoute(
          name: PublicProProfileViewWidget.routeName,
          path: PublicProProfileViewWidget.routePath,
          builder: (context, params) => PublicProProfileViewWidget(
            proDetails: params.getParam(
              'proDetails',
              ParamType.DataStruct,
              isList: false,
              structBuilder: ProDetailsStruct.fromSerializableMap,
            ),
          ),
        ),
        FFRoute(
          name: WowViewerCarrouselWidget.routeName,
          path: WowViewerCarrouselWidget.routePath,
          builder: (context, params) => WowViewerCarrouselWidget(
            portfolioImages: params.getParam<String>(
              'portfolioImages',
              ParamType.String,
              isList: true,
            ),
            initialIndex: params.getParam(
              'initialIndex',
              ParamType.int,
            ),
            proInfo: params.getParam(
              'proInfo',
              ParamType.DataStruct,
              isList: false,
              structBuilder: ProDetailsStruct.fromSerializableMap,
            ),
          ),
        ),
        FFRoute(
          name: WowSimpleViewerWidget.routeName,
          path: WowSimpleViewerWidget.routePath,
          builder: (context, params) => WowSimpleViewerWidget(
            portfolioImages: params.getParam<String>(
              'portfolioImages',
              ParamType.String,
              isList: true,
            ),
            initialIndex: params.getParam(
              'initialIndex',
              ParamType.int,
            ),
            proInfo: params.getParam(
              'proInfo',
              ParamType.DataStruct,
              isList: false,
              structBuilder: ProDetailsStruct.fromSerializableMap,
            ),
          ),
        ),
        // My Wedding Suite - Sprint 1
        FFRoute(
          name: MyWeddingPage.routeName,
          path: MyWeddingPage.routePath,
          builder: (context, params) => const MyWeddingPage(),
        ),
        FFRoute(
          name: WeddingsHubProPage.routeName,
          path: WeddingsHubProPage.routePath,
          builder: (context, params) => WeddingsHubProPage(
            initialWeddingId: params.getParam('weddingId', ParamType.String),
          ),
        ),
        // ChatDetailsPage - Clean Architecture (nouvelle page)
        FFRoute(
          name: 'ChatDetailsPage',
          path: '/chatDetailsPage',
          builder: (context, params) {
            // Récupérer initialMessage depuis extra si présent
            final extra = params.state.extra as Map<String, dynamic>?;
            final initialMessage = extra?['initialMessage'] as String?;
            
            return ChatDetailsPage(
              roomId: params.getParam('roomId', ParamType.String) ?? '',
              isPublicRoom: params.getParam('isPublicRoom', ParamType.bool) ?? false,
              pendingRequestId: params.getParam('pendingRequestId', ParamType.String),
              initialMessage: initialMessage,
              otherProfileId: params.getParam('otherProfileId', ParamType.String),
              otherFullName: params.getParam('otherFullName', ParamType.String),
              otherAvatarUrl: params.getParam('otherAvatarUrl', ParamType.String),
              viewerIsReviewer: params.getParam('viewerIsReviewer', ParamType.bool) ?? false,
            );
          },
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/authWelcomePage';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Image.asset(
                      'assets/images/Splash_Screen.png',
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: MediaQuery.sizeOf(context).height * 1.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => const TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}

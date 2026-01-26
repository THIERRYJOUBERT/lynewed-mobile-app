// ignore_for_file: deprecated_member_use_from_same_package
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/utils/secure_logger.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'startup_gate_model.dart';
export 'startup_gate_model.dart';

class StartupGateWidget extends StatefulWidget {
  const StartupGateWidget({super.key});

  static String routeName = 'StartupGate';
  static String routePath = '/startupGate';

  @override
  State<StartupGateWidget> createState() => _StartupGateWidgetState();
}

class _StartupGateWidgetState extends State<StartupGateWidget> {
  late StartupGateModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StartupGateModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Récupérer le deeplink initial qui a lancé l'application
      _model.initialLinkUrl = await actions.getInitialDeepLink();
      
      // ✅ Vérifier si le deeplink contient "reset-password" (path spécifique)
      if (_model.initialLinkUrl != null && 
          _model.initialLinkUrl!.contains('reset-password')) {
        SecureLogger.debug('Password reset deeplink detected, redirecting to reset page');
        
        // Rediriger immédiatement vers la page de reset password
        if (!mounted) return;
        context.goNamedAuth(
            ResetPasswordNewPageWidget.routeName, context.mounted);
        return; // Arrêter l'exécution ici
      }
      
      // Backup: Vérifier aussi avec la fonction isRecoveryLink (type=recovery dans fragment)
      if (functions.isRecoveryLink(_model.initialLinkUrl) == true) {
        SecureLogger.debug('Recovery link detected, redirecting to reset page');
        
        // Rediriger immédiatement vers la page de reset password
        if (!mounted) return;
        context.goNamedAuth(
            ResetPasswordNewPageWidget.routeName, context.mounted);
        return;
      }
      
      // Configurer le listener pour les deeplinks futurs (quand l'app est déjà ouverte)
      if (!mounted) return;
      await actions.setupDeeplinkListener(context);
      
      if (loggedIn) {
        _model.sessionData = await actions.loadInitialSessionData();
        if (_model.sessionData != null) {
          FFAppState().selfPublicProfile = _model.sessionData!.profile;
          FFAppState().currentUserPreferences =
              _model.sessionData!.preferences;
          FFAppState().currentUserRole = _model.sessionData?.profile.role;
          FFAppState().userPrefsLastSyncedAt = getCurrentTimestamp;
          // Load pro subscription from session data
          if (_model.sessionData!.hasProSubscription()) {
            FFAppState().selfProSubscription = _model.sessionData!.proSubscription;
          }
          
          // 🚫 Block inactive pros - they must subscribe via CRM first
          if (FFAppState().currentUserRole == UserRole.professional &&
              FFAppState().selfProSubscription.subscriptionTier == SubscriptionTierType.inactive) {
            SecureLogger.debug('Pro with inactive subscription detected, signing out');
            
            if (!mounted) return;
            GoRouter.of(context).prepareAuthEvent();
            await authManager.signOut();
            if (!mounted) return;
            GoRouter.of(context).clearRedirectLocation();

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Your subscription is not active. Please subscribe to a plan on the CRM to access the app.',
                  style: TextStyle(
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                duration: const Duration(milliseconds: 5000),
                backgroundColor: FlutterFlowTheme.of(context).accent2,
              ),
            );

            context.goNamedAuth(
                AuthWelcomePageWidget.routeName, context.mounted);
            return;
          }
          
          safeSetState(() {});
          if (!mounted) return;
          await actions.initPushNotifications(
            context,
          );
          _model.tosAccepted = await actions.checkTosAccepted();
          if ((FFAppState().currentUserRole == UserRole.bride) &&
              ((FFAppState().selfPublicProfile.fullName == '') ||
                  (FFAppState().currentUserPreferences.defaultLocale ==
                          '') ||
                  (_model.tosAccepted == false))) {
            if (!mounted) return;
            context.goNamedAuth(
                OnboardingBridesWizardWidget.routeName, context.mounted);
          } else {
            if (!mounted) return;
            if (FFAppState().currentUserRole == UserRole.bride) {
              context.goNamedAuth(
                  HomeBridesWidget.routeName, context.mounted);
            } else {
              context.goNamedAuth(
                  DashboardProWidget.routeName, context.mounted);
            }
          }
        } else {
          if (!mounted) return;
          GoRouter.of(context).prepareAuthEvent();
          await authManager.signOut();
          if (!mounted) return;
          GoRouter.of(context).clearRedirectLocation();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Session error. Please log in again.',
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              duration: const Duration(milliseconds: 2000),
              backgroundColor: FlutterFlowTheme.of(context).accent2,
            ),
          );

          context.goNamedAuth(
              AuthWelcomePageWidget.routeName, context.mounted);
        }
      } else {
        if (!mounted) return;
        context.goNamedAuth(AuthWelcomePageWidget.routeName, context.mounted);
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

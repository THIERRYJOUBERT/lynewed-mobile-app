import '/auth/base_auth_user_provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
        print('🔑 Deeplink reset-password détecté: ${_model.initialLinkUrl}');
        
        // Rediriger immédiatement vers la page de reset password
        context.goNamedAuth(
            ResetPasswordNewPageWidget.routeName, context.mounted);
        return; // Arrêter l'exécution ici
      }
      
      // Backup: Vérifier aussi avec la fonction isRecoveryLink (type=recovery dans fragment)
      if (functions.isRecoveryLink(_model.initialLinkUrl) == true) {
        print('🔑 Lien de récupération détecté (type=recovery): ${_model.initialLinkUrl}');
        context.goNamedAuth(
            ResetPasswordNewPageWidget.routeName, context.mounted);
        return;
      }
      
      // Configurer le listener pour les deeplinks futurs (quand l'app est déjà ouverte)
      await actions.setupDeeplinkListener(context);
      
      if (loggedIn) {
        _model.sessionData = await actions.loadInitialSessionData();
        if (_model.sessionData != null) {
          FFAppState().selfPublicProfile = _model.sessionData!.profile;
          FFAppState().currentUserPreferences =
              _model.sessionData!.preferences;
          FFAppState().currentUserRole = _model.sessionData?.profile?.role;
          FFAppState().userPrefsLastSyncedAt = getCurrentTimestamp;
          FFAppState().updateSelfProSubscriptionStruct(
            (e) => e
              ..subscriptionTier =
                  FFAppState().selfProSubscription.subscriptionTier,
          );
          safeSetState(() {});
          await actions.initPushNotifications(
            context,
          );
          _model.tosAccepted = await actions.checkTosAccepted();
          if ((FFAppState().currentUserRole == UserRole.bride) &&
              ((FFAppState().selfPublicProfile.fullName == null ||
                      FFAppState().selfPublicProfile.fullName == '') ||
                  (FFAppState().currentUserPreferences.defaultLocale ==
                          null ||
                      FFAppState().currentUserPreferences.defaultLocale ==
                          '') ||
                  (_model.tosAccepted == false))) {
            context.goNamedAuth(
                OnboardingBridesWizardWidget.routeName, context.mounted);
          } else {
            if (FFAppState().currentUserRole == UserRole.bride) {
              context.goNamedAuth(
                  HomeBridesWidget.routeName, context.mounted);
            } else {
              context.goNamedAuth(
                  DashboardProWidget.routeName, context.mounted);
            }
          }
        } else {
          GoRouter.of(context).prepareAuthEvent();
          await authManager.signOut();
          GoRouter.of(context).clearRedirectLocation();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur de session. Veuillez vous reconnecter.',
                style: TextStyle(
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              duration: Duration(milliseconds: 2000),
              backgroundColor: FlutterFlowTheme.of(context).accent2,
            ),
          );

          context.goNamedAuth(
              AuthWelcomePageWidget.routeName, context.mounted);
        }
      } else {
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
          decoration: BoxDecoration(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

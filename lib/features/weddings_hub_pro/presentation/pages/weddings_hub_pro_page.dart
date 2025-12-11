import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/design/design.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/nav/nav.dart';

/// Weddings Hub Pro Page - List of weddings where pro is participant
/// 
/// Sprint 1: Placeholder page
/// Sprint 5: Full implementation with wedding list and details
class WeddingsHubProPage extends StatefulWidget {
  const WeddingsHubProPage({super.key});

  static const String routeName = 'weddingsHubPro';
  static const String routePath = '/weddingsHubPro';

  @override
  State<WeddingsHubProPage> createState() => _WeddingsHubProPageState();
}

class _WeddingsHubProPageState extends State<WeddingsHubProPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

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
        backgroundColor: LynewedColors.background,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 110.0, 20.0, 84.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Placeholder content
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                size: 64.0,
                                color: LynewedColors.gray300,
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                'Weddings Hub',
                                style: LynewedTextStyles.headlineMedium,
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Coming soon in Sprint 5',
                                style: LynewedTextStyles.bodyMedium.copyWith(
                                  color: LynewedColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom Navigation
              Align(
                alignment: Alignment.bottomCenter,
                child: const NavBarProWidget(number: 3),
              ),
              // Header
              _buildHeader(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with title and action icons - same style as dashboard_pro
  Widget _buildHeader() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        height: 110.0,
        decoration: const BoxDecoration(color: LynewedColors.background),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'WEDDINGS',
                    style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 18.0),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Settings
                      _buildHeaderIcon(
                        icon: Icons.settings_outlined,
                        onTap: () {
                          // TODO: Navigate to settings
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14.0),
            const Divider(height: 1.0, thickness: 1.0, color: LynewedColors.gray200),
          ],
        ),
      ),
    );
  }

  /// Header icon without badge - fixed 32x32 size for uniform alignment
  Widget _buildHeaderIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32.0,
        height: 32.0,
        child: Center(
          child: Icon(icon, color: LynewedColors.textPrimary, size: 24.0),
        ),
      ),
    );
  }
}

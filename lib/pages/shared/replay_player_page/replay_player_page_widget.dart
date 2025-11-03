import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'replay_player_page_model.dart';
export 'replay_player_page_model.dart';

class ReplayPlayerPageWidget extends StatefulWidget {
  const ReplayPlayerPageWidget({
    super.key,
    required this.videoUrl,
  });

  final String? videoUrl;

  static String routeName = 'ReplayPlayerPage';
  static String routePath = '/replayPlayerPage';

  @override
  State<ReplayPlayerPageWidget> createState() => _ReplayPlayerPageWidgetState();
}

class _ReplayPlayerPageWidgetState extends State<ReplayPlayerPageWidget> {
  late ReplayPlayerPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReplayPlayerPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: custom_widgets.YoutubePlayerWidget(
                width: double.infinity,
                height: double.infinity,
                youtubeUrl: widget!.videoUrl!,
              ),
            ),
            Align(
              alignment: AlignmentDirectional(1.0, -1.0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 70.0, 40.0, 0.0),
                child: FlutterFlowIconButton(
                  borderRadius: 100.0,
                  borderWidth: 0.0,
                  buttonSize: 40.0,
                  fillColor: Color(0x7F141414),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 17.0,
                  ),
                  onPressed: () async {
                    context.safePop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

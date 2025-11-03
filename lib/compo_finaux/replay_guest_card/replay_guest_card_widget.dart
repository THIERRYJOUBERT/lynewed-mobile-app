import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'replay_guest_card_model.dart';
export 'replay_guest_card_model.dart';

class ReplayGuestCardWidget extends StatefulWidget {
  const ReplayGuestCardWidget({super.key});

  @override
  State<ReplayGuestCardWidget> createState() => _ReplayGuestCardWidgetState();
}

class _ReplayGuestCardWidgetState extends State<ReplayGuestCardWidget> {
  late ReplayGuestCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReplayGuestCardModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.5,
      height: 180.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Container(
        width: 100.0,
        height: 100.0,
        child: Stack(
          alignment: AlignmentDirectional(-1.0, 1.0),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image.asset(
                'assets/images/Group_1000003014.png',
                width: MediaQuery.sizeOf(context).width * 0.5,
                height: 180.0,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xB2191919)],
                  stops: [0.6, 1.0],
                  begin: AlignmentDirectional(0.0, -1.0),
                  end: AlignmentDirectional(0, 1.0),
                ),
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(-1.0, 1.0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 0.0, 14.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MARINA B.',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Haas Grot Text Trial',
                            color: Colors.white,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      'Bridal Designer',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Haas Grot Text Trial',
                            color: FlutterFlowTheme.of(context).accent1,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

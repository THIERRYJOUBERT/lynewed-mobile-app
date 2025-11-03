import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'item_room_chat_model.dart';
export 'item_room_chat_model.dart';

class ItemRoomChatWidget extends StatefulWidget {
  const ItemRoomChatWidget({super.key});

  @override
  State<ItemRoomChatWidget> createState() => _ItemRoomChatWidgetState();
}

class _ItemRoomChatWidgetState extends State<ItemRoomChatWidget> {
  late ItemRoomChatModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemRoomChatModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 71.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 14.0, 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2.0),
              child: Image.asset(
                'assets/images/Capture_decran_2025-07-27_a_21.48.21_5.png',
                width: 42.0,
                height: 50.0,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      'Wedding dress',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Haas Grot Text Trial',
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '32 unread messages',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Haas Grot Text Trial',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ].divide(SizedBox(height: 4.0)),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(1.0, 0.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 22.0,
              ),
            ),
          ].divide(SizedBox(width: 14.0)),
        ),
      ),
    );
  }
}

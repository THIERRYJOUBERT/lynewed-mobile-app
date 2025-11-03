import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'info_wedding_pin_sheet_model.dart';
export 'info_wedding_pin_sheet_model.dart';

class InfoWeddingPinSheetWidget extends StatefulWidget {
  const InfoWeddingPinSheetWidget({
    super.key,
    required this.weddingPinData,
  });

  final WeddingPinItemDataStruct? weddingPinData;

  @override
  State<InfoWeddingPinSheetWidget> createState() =>
      _InfoWeddingPinSheetWidgetState();
}

class _InfoWeddingPinSheetWidgetState extends State<InfoWeddingPinSheetWidget> {
  late InfoWeddingPinSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InfoWeddingPinSheetModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 14.0, 20.0, 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wedding Pin (public)',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Haas Grot Text Trial',
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: FlutterFlowTheme.of(context).tertiary,
                ),
              ].divide(SizedBox(height: 8.0)),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              decoration: BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100.0),
                    child: Image.network(
                      valueOrDefault<String>(
                        widget!.weddingPinData?.brideAvatarUrl,
                        'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwyfHxwcm9maWx8ZW58MHx8fHwxNzU4MTc4NTA3fDA&ixlib=rb-4.1.0&q=80&w=1080',
                      ),
                      width: 52.0,
                      height: 52.0,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          valueOrDefault<String>(
                            widget!.weddingPinData?.locationLabel,
                            'Label...',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Haas Grot Text Trial',
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                        Text(
                          valueOrDefault<String>(
                            dateTimeFormat(
                              "d/M/y",
                              widget!.weddingPinData?.eventStartDate,
                              locale: FFLocalizations.of(context).languageCode,
                            ),
                            'EventStartDate...',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Haas Grot Text Trial',
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                        Text(
                          'Budget : ${valueOrDefault<String>(
                            widget!.weddingPinData?.budgetMin?.toString(),
                            '0',
                          )} - ${valueOrDefault<String>(
                            widget!.weddingPinData?.budgetMax?.toString(),
                            '0',
                          )}${valueOrDefault<String>(
                            widget!.weddingPinData?.currency,
                            '\$',
                          )}',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Haas Grot Text Trial',
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ].divide(SizedBox(height: 2.0)),
                    ),
                  ),
                ].divide(SizedBox(width: 12.0)),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'Desired profession :',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Haas Grot Text Trial',
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                Align(
                  alignment: AlignmentDirectional(-1.0, 0.0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
                    child: Builder(
                      builder: (context) {
                        final listProfession = widget!
                                .weddingPinData?.professionsNeeded
                                ?.map((e) => e)
                                .toList()
                                ?.toList() ??
                            [];

                        return Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          direction: Axis.horizontal,
                          runAlignment: WrapAlignment.start,
                          verticalDirection: VerticalDirection.down,
                          clipBehavior: Clip.none,
                          children: List.generate(listProfession.length,
                              (listProfessionIndex) {
                            final listProfessionItem =
                                listProfession[listProfessionIndex];
                            return Container(
                              height: 30.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).tertiary,
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    12.0, 0.0, 12.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      valueOrDefault<String>(
                                        listProfessionItem.name,
                                        'Profession...',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Haas Grot Text Trial',
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 6.0)),
            ),
            Divider(
              thickness: 1.0,
              indent: 4.0,
              endIndent: 4.0,
              color: FlutterFlowTheme.of(context).tertiary,
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: 300.0,
              child: custom_widgets.LynewedMiniMap(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: 300.0,
                radiusKm: widget!.weddingPinData?.radiusKm?.toDouble(),
                borderRadius: 0.0,
                useLiteMode: false,
                center: widget!.weddingPinData!.center!,
                markerStyle: MarkerStyleInfoStruct(),
                mapStyle: MapStyleType.normal,
                onTap: () async {},
              ),
            ),
            FFButtonWidget(
              onPressed: () async {
                if (widget!.weddingPinData?.brideProfileId == currentUserUid) {
                  _model.deleteWeddingPin = await actions.deleteWeddingPin(
                    widget!.weddingPinData!.weddingPinId,
                  );
                  Navigator.pop(context);
                } else {
                  await action_blocks.contactChatRoom(
                    context,
                    targetProfileID: widget!.weddingPinData?.brideProfileId,
                  );
                }

                safeSetState(() {});
              },
              text: widget!.weddingPinData?.brideProfileId == currentUserUid
                  ? 'Delete'
                  : 'Contact',
              options: FFButtonOptions(
                width: double.infinity,
                height: 48.0,
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Haas Grot Text Trial',
                      color: Colors.white,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.normal,
                    ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          ].divide(SizedBox(height: 10.0)),
        ),
      ),
    );
  }
}

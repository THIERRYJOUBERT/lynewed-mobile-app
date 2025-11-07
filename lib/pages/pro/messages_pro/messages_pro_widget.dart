import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/header_bar/header_bar_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/conversation_sheet/conversation_actions_sheet/conversation_actions_sheet_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'messages_pro_model.dart';
export 'messages_pro_model.dart';

class MessagesProWidget extends StatefulWidget {
  const MessagesProWidget({super.key});

  static String routeName = 'MessagesPro';
  static String routePath = '/messagesPro';

  @override
  State<MessagesProWidget> createState() => _MessagesProWidgetState();
}

class _MessagesProWidgetState extends State<MessagesProWidget> {
  late MessagesProModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MessagesProModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _model.isLoadingInbox = true;
      _model.isLoadingRequests = true;
      if (mounted) {
        safeSetState(() {});
      }
      _model.inboxResult = await actions.getRoomsWithUnreadCountsAction(
        50,
      );
      if (!mounted) return;
      _model.psInboxItems =
          _model.inboxResult!.items.toList().cast<ConversationListItemStruct>();
      _model.requestsResult = await actions.getPendingContactRequestsAction();
      if (!mounted) return;
      _model.psRequestItems = _model.requestsResult!.items
          .toList()
          .cast<ContactRequestItemStruct>();
      if (mounted) {
        safeSetState(() {});
      }
      _model.isLoadingInbox = false;
      _model.isLoadingRequests = false;
      if (mounted) {
        safeSetState(() {});
      }
    });
  }

  @override
  void dispose() {
    // On page dispose action.
    () async {
      // Rafraîchir le compteur de messages au lieu de le mettre à 0
      await actions.refreshUnreadCounts();
    }();

    _model.dispose();

    super.dispose();
  }

  @override
  void didPopNext() {
    // Rafraîchir la liste quand on revient sur cette page
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _model.isLoadingInbox = true;
      if (mounted) {
        safeSetState(() {});
      }
      _model.inboxResult = await actions.getRoomsWithUnreadCountsAction(50);
      if (!mounted) return;
      _model.psInboxItems =
          _model.inboxResult!.items.toList().cast<ConversationListItemStruct>();
      _model.isLoadingInbox = false;
      if (mounted) {
        safeSetState(() {});
      }
      await actions.refreshUnreadCounts();
    });
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
        body: Align(
          alignment: const AlignmentDirectional(0.0, -1.0),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: MediaQuery.sizeOf(context).height * 1.0,
            child: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(20.0, 130.0, 20.0, 84.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'Contact request',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            height: 70.0,
                            decoration: const BoxDecoration(),
                            child: Builder(
                              builder: (context) {
                                final requestList =
                                    _model.psRequestItems.toList();
                                if (requestList.isEmpty) {
                                  return const Center(
                                    child: EmptyStateWidget(
                                      message: 'No contact request',
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  padding: EdgeInsets.zero,
                                  primary: false,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: requestList.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 14.0),
                                  itemBuilder: (context, requestListIndex) {
                                    final requestListItem =
                                        requestList[requestListIndex];
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await action_blocks
                                            .contactRoomChatMessagerie(
                                          context,
                                          otherProfileId:
                                              requestListItem.otherProfileId,
                                        );
                                      },
                                      child: Container(
                                        width: 64.0,
                                        decoration: const BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(99.0),
                                              child: Image.network(
                                                valueOrDefault<String>(
                                                  requestListItem
                                                      .otherAvatarUrl,
                                                  'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png',
                                                ),
                                                width: 50.0,
                                                height: 50.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Flexible(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      requestListItem
                                                                  .initiatorId ==
                                                              currentUserUid
                                                          ? 'Waiting'
                                                          : 'New',
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                'Haas Grot Text Trial',
                                                            fontSize: 10.0,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ].divide(const SizedBox(height: 6.0)),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ]
                            .divide(const SizedBox(height: 14.0))
                            .addToStart(const SizedBox(height: 2.0)),
                      ),
                      Divider(
                        height: 1.0,
                        thickness: 1.0,
                        color: FlutterFlowTheme.of(context).secondary,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Conversations',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Haas Grot Text Trial',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                            Flexible(
                              child: Container(
                                decoration: const BoxDecoration(),
                                child: Builder(
                                  builder: (context) {
                                    final conversationItem = _model.psInboxItems
                                        .where((e) =>
                                            (e.conversationStatus ==
                                                ConversationStatus.active) &&
                                            (e.roomType == RoomType.private))
                                        .toList();
                                    if (conversationItem.isEmpty) {
                                      return const Center(
                                        child: EmptyStateWidget(
                                          message: 'No recent chats',
                                        ),
                                      );
                                    }

                                    return RefreshIndicator(
                                      onRefresh: () async {
                                        _model.refreshedInbox = await actions
                                            .getRoomsWithUnreadCountsAction(
                                          50,
                                        );
                                        _model.psInboxItems = _model
                                            .refreshedInbox!.items
                                            .toList()
                                            .cast<ConversationListItemStruct>();
                                        safeSetState(() {});
                                      },
                                      child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        scrollDirection: Axis.vertical,
                                        itemCount: conversationItem.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 14.0),
                                        itemBuilder:
                                            (context, conversationItemIndex) {
                                          final conversationItemItem =
                                              conversationItem[
                                                  conversationItemIndex];
                                          return Builder(
                                            builder: (context) => InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await action_blocks
                                                    .contactRoomChatMessagerie(
                                                  context,
                                                  otherProfileId:
                                                      conversationItemItem
                                                          .otherProfileId,
                                                );
                                              },
                                              onLongPress: () async {
                                                await showAlignedDialog(
                                                  context: context,
                                                  isGlobal: false,
                                                  avoidOverflow: true,
                                                  targetAnchor:
                                                      const AlignmentDirectional(
                                                              -1.0, 0.0)
                                                          .resolve(
                                                              Directionality.of(
                                                                  context)),
                                                  followerAnchor:
                                                      const AlignmentDirectional(
                                                              -1.0, 0.0)
                                                          .resolve(
                                                              Directionality.of(
                                                                  context)),
                                                  builder: (dialogContext) {
                                                    return Material(
                                                      color: Colors.transparent,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(
                                                                  dialogContext)
                                                              .unfocus();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                        child: SizedBox(
                                                          width:
                                                              MediaQuery.sizeOf(
                                                                          context)
                                                                      .width *
                                                                  1.0,
                                                          child:
                                                              ConversationActionsSheetWidget(
                                                            conversationItem:
                                                                conversationItemItem,
                                                            onActionCompleted:
                                                                () async {
                                                              _model.refreshedInboxAfterArchive =
                                                                  await actions
                                                                      .getRoomsWithUnreadCountsAction(
                                                                50,
                                                              );
                                                              _model.psInboxItems = _model
                                                                  .refreshedInboxAfterArchive!
                                                                  .items
                                                                  .toList()
                                                                  .cast<
                                                                      ConversationListItemStruct>();
                                                              safeSetState(
                                                                  () {});
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );

                                                safeSetState(() {});
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(12.0, 12.0,
                                                          14.0, 12.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(99.0),
                                                        child: Image.network(
                                                          valueOrDefault<
                                                              String>(
                                                            conversationItemItem
                                                                .otherAvatarUrl,
                                                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/lynewed-alpha-du4al1/assets/egport4rt4rg/person_15429777_1.png',
                                                          ),
                                                          width: 50.0,
                                                          height: 50.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      valueOrDefault<
                                                                          String>(
                                                                        conversationItemItem
                                                                            .otherFullName,
                                                                        'Name...',
                                                                      ),
                                                                      maxLines:
                                                                          1,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                'Haas Grot Text Trial',
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  dateTimeFormat(
                                                                    "relative",
                                                                    conversationItemItem
                                                                        .lastMessageAt!,
                                                                    locale: FFLocalizations.of(
                                                                            context)
                                                                        .languageCode,
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Haas Grot Text Trial',
                                                                        fontSize:
                                                                            12.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      conversationItemItem
                                                                          .lastMessageText,
                                                                      'message...',
                                                                    ),
                                                                    maxLines: 1,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              'Haas Grot Text Trial',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
                                                                          fontSize:
                                                                              14.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                ),
                                                                if (conversationItemItem
                                                                        .unreadCount >=
                                                                    1)
                                                                  Align(
                                                                    alignment:
                                                                        const AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          16.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                        borderRadius:
                                                                            BorderRadius.circular(100.0),
                                                                      ),
                                                                      child:
                                                                          Align(
                                                                        alignment: const AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                                                              3.0,
                                                                              0.0,
                                                                              3.0,
                                                                              0.0),
                                                                          child:
                                                                              Text(
                                                                            conversationItemItem.unreadCount.toString().maybeHandleOverflow(
                                                                                  maxChars: 3,
                                                                                ),
                                                                            maxLines:
                                                                                1,
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: 'Haas Grot Text Trial',
                                                                                  color: Colors.white,
                                                                                  fontSize: 9.0,
                                                                                  letterSpacing: 0.0,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ].divide(const SizedBox(
                                                                  width: 20.0)),
                                                            ),
                                                          ].divide(const SizedBox(
                                                              height: 4.0)),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        const SizedBox(width: 14.0)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ].divide(const SizedBox(height: 14.0)),
                        ),
                      ),
                    ].divide(const SizedBox(height: 14.0)),
                  ),
                ),
                wrapWithModel(
                  model: _model.headerBarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const HeaderBarWidget(
                    title: 'MESSAGING',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

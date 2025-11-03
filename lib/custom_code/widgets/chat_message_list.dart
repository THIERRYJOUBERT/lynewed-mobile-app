// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:intl/intl.dart';

class _ChatCacheEntry {
  List<_ChatMsg> messages;
  DateTime? oldestAt;
  Map<String, _ProfileInfo> authors;
  Map<String, String> mediaUrlCache;

  _ChatCacheEntry({
    required this.messages,
    required this.oldestAt,
    Map<String, _ProfileInfo>? authors,
    Map<String, String>? mediaUrlCache,
  })  : authors = authors ?? {},
        mediaUrlCache = mediaUrlCache ?? {};
}

class _InMemoryChatCache {
  static final Map<String, _ChatCacheEntry> _byRoom = {};
  static _ChatCacheEntry? get(String roomId) => _byRoom[roomId];
  static void put(String roomId, _ChatCacheEntry entry) =>
      _byRoom[roomId] = entry;
  static void update(String roomId, void Function(_ChatCacheEntry) mutate) {
    final e = _byRoom[roomId];
    if (e != null) mutate(e);
  }
}

class _AvatarName {
  final String avatarUrl;
  final String name;
  const _AvatarName(this.avatarUrl, this.name);
}

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    super.key,
    this.width,
    this.height,
    required this.roomId,
    required this.currentUserId,
    required this.isPublic,
    this.pageSize,
    this.onMessageLongPress,
    this.onNewMessageArrived,
    this.onTopReached,
    this.otherAvatarUrl,
    this.otherFullName,
    // Request mode
    this.pendingRequestId,
    this.isReviewer,
    this.onRequestAccepted,
    this.onRequestDeclined,
  });

  final double? width;
  final double? height;
  final String roomId;
  final String currentUserId;
  final bool isPublic;
  final int? pageSize;
  final Future<dynamic> Function(MessageLongPressDataStruct data)?
      onMessageLongPress;
  final Future<dynamic> Function()? onNewMessageArrived;
  final Future<dynamic> Function()? onTopReached;
  final String? otherAvatarUrl;
  final String? otherFullName;

  // Request mode
  final String? pendingRequestId;
  final bool? isReviewer;
  final Future<dynamic> Function(String newRoomId)? onRequestAccepted;
  final Future<dynamic> Function()? onRequestDeclined;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const double kAvatarRadius = 16.0;
  static const double kAvatarSpace = kAvatarRadius * 2 + 8;

  final _scrollCtl = ScrollController();
  bool _isLoading = false;
  bool _hasInitialLoaded = false;
  bool _isLoadingOlder = false;
  bool _hasMore = true;
  int get _pageSize => (widget.pageSize == null || widget.pageSize! <= 0)
      ? 30
      : widget.pageSize!;

  RealtimeChannel? _channel;
  final List<_ChatMsg> _messages = [];
  final Set<int> _seenMsgIds = {};
  DateTime? _oldestAt;
  final Map<String, _ProfileInfo> _authors = {};
  final Map<String, String> _mediaUrlCache = {};

  // Request mode
  String? _effectiveRoomId;
  String get _roomId => (_effectiveRoomId ?? widget.roomId);

  // *** MODIFICATION LOGIQUE CI-DESSOUS ***
  // Le mode "demande de contact" est actif dès qu'un ID de demande est présent.
  bool get _requestMode =>
      (widget.pendingRequestId != null && widget.pendingRequestId!.isNotEmpty);

  Map<String, dynamic>? _reqRow;
  ChatRoomHeaderStruct? _reqHeader;
  bool _loadingRequestMeta = false;

  final _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _attachScrollListener();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_requestMode) {
        await _loadRequestMeta();
      } else {
        await _restoreFromCacheOrLoad();
        _subscribeRealtime();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newRid = (_effectiveRoomId ?? widget.roomId);
    final oldRid = oldWidget.roomId;
    if (newRid != oldRid ||
        widget.pendingRequestId != oldWidget.pendingRequestId) {
      _resetAndReload();
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _scrollCtl.dispose();
    _channel = null;
    super.dispose();
  }

  void _attachScrollListener() {
    _scrollCtl.addListener(() async {
      if (!mounted || _requestMode) return;
      final pos = _scrollCtl.position;
      final nearTop = pos.pixels >= (pos.maxScrollExtent - 150.0);
      if (nearTop && !_isLoadingOlder && _hasMore) {
        await _loadOlder();
        if (widget.onTopReached != null) {
          await widget.onTopReached!();
        }
      }
    });
  }

  Future<void> _resetAndReload() async {
    _channel?.unsubscribe();
    _channel = null;

    setState(() {
      _isLoading = false;
      _hasInitialLoaded = false;
      _isLoadingOlder = false;
      _hasMore = true;
      _messages.clear();
      _authors.clear();
      _mediaUrlCache.clear();
      _seenMsgIds.clear();
      _oldestAt = null;
      _reqRow = null;
      _reqHeader = null;
      _loadingRequestMeta = false;
    });

    if (_requestMode) {
      await _loadRequestMeta();
    } else {
      await _restoreFromCacheOrLoad();
      _subscribeRealtime();
    }
  }

  // ---------- REQUEST MODE ----------
  Future<void> _loadRequestMeta() async {
    if (widget.pendingRequestId == null || widget.pendingRequestId!.isEmpty)
      return;
    setState(() => _loadingRequestMeta = true);
    try {
      final resp = await SupaFlow.client
          .from('connection_requests')
          .select(
              'id, pro_profile_id, bride_profile_id, initiator_id, initial_message, created_at')
          .eq('id', widget.pendingRequestId!)
          .maybeSingle();

      if (resp != null && resp is Map) {
        _reqRow = Map<String, dynamic>.from(resp);
      }

      final String? otherId = (() {
        if (_reqRow == null) return null;
        final proId = _reqRow!['pro_profile_id']?.toString();
        final brideId = _reqRow!['bride_profile_id']?.toString();
        if (widget.currentUserId == proId) return brideId;
        if (widget.currentUserId == brideId) return proId;
        return proId; // fallback
      })();

      if (otherId != null && otherId.isNotEmpty) {
        final pr = await SupaFlow.client
            .from('profiles')
            .select('id, full_name, avatar_url, role')
            .eq('id', otherId)
            .maybeSingle();
        if (pr != null && pr is Map) {
          _reqHeader = ChatRoomHeaderStruct(
            roomType: RoomType.private,
            otherProfileId: pr['id']?.toString(),
            otherFullName: pr['full_name']?.toString(),
            otherAvatarUrl:
                stringToImagePath(pr['avatar_url']?.toString() ?? ''),
            otherRole: ((pr['role']?.toString() ?? 'bride') == 'professional')
                ? UserRole.professional
                : UserRole.bride,
          );
        }
      }
    } catch (e) {
      debugPrint('_loadRequestMeta error: $e');
    } finally {
      if (mounted) setState(() => _loadingRequestMeta = false);
    }
  }

  Future<void> _acceptRequest() async {
    if (widget.pendingRequestId == null || widget.pendingRequestId!.isEmpty)
      return;
    try {
      final res =
          await SupaFlow.client.rpc('accept_connection_request', params: {
        'p_request_id': widget.pendingRequestId,
      });
      final newRoomId =
          (res is Map && res['roomId'] != null) ? res['roomId'].toString() : '';
      if (newRoomId.isNotEmpty) {
        _effectiveRoomId = newRoomId;
        if (widget.onRequestAccepted != null) {
          await widget.onRequestAccepted!(newRoomId);
        }
        // Après acceptation, on quitte le mode "demande de contact" et on charge la conversation
        await _resetAndReload();
      }
    } catch (e) {
      debugPrint('_acceptRequest error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept. Please retry.')),
        );
      }
    }
  }

  Future<void> _declineRequest() async {
    if (widget.pendingRequestId == null || widget.pendingRequestId!.isEmpty)
      return;
    try {
      await SupaFlow.client.rpc('decline_connection_request', params: {
        'p_request_id': widget.pendingRequestId,
      });
      if (widget.onRequestDeclined != null) {
        await widget.onRequestDeclined!();
      }
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      debugPrint('_declineRequest error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to decline. Please retry.')),
        );
      }
    }
  }

  // ---------- ROOM MODE (le reste du code est inchangé) ----------
  Future<void> _restoreFromCacheOrLoad() async {
    final rid = _roomId;
    if (rid.isEmpty) return;
    final cached = _InMemoryChatCache.get(rid);
    if (cached != null && cached.messages.isNotEmpty) {
      _messages
        ..clear()
        ..addAll(cached.messages);
      _seenMsgIds
        ..clear()
        ..addAll(cached.messages.map((m) => m.id));
      _authors.addAll(cached.authors);
      _mediaUrlCache.addAll(cached.mediaUrlCache);
      _oldestAt = cached.oldestAt;
      _hasInitialLoaded = true;
      _isLoading = false;
      if (mounted) setState(() {});
      await _fetchNewerThanCurrentHead();
      _prefetchMediaForVisibleRange();
    } else {
      await _loadInitial();
    }
  }

  bool _isValidHttpUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final u = Uri.tryParse(url);
    return u != null && (u.scheme == 'http' || u.scheme == 'https');
  }

  void _prefetchMediaForVisibleRange() {
    final subset = _messages
        .take(20)
        .where((m) =>
            (m.attachmentUrl?.isNotEmpty == true) &&
            (m.messageType == 'image' || m.messageType == 'audio'))
        .toList();
    for (final m in subset) {
      final path = m.attachmentUrl!;
      if (!_mediaUrlCache.containsKey(path)) {
        createSignedUrlForChatMediaAction(path, 3600).then((url) {
          if (url != null && mounted) {
            _mediaUrlCache[path] = url;
            _InMemoryChatCache.update(
                _roomId, (e) => e.mediaUrlCache[path] = url);
          }
        }).catchError((_) {});
      }
    }
  }

  Future<void> _warmProfilesForMessages(List<_ChatMsg> msgs) async {
    if (!widget.isPublic || msgs.isEmpty) return;
    final ids = <String>{};
    for (final m in msgs) {
      if (!_authors.containsKey(m.profileId)) ids.add(m.profileId);
    }
    if (ids.isEmpty) return;
    try {
      final res = await SupaFlow.client
          .from('profiles')
          .select('id, full_name, avatar_url')
          .inFilter('id', ids.toList());
      bool updated = false;
      if (res is List) {
        for (final r in res) {
          if (r is Map) {
            final id = (r['id'] ?? '').toString();
            if (id.isNotEmpty) {
              _authors[id] = _ProfileInfo(
                id: id,
                fullName: (r['full_name'] ?? '').toString(),
                avatarUrl:
                    stringToImagePath((r['avatar_url'] ?? '').toString()),
              );
              updated = true;
            }
          }
        }
      }
      if (updated && mounted) setState(() {});
      _InMemoryChatCache.update(_roomId, (e) => e.authors.addAll(_authors));
    } catch (_) {}
  }

  Future<void> _ensureAuthor(String profileId) async {
    if (!widget.isPublic ||
        profileId.isEmpty ||
        _authors.containsKey(profileId)) return;
    try {
      final r = await SupaFlow.client
          .from('profiles')
          .select('id, full_name, avatar_url')
          .eq('id', profileId)
          .maybeSingle();
      if (mounted && r != null && r is Map) {
        _authors[profileId] = _ProfileInfo(
          id: profileId,
          fullName: (r['full_name'] ?? '').toString(),
          avatarUrl: stringToImagePath((r['avatar_url'] ?? '').toString()),
        );
        setState(() {});
        _InMemoryChatCache.update(
            _roomId, (e) => e.authors[profileId] = _authors[profileId]!);
      }
    } catch (_) {}
  }

  Future<void> _loadInitial() async {
    final rid = _roomId;
    if (rid.isEmpty) return;
    if (_messages.isEmpty && mounted) setState(() => _isLoading = true);
    try {
      final res = await SupaFlow.client
          .from('chat_messages')
          .select(
              'id, room_id, profile_id, content, message_type, attachment_url, is_deleted, created_at')
          .eq('room_id', rid)
          .order('created_at', ascending: false)
          .limit(_pageSize);

      final List<_ChatMsg> msgsDesc = [];
      if (res is List) {
        for (final r in res) {
          if (r is Map) {
            final m = _ChatMsg.fromRow(Map<String, dynamic>.from(r));
            if (_seenMsgIds.add(m.id)) {
              msgsDesc.add(m);
            }
          }
        }
      }

      _messages
        ..clear()
        ..addAll(msgsDesc);
      _oldestAt = _messages.isNotEmpty ? _messages.last.createdAt : null;
      _hasMore = (res is List) ? (res.length == _pageSize) : false;
      _hasInitialLoaded = true;
      _isLoading = false;
      if (mounted) setState(() {});

      _InMemoryChatCache.put(
        rid,
        _ChatCacheEntry(
          messages: List<_ChatMsg>.from(_messages),
          oldestAt: _oldestAt,
          authors: Map<String, _ProfileInfo>.from(_authors),
          mediaUrlCache: Map<String, String>.from(_mediaUrlCache),
        ),
      );

      _prefetchMediaForVisibleRange();
      await _warmProfilesForMessages(_messages);
    } catch (e) {
      debugPrint('_loadInitial error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchNewerThanCurrentHead() async {
    if (_messages.isEmpty) return;
    final rid = _roomId;
    if (rid.isEmpty) return;
    final newestAt = _messages.first.createdAt;
    try {
      final res = await SupaFlow.client
          .from('chat_messages')
          .select(
              'id, room_id, profile_id, content, message_type, attachment_url, is_deleted, created_at')
          .eq('room_id', rid)
          .gt('created_at', newestAt.toUtc().toIso8601String())
          .order('created_at', ascending: true);

      final List<_ChatMsg> newer = [];
      if (res is List) {
        for (final r in res) {
          if (r is Map) {
            final m = _ChatMsg.fromRow(Map<String, dynamic>.from(r));
            if (_seenMsgIds.add(m.id)) newer.add(m);
          }
        }
      }
      if (newer.isNotEmpty) {
        for (final m in newer.reversed) {
          _messages.insert(0, m);
        }
        if (mounted) setState(() {});
        _InMemoryChatCache.update(
            _roomId, (e) => e.messages = List<_ChatMsg>.from(_messages));
        _prefetchMediaForVisibleRange();
        await _warmProfilesForMessages(newer);
      }
    } catch (e) {
      debugPrint('_fetchNewerThanCurrentHead error: $e');
    }
  }

  Future<void> _loadOlder() async {
    final rid = _roomId;
    if (_oldestAt == null || rid.isEmpty || !mounted) return;
    setState(() => _isLoadingOlder = true);
    try {
      final res = await SupaFlow.client
          .from('chat_messages')
          .select(
              'id, room_id, profile_id, content, message_type, attachment_url, is_deleted, created_at')
          .eq('room_id', rid)
          .lt('created_at', _oldestAt!.toUtc().toIso8601String())
          .order('created_at', ascending: false)
          .limit(_pageSize);

      final List<_ChatMsg> olderDesc = [];
      if (res is List) {
        for (final r in res) {
          if (r is Map) {
            final m = _ChatMsg.fromRow(Map<String, dynamic>.from(r));
            if (_seenMsgIds.add(m.id)) olderDesc.add(m);
          }
        }
      }

      if (olderDesc.isNotEmpty) {
        _messages.addAll(olderDesc);
        _oldestAt = _messages.last.createdAt;
        _hasMore = (res is List) ? (res.length == _pageSize) : false;
        if (mounted) setState(() => _isLoadingOlder = false);
        _InMemoryChatCache.update(_roomId, (e) {
          e.messages = List<_ChatMsg>.from(_messages);
          e.oldestAt = _oldestAt;
        });
        _prefetchMediaForVisibleRange();
        await _warmProfilesForMessages(olderDesc);
      } else {
        if (mounted) {
          setState(() {
            _hasMore = false;
            _isLoadingOlder = false;
          });
        }
      }
    } catch (e) {
      debugPrint('_loadOlder error: $e');
      if (mounted) setState(() => _isLoadingOlder = false);
    }
  }

  void _subscribeRealtime() {
    final rid = _roomId;
    if (rid.isEmpty) return;
    try {
      _channel?.unsubscribe();
      _channel = SupaFlow.client.channel('room-$rid')
        ..onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: rid,
          ),
          callback: (payload) async {
            final newRec = payload.newRecord;
            if (newRec == null || newRec is! Map) return;

            final msg = _ChatMsg.fromRow(Map<String, dynamic>.from(newRec));
            if (msg.roomId != rid || !_seenMsgIds.add(msg.id)) return;

            _messages.insert(0, msg);
            if (_oldestAt == null || msg.createdAt.isBefore(_oldestAt!)) {
              _oldestAt = msg.createdAt;
            }
            _InMemoryChatCache.update(_roomId, (e) {
              e.messages = List<_ChatMsg>.from(_messages);
              e.oldestAt = _oldestAt;
            });
            if (mounted) setState(() {});
            _prefetchMediaForVisibleRange();
            await _ensureAuthor(msg.profileId);
            if (widget.onNewMessageArrived != null) {
              await widget.onNewMessageArrived!();
            }
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: rid,
          ),
          callback: (payload) async {
            final newRec = payload.newRecord;
            if (newRec == null || newRec is! Map) return;

            final updated = _ChatMsg.fromRow(Map<String, dynamic>.from(newRec));
            final idx = _messages.indexWhere((m) => m.id == updated.id);
            if (idx >= 0) {
              _messages[idx] = updated;
              _InMemoryChatCache.update(
                  _roomId, (e) => e.messages = List<_ChatMsg>.from(_messages));
              if (mounted) setState(() {});
              await _ensureAuthor(updated.profileId);
            }
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: rid,
          ),
          callback: (payload) {
            final oldRec = payload.oldRecord;
            if (oldRec == null || oldRec is! Map) return;

            final id = (oldRec['id'] as num?)?.toInt();
            if (id == null) return;
            final idx = _messages.indexWhere((m) => m.id == id);
            if (idx >= 0) {
              _messages.removeAt(idx);
              _InMemoryChatCache.update(
                  _roomId, (e) => e.messages = List<_ChatMsg>.from(_messages));
              if (mounted) setState(() {});
            }
          },
        ).subscribe();
    } catch (e) {
      debugPrint('subscribeRealtime error: $e');
    }
  }

  String _fmtDay(DateTime dt) {
    final locale = FFLocalizations.of(context).languageCode.toLowerCase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);
    if (date == today) return locale == 'fr' ? 'Aujourd\'hui' : 'Today';
    if (date == yesterday) return locale == 'fr' ? 'Hier' : 'Yesterday';
    return DateFormat.yMMMMd(locale).format(dt);
  }

  String _fmtTime(DateTime dt) {
    final locale = FFLocalizations.of(context).languageCode;
    return DateFormat.Hm(locale).format(dt.toLocal());
  }

  bool _showDayDividerBelow(int index) {
    if (index <= 0) return false;
    final cur = _messages[index].createdAt.toLocal();
    final prev = _messages[index - 1].createdAt.toLocal();
    return !(cur.year == prev.year &&
        cur.month == prev.month &&
        cur.day == prev.day);
  }

  bool _isGroupStart(int index) {
    if (index == _messages.length - 1) return true;
    final cur = _messages[index];
    final nextOlder = _messages[index + 1];
    if (cur.profileId != nextOlder.profileId) return true;
    return nextOlder.createdAt.difference(cur.createdAt).inMinutes > 5;
  }

  _AvatarName _resolveAuthorVisuals(_ChatMsg m, bool isMine) {
    if (!isMine && !widget.isPublic) {
      final url = stringToImagePath(widget.otherAvatarUrl ?? '');
      final name = widget.otherFullName ?? '';
      if (url.isNotEmpty) return _AvatarName(url, name);
    }
    final author = _authors[m.profileId];
    return _AvatarName(
        stringToImagePath(author?.avatarUrl ?? ''), author?.fullName ?? '');
  }

  Future<String?> _getSignedUrlForPath(String fullPath) async {
    final cached = _mediaUrlCache[fullPath];
    if (cached != null && cached.isNotEmpty) return cached;
    try {
      final url = await createSignedUrlForChatMediaAction(fullPath, 3600);
      if (url != null) {
        _mediaUrlCache[fullPath] = url;
        _InMemoryChatCache.update(
            _roomId, (e) => e.mediaUrlCache[fullPath] = url);
      }
      return url;
    } catch (_) {
      return null;
    }
  }

  Widget _buildMediaContent(_ChatMsg m, bool isMine) {
    final theme = FlutterFlowTheme.of(context);
    final path = m.attachmentUrl ?? '';
    if (path.isEmpty) return const SizedBox.shrink();

    final textColor = isMine ? Colors.white : theme.primaryText;
    final isFr = FFLocalizations.of(context).languageCode.toLowerCase() == 'fr';

    if (m.isDeleted) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          isFr ? 'Message supprimé' : 'Message deleted',
          style: theme.bodySmall.copyWith(
              color: theme.secondaryText, fontStyle: FontStyle.italic),
        ),
      );
    }

    final cached = _mediaUrlCache[path];
    if (cached != null && cached.isNotEmpty) {
      return _renderMedia(m, cached, textColor);
    }
    return FutureBuilder<String?>(
      future: _getSignedUrlForPath(path),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
              ],
            ),
          );
        }
        return _renderMedia(m, snapshot.data!, textColor);
      },
    );
  }

  Widget _renderMedia(_ChatMsg m, String url, Color textColor) {
    final theme = FlutterFlowTheme.of(context);
    final screenW = MediaQuery.of(context).size.width;
    final maxW = (screenW * 0.72).clamp(180.0, 360.0);

    if (m.messageType == 'image') {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => _FullScreenImageViewerWithDownload(imageUrl: url),
          ));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(
            url,
            width: maxW,
            fit: BoxFit.cover,
            loadingBuilder: (c, child, progress) => progress == null
                ? child
                : const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2))),
          ),
        ),
      );
    }
    if (m.messageType == 'audio') {
      return AudioPlayerWidget(
        audioUrl: url,
        bubbleColor: Colors.transparent,
        textColor: textColor,
      );
    }
    return const SizedBox.shrink();
  }

  MessageType _messageTypeFromString(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      case 'text':
      default:
        return MessageType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = FlutterFlowTheme.of(context);
    final screenW = MediaQuery.of(context).size.width;
    final maxBubbleW = screenW * 0.72;

    // REQUEST MODE UI
    if (_requestMode) {
      final isFr =
          FFLocalizations.of(context).languageCode.toLowerCase() == 'fr';
      final pendingText =
          isFr ? 'En attente d’acceptation' : 'Pending acceptance';
      final headerAvatarUrl = _reqHeader?.otherAvatarUrl ?? '';

      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: theme.secondaryBackground,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: kAvatarRadius,
                      backgroundImage: _isValidHttpUrl(headerAvatarUrl)
                          ? NetworkImage(headerAvatarUrl)
                          : null,
                      child: !_isValidHttpUrl(headerAvatarUrl)
                          ? const Icon(Icons.person, size: 18)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_reqHeader?.otherFullName ?? 'Contact',
                                style: theme.bodyMedium),
                            Text(
                                (_reqHeader?.otherRole == UserRole.professional)
                                    ? 'Professional'
                                    : 'Bride',
                                style: theme.labelSmall
                                    .copyWith(color: theme.secondaryText)),
                          ]),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.alternate.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(pendingText,
                          style: theme.labelSmall
                              .copyWith(color: theme.secondaryText)),
                    ),
                  ],
                ),
              ),
            ),

            // Initial message (lecture)
            if (!_loadingRequestMeta)
              Positioned.fill(
                top: 60,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxBubbleW),
                      child: _MessageBubble(
                        isMine: (_reqRow?['initiator_id']?.toString() ==
                            widget.currentUserId),
                        isDeleted: false,
                        messageType: 'text',
                        content: _reqRow?['initial_message']?.toString() ?? '',
                        attachmentUrl: null,
                        timeLabel: '',
                        name: null,
                        mediaContent: null,
                        onLongPress: () {},
                      ),
                    ),
                  ),
                ),
              ),

            if (_loadingRequestMeta)
              Positioned.fill(
                child: Container(
                  color: theme.primaryBackground.withOpacity(0.9),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),

            // Accept/Decline (bride reviewer)
            if ((widget.isReviewer ?? false) && !_loadingRequestMeta)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Color(0x33000000),
                        offset: Offset(0, -2),
                      )
                    ],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _declineRequest,
                          child: Text(isFr ? 'Refuser' : 'Decline',
                              style: theme.titleSmall),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _acceptRequest,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primary),
                          child: Text(isFr ? 'Accepter' : 'Accept',
                              style: theme.titleSmall
                                  .copyWith(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // ROOM MODE UI
    final listView = ListView.builder(
      key: _listKey,
      controller: _scrollCtl,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemCount: _messages.length + (_isLoadingOlder ? 1 : 0),
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: true,
      cacheExtent: 800,
      itemBuilder: (ctx, i) {
        if (_isLoadingOlder && i == _messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }
        final m = _messages[i];
        final isMine = (m.profileId == widget.currentUserId);
        final isGroupStart = _isGroupStart(i);
        final showDividerBelow = _showDayDividerBelow(i);
        final avatarName = _resolveAuthorVisuals(m, isMine);
        final resolvedAvatar = avatarName.avatarUrl;
        final resolvedName = avatarName.name;
        final avatarOk = _isValidHttpUrl(resolvedAvatar);

        final bubble = _MessageBubble(
          key: ValueKey('msg_${m.id}'),
          isMine: isMine,
          isDeleted: m.isDeleted,
          messageType: m.messageType,
          content: m.content,
          attachmentUrl: m.attachmentUrl,
          timeLabel: _fmtTime(m.createdAt),
          name: widget.isPublic && !isMine ? resolvedName : null,
          mediaContent: (m.messageType == 'image' || m.messageType == 'audio')
              ? _buildMediaContent(m, isMine)
              : null,
          onLongPress: () async {
            if (widget.onMessageLongPress != null) {
              await widget.onMessageLongPress!(
                MessageLongPressDataStruct(
                  messageId: m.id,
                  isMine: isMine,
                  messageType: _messageTypeFromString(m.messageType),
                  attachmentUrl: m.attachmentUrl,
                  content: m.content,
                  createdAt: m.createdAt,
                  authorProfileId: m.profileId,
                ),
              );
            }
          },
        );

        final row = RepaintBoundary(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMine)
                isGroupStart
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          radius: kAvatarRadius,
                          backgroundColor: theme.secondaryBackground,
                          backgroundImage:
                              avatarOk ? NetworkImage(resolvedAvatar) : null,
                          child: !avatarOk
                              ? const Icon(Icons.person, size: 18)
                              : null,
                        ),
                      )
                    : const SizedBox(width: kAvatarSpace),
              ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxBubbleW),
                  child: bubble),
            ],
          ),
        );

        final dayDivider = showDividerBelow
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(_fmtDay(_messages[i - 1].createdAt.toLocal()),
                          style: theme.labelSmall
                              .copyWith(color: theme.secondaryText)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              )
            : const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            row,
            SizedBox(height: isGroupStart ? 12 : 6),
            dayDivider,
          ],
        );
      },
    );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          Positioned.fill(child: listView),
          if (!_hasInitialLoaded && _isLoading)
            Positioned.fill(
              child: Container(
                color: theme.primaryBackground.withOpacity(0.9),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    super.key,
    required this.isMine,
    required this.isDeleted,
    required this.messageType,
    this.content,
    this.attachmentUrl,
    required this.timeLabel,
    this.name,
    this.mediaContent,
    required this.onLongPress,
  });

  final bool isMine;
  final bool isDeleted;
  final String messageType; // 'text' | 'image' | 'audio'
  final String? content;
  final String? attachmentUrl;
  final String timeLabel;
  final String? name;
  final Widget? mediaContent;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final bg = isMine ? theme.primary : theme.secondaryBackground;
    final fg = isMine ? Colors.white : theme.primaryText;
    final secondary = theme.secondaryText;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft: Radius.circular(isMine ? 14 : 4),
      bottomRight: Radius.circular(isMine ? 4 : 14),
    );

    final isFr = FFLocalizations.of(context).languageCode.toLowerCase() == 'fr';
    final deletedLabel = isFr ? 'Message supprimé' : 'Message deleted';

    Widget buildTextBubble() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: isDeleted
                ? Text(deletedLabel,
                    style: theme.bodySmall.copyWith(
                        color: secondary, fontStyle: FontStyle.italic))
                : Text(content ?? '',
                    style: theme.bodyMedium.copyWith(color: fg)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 8, bottom: 6),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(timeLabel,
                  style: theme.labelSmall
                      .copyWith(color: isMine ? Colors.white70 : secondary)),
            ]),
          ),
        ],
      );
    }

    Widget buildMediaBubble() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: mediaContent ?? const SizedBox.shrink()),
          Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 8, bottom: 6, top: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(timeLabel,
                  style: theme.labelSmall
                      .copyWith(color: isMine ? Colors.white70 : secondary)),
            ]),
          ),
        ],
      );
    }

    final inner =
        (messageType == 'text') ? buildTextBubble() : buildMediaBubble();

    return GestureDetector(
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMine && (name != null && name!.isNotEmpty))
            Padding(
                padding: const EdgeInsets.only(left: 6.0, bottom: 2.0),
                child: Text(name!,
                    style: theme.labelSmall.copyWith(color: secondary))),
          Container(
              decoration: BoxDecoration(color: bg, borderRadius: borderRadius),
              child: inner),
        ],
      ),
    );
  }
}

class _FullScreenImageViewerWithDownload extends StatelessWidget {
  final String imageUrl;
  const _FullScreenImageViewerWithDownload({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isFr = FFLocalizations.of(context).languageCode.toLowerCase() == 'fr';
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () async {
              await launchURL(imageUrl);
            },
            tooltip: isFr ? 'Télécharger' : 'Download',
          )
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1.0,
          maxScale: 4.0,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}

class _ChatMsg {
  final int id;
  final String roomId;
  final String profileId;
  final String messageType;
  final String? content;
  final String? attachmentUrl;
  final bool isDeleted;
  final DateTime createdAt;

  _ChatMsg({
    required this.id,
    required this.roomId,
    required this.profileId,
    required this.messageType,
    this.content,
    this.attachmentUrl,
    required this.isDeleted,
    required this.createdAt,
  });

  factory _ChatMsg.fromRow(Map<String, dynamic> row) {
    return _ChatMsg(
      id: (row['id'] as num?)?.toInt() ?? 0,
      roomId: row['room_id']?.toString() ?? '',
      profileId: row['profile_id']?.toString() ?? '',
      messageType: row['message_type']?.toString() ?? 'text',
      content: row['content']?.toString(),
      attachmentUrl: row['attachment_url']?.toString(),
      isDeleted: row['is_deleted'] == true,
      createdAt:
          DateTime.tryParse(row['created_at']?.toString() ?? '')?.toUtc() ??
              DateTime.now().toUtc(),
    );
  }
}

class _ProfileInfo {
  final String id;
  final String fullName;
  final String avatarUrl;
  _ProfileInfo(
      {required this.id, required this.fullName, required this.avatarUrl});
}

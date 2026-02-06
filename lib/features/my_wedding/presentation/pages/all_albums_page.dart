/// All Albums Page - Unified view of all album types with tabs.
///
/// Displays wedding, private, and guest albums in a tabbed interface.
/// Each tab shows albums in a consistent 2-column grid layout.
/// Follows the [OrganizationPage] pattern for TabBar architecture.
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/guest_album.dart';
import '../sheets/create_album_sheet.dart';
import '../widgets/guest_album_grid_card.dart';
import '../widgets/inspiration_albums_grid.dart';
import 'guest_albums_page.dart';

/// Unified albums page with tabs for Wedding, Private, and Guest albums.
class AllAlbumsPage extends StatefulWidget {
  const AllAlbumsPage({
    super.key,
    required this.weddingId,
    this.initialTab = 0,
    this.isReadOnly = false,
  });

  /// The wedding ID.
  final String weddingId;

  /// Initial tab index (0=Wedding, 1=Private, 2=Guest).
  final int initialTab;

  /// Whether to disable editing actions.
  final bool isReadOnly;

  @override
  State<AllAlbumsPage> createState() => _AllAlbumsPageState();
}

class _AllAlbumsPageState extends State<AllAlbumsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  // Keys for reloading inspiration grids
  final _weddingGridKey = GlobalKey<InspirationAlbumsGridState>();
  final _privateGridKey = GlobalKey<InspirationAlbumsGridState>();

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentTab = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Wedding albums tab
                  InspirationAlbumsGrid(
                    key: _weddingGridKey,
                    weddingId: widget.weddingId,
                    isReadOnly: widget.isReadOnly,
                    filterPrivate: false,
                    onCreateAlbum: _openCreateAlbumSheet,
                  ),
                  // Private albums tab
                  InspirationAlbumsGrid(
                    key: _privateGridKey,
                    weddingId: widget.weddingId,
                    isReadOnly: widget.isReadOnly,
                    filterPrivate: true,
                    onCreateAlbum: _openCreateAlbumSheet,
                  ),
                  // Guest albums tab
                  _GuestAlbumsTabContent(weddingId: widget.weddingId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Albums',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
          // Create button - hidden on Guest tab and in read-only mode
          if (!widget.isReadOnly && _currentTab != 2)
            GestureDetector(
              onTap: _openCreateAlbumSheet,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: LynewedColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 22,
                  color: LynewedColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: LynewedColors.gray200, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: LynewedColors.textPrimary,
        unselectedLabelColor: LynewedColors.textSecondary,
        labelStyle: LynewedTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: LynewedTextStyles.bodyMedium,
        indicatorColor: LynewedColors.primary,
        indicatorWeight: 2,
        tabs: const [
          Tab(text: 'Wedding'),
          Tab(text: 'Private'),
          Tab(text: 'Guest'),
        ],
      ),
    );
  }

  void _openCreateAlbumSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAlbumSheet(
        weddingId: widget.weddingId,
        onCreated: _reloadCurrentTab,
      ),
    );
  }

  void _reloadCurrentTab() {
    if (_currentTab == 0) {
      _weddingGridKey.currentState?.reload();
    } else if (_currentTab == 1) {
      _privateGridKey.currentState?.reload();
    }
  }
}

/// Guest albums tab content - loads and displays guest albums in a grid.
class _GuestAlbumsTabContent extends StatefulWidget {
  const _GuestAlbumsTabContent({required this.weddingId});

  final String weddingId;

  @override
  State<_GuestAlbumsTabContent> createState() => _GuestAlbumsTabContentState();
}

class _GuestAlbumsTabContentState extends State<_GuestAlbumsTabContent>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  String? _error;
  List<GuestAlbum> _albums = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadAlbums();
    });
  }

  Future<void> _loadAlbums() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repository = MyWeddingRepositoryImpl();
    final result = await repository.getGuestAlbums(weddingId: widget.weddingId);

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _albums = result.data ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: LynewedColors.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LynewedButton(
              text: 'Retry',
              onPressed: _loadAlbums,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    if (_albums.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadAlbums,
      color: LynewedColors.primary,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _albums.length,
        itemBuilder: (context, index) {
          final album = _albums[index];
          return GuestAlbumGridCard(
            album: album,
            onTap: () => _navigateToAlbumDetail(album),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_album_outlined, size: 64, color: LynewedColors.gray300),
            const SizedBox(height: 24),
            Text(
              'No guest albums yet',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Photos and videos from your guests will appear here',
              style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAlbumDetail(GuestAlbum album) {
    // Navigate to GuestAlbumsPage's detail page using the existing route
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuestAlbumDetailPage(album: album),
      ),
    );
  }
}

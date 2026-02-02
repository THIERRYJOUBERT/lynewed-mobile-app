import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../sheets/add_guest_sheet.dart';
import '../widgets/guest_list_summary.dart';
import '../widgets/guest_status_badge.dart';
import '../widgets/guest_status_filter.dart';
import '../widgets/send_invitation_button.dart';
import '../widgets/bulk_invite_dialog.dart';

/// Guests Page - Full list of wedding guests with CRUD
class GuestsPage extends StatefulWidget {
  const GuestsPage({
    super.key,
    required this.weddingId,
  });

  final String weddingId;

  static const String routeName = 'guests';
  static const String routePath = '/guests';

  @override
  State<GuestsPage> createState() => _GuestsPageState();
}

class _GuestsPageState extends State<GuestsPage> {
  final _repository = MyWeddingRepositoryImpl();

  bool _isLoading = true;
  List<WeddingGuest> _guests = [];
  String? _error;
  GuestStatusFilter _currentFilter = GuestStatusFilter.all;

  List<WeddingGuest> get _filteredGuests => filterGuests(_guests, _currentFilter);

  @override
  void initState() {
    super.initState();
    _loadGuests();
  }

  Future<void> _loadGuests() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getWeddingGuests(weddingId: widget.weddingId);

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _guests = result.data ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.error;
        _isLoading = false;
      });
    }
  }

  void _openAddGuestSheet({WeddingGuest? guest}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: AddGuestSheet(
          weddingId: widget.weddingId,
          guest: guest,
          onSaved: _loadGuests,
        ),
      ),
    );
  }

  Future<void> _deleteGuest(WeddingGuest guest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guest'),
        content: Text('Are you sure you want to delete "${guest.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: LynewedColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _repository.deleteWeddingGuest(guestId: guest.id);

    if (!mounted) return;

    if (result.isSuccess) {
      _loadGuests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Guest deleted',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.textPrimary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to delete guest'),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
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
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddGuestSheet(),
        backgroundColor: LynewedColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    final guestCount = _guests.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              children: [
                Text(
                  'Guests',
                  style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
                ),
                if (guestCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: LynewedColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$guestCount',
                      style: LynewedTextStyles.labelMedium.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Bulk invite button
          if (_pendingGuestsWithEmail.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.send_outlined),
              tooltip: 'Invite All (${_pendingGuestsWithEmail.length})',
              color: LynewedColors.primary,
              onPressed: _showBulkInviteDialog,
            ),
          // Filter button
          GuestStatusFilterButton(
            currentFilter: _currentFilter,
            onFilterChanged: (filter) {
              setState(() => _currentFilter = filter);
            },
          ),
        ],
      ),
    );
  }

  /// Returns pending guests that have an email address.
  List<WeddingGuest> get _pendingGuestsWithEmail => _guests
      .where((g) => g.status == GuestStatus.pending && g.email != null && g.email!.isNotEmpty)
      .toList();

  Future<void> _showBulkInviteDialog() async {
    final sent = await showBulkInviteDialog(
      context: context,
      weddingId: widget.weddingId,
      pendingGuests: _pendingGuestsWithEmail,
    );

    if (sent && mounted) {
      _loadGuests();
    }
  }

  Widget _buildContent() {
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
            const Text('Something went wrong', style: LynewedTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LynewedButton(
              text: 'Retry',
              onPressed: _loadGuests,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    if (_guests.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadGuests,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary at top
          GuestListSummary(guests: _guests),
          const SizedBox(height: 16),

          // Filter chip (if filter active)
          if (_currentFilter != GuestStatusFilter.all) ...[
            GuestStatusFilterChip(
              filter: _currentFilter,
              onClear: () => setState(() => _currentFilter = GuestStatusFilter.all),
            ),
            const SizedBox(height: 16),
          ],

          // Guest list
          ..._filteredGuests.map((guest) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildGuestTile(guest),
              )),

          // Empty filter result
          if (_filteredGuests.isEmpty && _guests.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No guests with this status',
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
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
            const Icon(Icons.people_outline, size: 64, color: LynewedColors.gray300),
            const SizedBox(height: 24),
            const Text(
              'No guests yet',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start building your guest list by adding your first guest.',
              style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LynewedButton(
              text: 'Add Guest',
              onPressed: () => _openAddGuestSheet(),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestTile(WeddingGuest guest) {
    return GestureDetector(
      onTap: () => _openAddGuestSheet(guest: guest),
      onLongPress: () => _showGuestOptions(guest),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LynewedColors.background,
          border: Border.all(color: LynewedColors.gray200),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: LynewedColors.surface,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(guest.name ?? ''),
                      style: LynewedTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              guest.name ?? 'Unknown',
                              style: LynewedTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Status badge
                          if (guest.status != GuestStatus.pending) ...[
                            const SizedBox(width: 8),
                            GuestStatusBadge(status: guest.status),
                          ],
                          // Role badge
                          if (guest.role != GuestRole.guest) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: LynewedColors.surface,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getRoleLabel(guest.role),
                                style: LynewedTextStyles.labelSmall.copyWith(
                                  color: LynewedColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (guest.email != null || guest.phone != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (guest.email != null && guest.email!.isNotEmpty) ...[
                              const Icon(
                                Icons.email_outlined,
                                size: 14,
                                color: LynewedColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  guest.email!,
                                  style: LynewedTextStyles.labelMedium.copyWith(
                                    color: LynewedColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            if (guest.email != null && guest.email!.isNotEmpty &&
                                guest.phone != null && guest.phone!.isNotEmpty)
                              const SizedBox(width: 12),
                            if (guest.phone != null && guest.phone!.isNotEmpty) ...[
                              const Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: LynewedColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                guest.phone!,
                                style: LynewedTextStyles.labelMedium.copyWith(
                                  color: LynewedColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      if (guest.notes != null && guest.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          guest.notes!,
                          style: LynewedTextStyles.bodySmall.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            // Send invitation button
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SendInvitationButton(
                guestId: guest.id,
                weddingId: guest.weddingId,
                guestEmail: guest.email,
                guestStatus: guest.status,
                onSuccess: _loadGuests,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuestOptions(WeddingGuest guest) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: LynewedColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LynewedColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _openAddGuestSheet(guest: guest);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: LynewedColors.error),
                title: const Text('Delete', style: TextStyle(color: LynewedColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteGuest(guest);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _getRoleLabel(GuestRole role) {
    switch (role) {
      case GuestRole.bridesmaid:
        return 'Bridesmaid';
      case GuestRole.bestMan:
        return 'Best Man';
      case GuestRole.family:
        return 'Family';
      case GuestRole.witness:
        return 'Witness';
      case GuestRole.other:
        return 'Other';
      case GuestRole.guest:
        return 'Guest';
    }
  }
}

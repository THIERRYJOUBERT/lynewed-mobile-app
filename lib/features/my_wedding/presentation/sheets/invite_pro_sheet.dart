import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/core/design/design.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';

/// Invite Pro Sheet - Search and invite professionals
class InviteProSheet extends StatefulWidget {
  const InviteProSheet({
    super.key,
    required this.weddingId,
    required this.onProInvited,
  });

  final String weddingId;
  final VoidCallback onProInvited;

  @override
  State<InviteProSheet> createState() => _InviteProSheetState();
}

class _InviteProSheetState extends State<InviteProSheet> {
  final _repository = MyWeddingRepositoryImpl();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  List<ContactedPro> _contactedPros = [];
  List<ContactedPro> _filteredPros = [];
  Set<String> _invitedProIds = {};
  String? _error;
  String? _invitingProId;
  String? _removingProId;

  @override
  void initState() {
    super.initState();
    _loadContactedPros();
    _searchController.addListener(_filterPros);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContactedPros() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Load both contacted pros and current team members in parallel
    final results = await Future.wait([
      _repository.getContactedPros(),
      _repository.getActiveWeddingTeam(weddingId: widget.weddingId),
    ]);

    if (!mounted) return;

    final contactedResult = results[0] as RepositoryResult<List<ContactedPro>>;
    final teamResult = results[1] as RepositoryResult<List<WeddingTeamMember>>;

    if (contactedResult.isSuccess) {
      // Build set of already invited pro IDs
      final invitedIds = <String>{};
      if (teamResult.isSuccess && teamResult.data != null) {
        for (final member in teamResult.data!) {
          invitedIds.add(member.profileId);
        }
      }

      setState(() {
        _contactedPros = contactedResult.data ?? [];
        _filteredPros = _contactedPros;
        _invitedProIds = invitedIds;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = contactedResult.error;
        _isLoading = false;
      });
    }
  }

  void _filterPros() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredPros = _contactedPros);
    } else {
      setState(() {
        _filteredPros = _contactedPros.where((pro) {
          return pro.displayName.toLowerCase().contains(query) ||
              (pro.profession?.toLowerCase().contains(query) ?? false);
        }).toList();
      });
    }
  }

  Future<void> _invitePro(ContactedPro pro) async {
    setState(() => _invitingProId = pro.profileId);

    final result = await _repository.inviteProToWedding(
      weddingId: widget.weddingId,
      proProfileId: pro.profileId,
    );

    if (!mounted) return;

    setState(() => _invitingProId = null);

    if (result.isSuccess) {
      setState(() => _invitedProIds.add(pro.profileId));
      widget.onProInvited();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${pro.displayName} has been added to your team',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.textPrimary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? 'Failed to invite professional',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }

  Future<void> _removePro(ContactedPro pro) async {
    setState(() => _removingProId = pro.profileId);

    final result = await _repository.excludeProFromWedding(
      weddingId: widget.weddingId,
      proProfileId: pro.profileId,
    );

    if (!mounted) return;

    setState(() => _removingProId = null);

    if (result.isSuccess) {
      setState(() => _invitedProIds.remove(pro.profileId));
      widget.onProInvited();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${pro.displayName} has been removed from your team',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.textPrimary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? 'Failed to remove professional',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Invite Professional',
      onClose: () => Navigator.pop(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle (outside header)
          Text(
            'Add professionals from your contacts to your wedding team',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // Search field
          LynewedTextField(
            controller: _searchController,
            hint: 'Search by name or profession...',
            prefixIcon: const Icon(Icons.search, color: LynewedColors.textSecondary),
          ),
          const SizedBox(height: 20),
          // Content
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: LynewedColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load contacts',
                style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              ),
              const SizedBox(height: 16),
              LynewedButton(
                text: 'Retry',
                onPressed: _loadContactedPros,
                type: LynewedButtonType.secondary,
              ),
            ],
          ),
        ),
      );
    }

    if (_contactedPros.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.people_outline, size: 48, color: LynewedColors.gray300),
              const SizedBox(height: 16),
              Text(
                'No contacts yet',
                style: LynewedTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Start chatting with professionals to add them to your wedding team',
                style: LynewedTextStyles.bodySmall.copyWith(color: LynewedColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredPros.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 48, color: LynewedColors.gray300),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _filteredPros.map((pro) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildProItem(pro),
      )).toList(),
    );
  }

  void _navigateToProDetails(ContactedPro pro) {
    Navigator.pop(context); // Close sheet first
    context.pushNamed(
      'ProDetails',
      pathParameters: {'proId': pro.profileId},
    );
  }

  Widget _buildProItem(ContactedPro pro) {
    final isInvited = _invitedProIds.contains(pro.profileId);
    final isInviting = _invitingProId == pro.profileId;
    final isRemoving = _removingProId == pro.profileId;
    final isLoading = isInviting || isRemoving;

    return GestureDetector(
      onTap: () => _navigateToProDetails(pro),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: pro.avatarUrl != null && pro.avatarUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: pro.avatarUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 48,
                      height: 48,
                      color: LynewedColors.gray200,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      color: LynewedColors.gray200,
                      child: const Icon(Icons.person, color: LynewedColors.gray300),
                    ),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: LynewedColors.gray200,
                    child: const Icon(Icons.person, color: LynewedColors.gray300),
                  ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pro.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LynewedTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
                if (pro.profession != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    pro.profession!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LynewedTextStyles.labelLarge.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Add/Remove button
          GestureDetector(
            onTap: isLoading ? null : () => isInvited ? _removePro(pro) : _invitePro(pro),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isInvited ? LynewedColors.gray200 : LynewedColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isInvited ? LynewedColors.textPrimary : Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      isInvited ? 'Remove' : 'Add',
                      style: LynewedTextStyles.labelLarge.copyWith(
                        color: isInvited ? LynewedColors.textPrimary : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}

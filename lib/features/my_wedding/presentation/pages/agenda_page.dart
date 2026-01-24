import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/core/design/design.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../sheets/add_event_sheet.dart';

/// Agenda Page - Full list of wedding events with CRUD
class AgendaPage extends StatefulWidget {
  const AgendaPage({
    super.key,
    required this.weddingId,
  });

  final String weddingId;

  static const String routeName = 'agenda';
  static const String routePath = '/agenda';

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final _repository = MyWeddingRepositoryImpl();

  bool _isLoading = true;
  List<WeddingEvent> _events = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.getWeddingEvents(weddingId: widget.weddingId);

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _events = result.data ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.error;
        _isLoading = false;
      });
    }
  }

  void _openAddEventSheet({WeddingEvent? event}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: AddEventSheet(
          weddingId: widget.weddingId,
          event: event,
          onSaved: _loadEvents,
        ),
      ),
    );
  }

  Future<void> _toggleEventStatus(WeddingEvent event) async {
    final result = await _repository.toggleEventStatus(
      eventId: event.id,
      currentStatus: event.status.name,
    );

    if (result.isSuccess) {
      _loadEvents();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to update event'),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }

  Future<void> _deleteEvent(WeddingEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
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

    final result = await _repository.deleteWeddingEvent(eventId: event.id);

    if (!mounted) return;

    if (result.isSuccess) {
      _loadEvents();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Event deleted',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.textPrimary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to delete event'),
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
        onPressed: () => _openAddEventSheet(),
        backgroundColor: LynewedColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
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
              'Agenda',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
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
              onPressed: _loadEvents,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final showDateHeader = index == 0 ||
              !_isSameDay(_events[index - 1].eventDate, event.eventDate);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDateHeader) ...[
                if (index > 0) const SizedBox(height: 20),
                _buildDateHeader(event.eventDate),
                const SizedBox(height: 10),
              ],
              _buildEventTile(event),
              const SizedBox(height: 10),
            ],
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
            const Icon(Icons.event_outlined, size: 64, color: LynewedColors.gray300),
            const SizedBox(height: 24),
            const Text(
              'No events yet',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first event to start planning your wedding agenda.',
              style: LynewedTextStyles.bodyMedium.copyWith(color: LynewedColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LynewedButton(
              text: 'Add Event',
              onPressed: () => _openAddEventSheet(),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);

    String label;
    if (eventDay == today) {
      label = 'Today';
    } else if (eventDay == today.add(const Duration(days: 1))) {
      label = 'Tomorrow';
    } else if (eventDay.isBefore(today)) {
      label = 'Past';
    } else {
      label = DateFormat('EEEE, MMMM d').format(date);
    }

    final isPast = eventDay.isBefore(today);

    return Text(
      label,
      style: LynewedTextStyles.labelLarge.copyWith(
        color: isPast ? LynewedColors.gray300 : LynewedColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildEventTile(WeddingEvent event) {
    final isPast = event.isPast;
    final isDone = event.isDone;

    return GestureDetector(
      onTap: () => _openAddEventSheet(event: event),
      onLongPress: () => _showEventOptions(event),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPast || isDone ? LynewedColors.surface : LynewedColors.background,
          border: Border.all(
            color: isDone ? LynewedColors.textPrimary : LynewedColors.gray200,
            width: isDone ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => _toggleEventStatus(event),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDone ? LynewedColors.textPrimary : Colors.transparent,
                  border: Border.all(
                    color: isDone ? LynewedColors.textPrimary : LynewedColors.gray200,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
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
                          event.title,
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isPast || isDone
                                ? LynewedColors.textSecondary
                                : LynewedColors.textPrimary,
                          ),
                        ),
                      ),
                      if (event.isPublic)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: LynewedColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: LynewedColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(event.eventDate),
                        style: LynewedTextStyles.labelMedium.copyWith(
                          color: LynewedColors.textSecondary,
                        ),
                      ),
                      if (event.location != null && event.location!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: LynewedColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: LynewedTextStyles.labelMedium.copyWith(
                              color: LynewedColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.description!,
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
      ),
    );
  }

  void _showEventOptions(WeddingEvent event) {
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
                  _openAddEventSheet(event: event);
                },
              ),
              ListTile(
                leading: Icon(
                  event.isDone ? Icons.replay : Icons.check_circle_outline,
                ),
                title: Text(event.isDone ? 'Mark as pending' : 'Mark as done'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleEventStatus(event);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: LynewedColors.error),
                title: const Text('Delete', style: TextStyle(color: LynewedColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteEvent(event);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

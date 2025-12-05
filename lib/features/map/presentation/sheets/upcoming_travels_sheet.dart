/// Upcoming Travels Sheet
/// 
/// Displays a professional's upcoming travel dates and locations.
/// Fetches data directly from Supabase when opened.
/// 
/// DESIGN SYSTEM v3 APPLIED:
/// - LynewedSheet wrapper
/// - LynewedColors, LynewedTextStyles tokens
/// - Spacing: 30px between sections, 10px label→content
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/backend/supabase/supabase.dart';
import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';

/// Travel data model
class _TravelData {
  final String id;
  final String location;
  final String? startDate;
  final String? endDate;

  _TravelData({
    required this.id,
    required this.location,
    this.startDate,
    this.endDate,
  });

  factory _TravelData.fromJson(Map<String, dynamic> json) {
    return _TravelData(
      id: json['id']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
    );
  }
}

/// Upcoming travels bottom sheet
/// 
/// Shows where a professional will be traveling for work.
/// Fetches data directly from Supabase.
class UpcomingTravelsSheet extends StatefulWidget {
  const UpcomingTravelsSheet({
    super.key,
    required this.professionalId,
    required this.professionalName,
  });

  final String professionalId;
  final String professionalName;

  /// Show the sheet as a modal bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String professionalId,
    required String professionalName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpcomingTravelsSheet(
        professionalId: professionalId,
        professionalName: professionalName,
      ),
    );
  }

  @override
  State<UpcomingTravelsSheet> createState() => _UpcomingTravelsSheetState();
}

class _UpcomingTravelsSheetState extends State<UpcomingTravelsSheet> {
  List<_TravelData>? _travels;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTravels();
  }

  Future<void> _loadTravels() async {
    try {
      final result = await ProfessionalDetailsTable().queryRows(
        queryFn: (q) => q.eq('profile_id', widget.professionalId),
      );

      if (result.isNotEmpty && result.first.upcomingTravels != null) {
        final travelsJson = result.first.upcomingTravels as List<dynamic>?;
        if (travelsJson != null) {
          final now = DateTime.now().subtract(const Duration(days: 1));
          final travels = travelsJson
              .map((e) => _TravelData.fromJson(e as Map<String, dynamic>))
              .where((t) {
                if (t.endDate == null || t.endDate!.isEmpty) return true;
                try {
                  return DateTime.parse(t.endDate!).isAfter(now);
                } catch (_) {
                  return true;
                }
              })
              .toList();
          
          if (mounted) {
            setState(() {
              _travels = travels;
              _isLoading = false;
            });
          }
          return;
        }
      }
      
      if (mounted) {
        setState(() {
          _travels = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LynewedSheet(
      title: 'Upcoming Travels',
      onClose: () => Navigator.of(context).pop(),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return _buildEmptyState();
    }

    if (_travels == null || _travels!.isEmpty) {
      return _buildEmptyState();
    }

    return _buildTravelsList(_travels!);
  }

  Widget _buildTravelsList(List<_TravelData> travels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '${widget.professionalName} will be available in:',
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
        ...travels.map((travel) => _buildTravelItem(travel)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTravelItem(_TravelData travel) {
    final dateFormat = DateFormat('MMM d, yyyy');
    String dateRange = '';
    
    try {
      if (travel.startDate != null && travel.startDate!.isNotEmpty &&
          travel.endDate != null && travel.endDate!.isNotEmpty) {
        final start = DateTime.parse(travel.startDate!);
        final end = DateTime.parse(travel.endDate!);
        dateRange = '${dateFormat.format(start)} - ${dateFormat.format(end)}';
      } else if (travel.startDate != null && travel.startDate!.isNotEmpty) {
        final start = DateTime.parse(travel.startDate!);
        dateRange = 'From ${dateFormat.format(start)}';
      }
    } catch (_) {
      dateRange = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: LynewedColors.gray200),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LynewedColors.gray100,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.flight_takeoff,
              size: 22,
              color: LynewedColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  travel.location,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (dateRange.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    dateRange,
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: LynewedColors.gray100,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.flight_takeoff,
              size: 32,
              color: LynewedColors.gray300,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            'No upcoming travels',
            style: LynewedTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: LynewedColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              '${widget.professionalName} hasn\'t added any upcoming travel dates yet.',
              textAlign: TextAlign.center,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

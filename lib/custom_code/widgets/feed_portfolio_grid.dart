// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
// Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
import 'dart:async';
import 'package:uuid/uuid.dart';

class FeedPortfolioGrid extends StatefulWidget {
  const FeedPortfolioGrid({
    super.key,
    this.width,
    this.height,
    this.filters,
    this.onItemTap,
  });

  final double? width;
  final double? height;
  final QueryFiltersStruct? filters;
  final Future<dynamic> Function(FeedImageItemStruct item)? onItemTap;

  @override
  State<FeedPortfolioGrid> createState() => _FeedPortfolioGridState();
}

class _FeedPortfolioGridState extends State<FeedPortfolioGrid> {
  final ScrollController _scrollController = ScrollController();
  final List<FeedImageItemStruct> _items = [];
  final Set<String> _seenKeys = {};

  bool _isLoading = false;
  bool _hasMore = true;
  String? _nextCursor;
  String? _seed;

  QueryFiltersStruct? _lastFetchedFilters;

  // Create a shallow/deep-enough copy of filters so we can reliably detect changes
  QueryFiltersStruct _copyFilters(QueryFiltersStruct? f) {
    final src = f ?? QueryFiltersStruct();
    return QueryFiltersStruct(
      // important lists copied
      professions: List.from(src.professions),
      // important scalar filters copied
      budgetMin: src.budgetMin,
      budgetMax: src.budgetMax,
      currency: src.currency,
      center: src.center,
      radiusKm: src.radiusKm,
      countryCode: src.countryCode,
    );
  }

  QueryFiltersStruct get _effectiveFilters =>
      widget.filters ?? QueryFiltersStruct();

  @override
  void initState() {
    super.initState();
    _seed = const Uuid().v4();
    // snapshot current filters instead of keeping the same instance reference
    _lastFetchedFilters = _copyFilters(_effectiveFilters);
    _fetchData();

    _scrollController.addListener(() {
      final threshold = _scrollController.position.maxScrollExtent * 0.8;
      if (_scrollController.position.pixels >= threshold) {
        if (!_isLoading && _hasMore) {
          _fetchData();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant FeedPortfolioGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compare against the last fetched snapshot, not oldWidget (which may share the same instance)
    if (_filtersChanged(_lastFetchedFilters, widget.filters)) {
      _resetAndFetchData();
    }
  }

  bool _filtersChanged(QueryFiltersStruct? oldF, QueryFiltersStruct? newF) {
    final oldFilters = oldF ?? QueryFiltersStruct();
    final newFilters = newF ?? QueryFiltersStruct();

    // AJOUTÉ : Vérification des filtres de budget
    if ((oldFilters.budgetMin ?? 0.0) != (newFilters.budgetMin ?? 0.0)) {
      return true;
    }
    if ((oldFilters.budgetMax ?? 0.0) != (newFilters.budgetMax ?? 0.0)) {
      return true;
    }

    final oldLat = oldFilters.center?.latitude;
    final oldLng = oldFilters.center?.longitude;
    final newLat = newFilters.center?.latitude;
    final newLng = newFilters.center?.longitude;
    if (oldLat != newLat || oldLng != newLng) return true;

    if ((oldFilters.radiusKm ?? 0) != (newFilters.radiusKm ?? 0)) return true;

    // CRITICAL: Check country code changes
    if ((oldFilters.countryCode ?? '') != (newFilters.countryCode ?? '')) return true;

    List<String> norm(dynamic list) {
      final out = <String>[];
      if (list is List) {
        for (final e in list) {
          if (e is String) {
            out.add(e.toUpperCase());
          } else if (e is Profession)
            out.add(e.name.toUpperCase());
          else
            out.add(e.toString().toUpperCase());
        }
      }
      out.sort();
      return out;
    }

    final op = norm(oldFilters.professions);
    final np = norm(newFilters.professions);
    if (op.length != np.length) return true;
    for (int i = 0; i < op.length; i++) {
      if (op[i] != np[i]) return true;
    }

    return false;
  }

  Future<void> _resetAndFetchData() async {
    setState(() {
      _items.clear();
      _seenKeys.clear();
      _nextCursor = null;
      _hasMore = true;
      _isLoading = false;
      _seed = const Uuid().v4();
      // refresh the snapshot with a fresh copy
      _lastFetchedFilters = _copyFilters(_effectiveFilters);
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await getPortfolioFeedAction(
        _lastFetchedFilters,
        _nextCursor,
        30,
        _seed,
      );

      if (result == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasMore = false;
          });
        }
        return;
      }

      final newItems = <FeedImageItemStruct>[];
      for (final it in result.items) {
        final pid = it.proProfileId ?? '';
        final idx = it.imageIndex.toString();
        final url = it.imageUrl ?? '';
        final key = (pid.isNotEmpty) ? '$pid#$idx' : url;

        if (key.isNotEmpty && !_seenKeys.contains(key)) {
          _seenKeys.add(key);
          newItems.add(it);
        }
      }

      if (mounted) {
        setState(() {
          _items.addAll(newItems);
          if ((result.nextCursor ?? '').isNotEmpty) {
            _nextCursor = result.nextCursor;
            _hasMore = true;
          } else {
            _nextCursor = null;
            _hasMore = false;
          }
        });
      }
    } catch (e, st) {
      debugPrint('Error fetching feed data: $e');
      debugPrint(st.toString());
      if (mounted) {
        setState(() {
          _hasMore = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyItemUpdateAt(int index, bool newFavStatus) {
    if (index < 0 || index >= _items.length) return;
    final currentItem = _items[index];
    final updatedItem = FeedImageItemStruct(
      imageUrl: currentItem.imageUrl,
      imageIndex: currentItem.imageIndex,
      proProfileId: currentItem.proProfileId,
      proFullName: currentItem.proFullName,
      proAvatarUrl: currentItem.proAvatarUrl,
      proProfession: currentItem.proProfession,
      proLocationLabel: currentItem.proLocationLabel,
      isFavorited: newFavStatus,
    );
    setState(() {
      _items[index] = updatedItem;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty && !_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucune inspiration trouvée.',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Essayez de modifier vos filtres',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: (1 / 1.2),
      ),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item = _items[index];
        final url = item.imageUrl ?? '';
        if (url.isEmpty) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () async {
            if (widget.onItemTap != null) {
              final result = await widget.onItemTap!(item);
              if (result is bool) {
                _applyItemUpdateAt(index, result);
              }
            }
          },
          child: SizedBox(
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 220,
                cacheWidth: 600,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFFE0E0E0),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE0E0E0),
                    child: const Icon(Icons.error_outline, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Magazine Draft entity for local persistence.
///
/// Serializes the magazine preview state to JSON for SharedPreferences storage.
/// Used to auto-save and restore magazine editing progress.
library;

import 'dart:convert';

/// A serializable snapshot of a single magazine page.
class MagazineDraftPage {
  /// Creates a magazine draft page.
  const MagazineDraftPage({
    required this.type,
    required this.photoIds,
  });

  /// Page type: 'cover', 'single', 'double', or 'mosaic'.
  final String type;

  /// Ordered list of selectionIds for photos on this page.
  final List<String> photoIds;

  /// Creates from JSON map.
  factory MagazineDraftPage.fromJson(Map<String, dynamic> json) {
    return MagazineDraftPage(
      type: json['type'] as String,
      photoIds: (json['photoIds'] as List<dynamic>).cast<String>(),
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'type': type,
        'photoIds': photoIds,
      };
}

/// A serializable snapshot of the entire magazine preview state.
class MagazineDraft {
  /// Creates a magazine draft.
  const MagazineDraft({
    required this.pages,
    required this.unassignedIds,
    this.formatName,
    required this.coverTitle,
    required this.coverSubtitle,
    required this.savedAt,
  });

  /// Ordered list of page snapshots.
  final List<MagazineDraftPage> pages;

  /// SelectionIds not assigned to any page.
  final List<String> unassignedIds;

  /// The selected format name (e.g. 'GUEST EDITION').
  final String? formatName;

  /// The cover title text.
  final String coverTitle;

  /// The cover subtitle text.
  final String coverSubtitle;

  /// When this draft was saved.
  final DateTime savedAt;

  /// Creates from JSON map.
  factory MagazineDraft.fromJson(Map<String, dynamic> json) {
    return MagazineDraft(
      pages: (json['pages'] as List<dynamic>)
          .map((e) => MagazineDraftPage.fromJson(e as Map<String, dynamic>))
          .toList(),
      unassignedIds: (json['unassignedIds'] as List<dynamic>).cast<String>(),
      formatName: json['formatName'] as String?,
      coverTitle: json['coverTitle'] as String,
      coverSubtitle: json['coverSubtitle'] as String,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'pages': pages.map((p) => p.toJson()).toList(),
        'unassignedIds': unassignedIds,
        'formatName': formatName,
        'coverTitle': coverTitle,
        'coverSubtitle': coverSubtitle,
        'savedAt': savedAt.toIso8601String(),
      };

  /// Serializes to a JSON string.
  String encode() => jsonEncode(toJson());

  /// Deserializes from a JSON string. Returns null on failure.
  static MagazineDraft? decode(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return MagazineDraft.fromJson(map);
    } on Object {
      return null;
    }
  }
}

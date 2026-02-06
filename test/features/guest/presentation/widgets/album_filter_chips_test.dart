import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/guest/presentation/widgets/album_filter_chips.dart';

void main() {
  group('AlbumFilterChips', () {
    late AlbumFilter lastFilter;

    Widget buildWidget({AlbumFilter activeFilter = AlbumFilter.all}) {
      return MaterialApp(
        home: Scaffold(
          body: AlbumFilterChips(
            activeFilter: activeFilter,
            onFilterChanged: (filter) => lastFilter = filter,
          ),
        ),
      );
    }

    testWidgets('displays all three filter labels', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Photos'), findsOneWidget);
      expect(find.text('Videos'), findsOneWidget);
    });

    testWidgets('tapping Photos triggers onFilterChanged', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.text('Photos'));
      expect(lastFilter, AlbumFilter.photos);
    });

    testWidgets('tapping Videos triggers onFilterChanged', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.text('Videos'));
      expect(lastFilter, AlbumFilter.videos);
    });

    testWidgets('tapping All triggers onFilterChanged', (tester) async {
      await tester.pumpWidget(buildWidget(activeFilter: AlbumFilter.photos));
      await tester.tap(find.text('All'));
      expect(lastFilter, AlbumFilter.all);
    });

    testWidgets('shows camera icon for Photos chip', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
    });

    testWidgets('shows videocam icon for Videos chip', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
    });
  });

  group('AlbumFilter enum', () {
    test('has three values', () {
      expect(AlbumFilter.values.length, 3);
    });

    test('values are all, photos, videos', () {
      expect(AlbumFilter.values, [
        AlbumFilter.all,
        AlbumFilter.photos,
        AlbumFilter.videos,
      ]);
    });
  });
}

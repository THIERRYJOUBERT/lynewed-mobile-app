import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/guest/presentation/widgets/album_stats_header.dart';

void main() {
  group('AlbumStatsHeader', () {
    Widget buildWidget({
      int photoCount = 0,
      int videoCount = 0,
      int lovedCount = 0,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AlbumStatsHeader(
            photoCount: photoCount,
            videoCount: videoCount,
            lovedCount: lovedCount,
          ),
        ),
      );
    }

    testWidgets('displays photo count', (tester) async {
      await tester.pumpWidget(buildWidget(photoCount: 12));
      expect(find.text('12'), findsOneWidget);
      expect(find.text('photos'), findsOneWidget);
    });

    testWidgets('displays singular "photo" for count 1', (tester) async {
      await tester.pumpWidget(buildWidget(photoCount: 1));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('photo'), findsOneWidget);
    });

    testWidgets('displays video count', (tester) async {
      await tester.pumpWidget(buildWidget(videoCount: 3));
      expect(find.text('3'), findsOneWidget);
      expect(find.text('videos'), findsOneWidget);
    });

    testWidgets('displays singular "video" for count 1', (tester) async {
      await tester.pumpWidget(buildWidget(videoCount: 1));
      expect(find.text('video'), findsOneWidget);
    });

    testWidgets('displays loved count', (tester) async {
      await tester.pumpWidget(buildWidget(lovedCount: 5));
      expect(find.text('5'), findsOneWidget);
      expect(find.text('loved'), findsOneWidget);
    });

    testWidgets('displays all three stats', (tester) async {
      await tester.pumpWidget(buildWidget(
        photoCount: 10,
        videoCount: 2,
        lovedCount: 3,
      ));
      expect(find.text('10'), findsOneWidget);
      expect(find.text('photos'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('videos'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('loved'), findsOneWidget);
    });

    testWidgets('shows heart icon', (tester) async {
      await tester.pumpWidget(buildWidget(lovedCount: 1));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('shows camera icon', (tester) async {
      await tester.pumpWidget(buildWidget(photoCount: 1));
      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
    });

    testWidgets('shows video icon', (tester) async {
      await tester.pumpWidget(buildWidget(videoCount: 1));
      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
    });
  });
}

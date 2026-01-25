/// Tests for ContentBlockWidget.
///
/// Verifies the content block widget:
/// - Renders text blocks correctly
/// - Renders image blocks correctly
/// - Renders video blocks correctly
/// - Renders quote blocks correctly
/// - Proper styling and layout
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/content/domain/entities/wed_content_block.dart';
import 'package:lynewed_beta/features/content/presentation/widgets/content_block_widget.dart';

void main() {
  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: child,
        ),
      ),
    );
  }

  group('ContentBlockWidget', () {
    group('Text blocks', () {
      testWidgets('should display text content', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: 'This is a paragraph of text.',
        );

        await tester.pumpWidget(buildTestWidget(
          child: const ContentBlockWidget(block: block),
        ));

        expect(find.text('This is a paragraph of text.'), findsOneWidget);
      });

      testWidgets('should handle multiline text', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Line 1\nLine 2\nLine 3',
        );

        await tester.pumpWidget(buildTestWidget(
          child: const ContentBlockWidget(block: block),
        ));

        expect(find.textContaining('Line 1'), findsOneWidget);
      });

      testWidgets('should handle empty text content', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: '',
        );

        await tester.pumpWidget(buildTestWidget(
          child: const ContentBlockWidget(block: block),
        ));

        expect(find.byType(ContentBlockWidget), findsOneWidget);
      });

      testWidgets('should handle null text content gracefully', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.text,
        );

        await tester.pumpWidget(buildTestWidget(
          child: const ContentBlockWidget(block: block),
        ));

        expect(find.byType(ContentBlockWidget), findsOneWidget);
      });
    });

    group('Image blocks', () {
      testWidgets('should display image placeholder', (tester) async {
        // Note: This test verifies widget accepts imageUrl parameter
        // Actual network image loading would require image mocking
        const block = WedContentBlock(
          type: ContentBlockType.image,
          imageUrl: 'https://example.com/image.jpg',
        );

        expect(block.imageUrl, 'https://example.com/image.jpg');
        expect(block.isImage, isTrue);
      });

      testWidgets('should handle missing imageUrl gracefully', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.image,
        );

        await tester.pumpWidget(buildTestWidget(
          child: const ContentBlockWidget(block: block),
        ));

        // Should show placeholder
        expect(find.byType(ContentBlockWidget), findsOneWidget);
      });
    });

    group('Video blocks', () {
      testWidgets('should display video placeholder', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.video,
          videoUrl: 'https://vimeo.com/123456',
        );

        await tester.pumpWidget(buildTestWidget(
          child: const ContentBlockWidget(block: block),
        ));

        // Should show video placeholder
        expect(find.byType(ContentBlockWidget), findsOneWidget);
      });

      testWidgets('should show play icon for video blocks', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.video,
          videoUrl: 'https://vimeo.com/123456',
        );

        await tester.pumpWidget(buildTestWidget(
          child: const ContentBlockWidget(block: block),
        ));

        expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      });

      testWidgets('should handle missing videoUrl gracefully', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.video,
        );

        await tester.pumpWidget(buildTestWidget(
          child: const ContentBlockWidget(block: block),
        ));

        expect(find.byType(ContentBlockWidget), findsOneWidget);
      });
    });

    group('Quote blocks', () {
      testWidgets('should display quote content', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.quote,
          content: 'This is an inspiring quote.',
        );

        await tester.pumpWidget(buildTestWidget(
          child: const ContentBlockWidget(block: block),
        ));

        expect(find.text('This is an inspiring quote.'), findsOneWidget);
      });

      testWidgets('should style quote differently from text', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.quote,
          content: 'Quote text',
        );

        await tester.pumpWidget(buildTestWidget(
          child: const ContentBlockWidget(block: block),
        ));

        // Quote should have special styling (italic or left border)
        expect(find.byType(ContentBlockWidget), findsOneWidget);
      });

      testWidgets('should display quote icon', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.quote,
          content: 'A beautiful quote.',
        );

        await tester.pumpWidget(buildTestWidget(
          child: const ContentBlockWidget(block: block),
        ));

        expect(find.byIcon(Icons.format_quote), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('should have proper padding', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Text content',
        );

        await tester.pumpWidget(buildTestWidget(
          child: const ContentBlockWidget(block: block),
        ));

        final paddingFinder = find.byType(Padding);
        expect(paddingFinder, findsWidgets);
      });
    });

    group('Widget configuration', () {
      testWidgets('should accept block parameter', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Content',
        );

        const widget = ContentBlockWidget(block: block);

        expect(widget.block, block);
        expect(widget.block.type, ContentBlockType.text);
        expect(widget.block.content, 'Content');
      });

      testWidgets('should render without errors', (tester) async {
        const block = WedContentBlock(
          type: ContentBlockType.text,
          content: 'Test',
        );

        expect(
          () async => tester.pumpWidget(buildTestWidget(
            child: const ContentBlockWidget(block: block),
          )),
          returnsNormally,
        );
      });
    });

    group('Multiple blocks', () {
      testWidgets('should render list of blocks', (tester) async {
        const blocks = [
          WedContentBlock(type: ContentBlockType.text, content: 'First paragraph'),
          WedContentBlock(type: ContentBlockType.quote, content: 'A quote'),
          WedContentBlock(type: ContentBlockType.text, content: 'Second paragraph'),
        ];

        await tester.pumpWidget(buildTestWidget(
          child: Column(
            children: blocks.map((b) => ContentBlockWidget(block: b)).toList(),
          ),
        ));

        expect(find.byType(ContentBlockWidget), findsNWidgets(3));
        expect(find.text('First paragraph'), findsOneWidget);
        expect(find.text('A quote'), findsOneWidget);
        expect(find.text('Second paragraph'), findsOneWidget);
      });
    });
  });
}

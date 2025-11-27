import 'package:flutter/material.dart';
import 'design.dart';

/// Test widget to validate Lynewed Design System renders identically to FlutterFlow
/// See /docs/App/DESIGN_SYSTEM.md for complete usage guide
/// Use this widget to validate design system implementation
class DesignSystemTestWidget extends StatelessWidget {
  const DesignSystemTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedTheme.of(context).primaryBackground,
      appBar: AppBar(
        title: Text(
          'Design System Test',
          style: LynewedTheme.of(context).titleMedium,
        ),
        backgroundColor: LynewedTheme.of(context).primaryBackground,
      ),
      body: SingleChildScrollView(
        padding: LynewedSpacing.pageContent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Typography Test
            _buildTypographySection(),
            LynewedGap.verticalXl,
            
            // Color Test
            _buildColorSection(),
            LynewedGap.verticalXl,
            
            // Button Test
            _buildButtonSection(),
            LynewedGap.verticalXl,
            
            // Input Test
            _buildInputSection(),
            LynewedGap.verticalXl,
            
            // Card Test
            _buildCardSection(),
            LynewedGap.verticalXl,
            
            // Spacing Test
            _buildSpacingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypographySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typography Test',
          style: LynewedTheme.of(context).headlineLarge,
        ),
        LynewedGap.verticalMd,
        Text(
          'Display Large (64px)',
          style: LynewedTheme.of(context).displayLarge,
        ),
        Text(
          'Headline Large (32px)',
          style: LynewedTheme.of(context).headlineLarge,
        ),
        Text(
          'Title Medium (20px)',
          style: LynewedTheme.of(context).titleMedium,
        ),
        Text(
          'Body Large (16px)',
          style: LynewedTheme.of(context).bodyLarge,
        ),
        Text(
          'Body Medium (14px)',
          style: LynewedTheme.of(context).bodyMedium,
        ),
        Text(
          'Label Medium (12px)',
          style: LynewedTheme.of(context).labelMedium,
        ),
        Text(
          'Caption (9px)',
          style: LynewedTheme.of(context).caption,
        ),
        Text(
          'Text on Dark Background',
          style: LynewedTextStyles.textOnDark(
            LynewedTheme.of(context).bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Test',
          style: LynewedTheme.of(context).headlineLarge,
        ),
        LynewedGap.verticalMd,
        _buildColorBox('Primary', LynewedColors.primary, LynewedColors.textOnPrimary),
        _buildColorBox('Background', LynewedColors.background, LynewedColors.textPrimary),
        _buildColorBox('Surface', LynewedColors.surface, LynewedColors.textPrimary),
        _buildColorBox('Border', LynewedColors.border, LynewedColors.textPrimary),
        _buildColorBox('Success', LynewedColors.success, LynewedColors.textOnPrimary),
        _buildColorBox('Warning', LynewedColors.warning, LynewedColors.textPrimary),
        _buildColorBox('Error', LynewedColors.error, LynewedColors.textOnPrimary),
      ],
    );
  }

  Widget _buildColorBox(String label, Color backgroundColor, Color textColor) {
    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: LynewedColors.border),
        borderRadius: LynewedBorders.borderRadiusNone,
      ),
      child: Text(
        label,
        style: LynewedTextStyles.bodyMedium.copyWith(color: textColor),
      ),
    );
  }

  Widget _buildButtonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Button Test',
          style: LynewedTheme.of(context).headlineLarge,
        ),
        LynewedGap.verticalMd,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: LynewedComponentStyles.primaryButton(),
            onPressed: () {},
            child: Text(
              'Primary Button',
              style: LynewedTheme.of(context).titleSmall,
            ),
          ),
        ),
        LynewedGap.verticalMd,
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: LynewedComponentStyles.secondaryButton(),
            onPressed: () {},
            child: Text(
              'Secondary Button',
              style: LynewedTheme.of(context).titleSmall,
            ),
          ),
        ),
        LynewedGap.verticalMd,
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: LynewedComponentStyles.textButton(),
            onPressed: () {},
            child: Text(
              'Text Button',
              style: LynewedTheme.of(context).titleSmall,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input Test',
          style: LynewedTheme.of(context).headlineLarge,
        ),
        LynewedGap.verticalMd,
        TextField(
          decoration: LynewedComponentStyles.inputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter your email',
          ),
        ),
        LynewedGap.verticalMd,
        TextField(
          decoration: LynewedComponentStyles.inputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
          ).copyWith(
            errorText: 'This field is required',
          ),
        ),
      ],
    );
  }

  Widget _buildCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Test',
          style: LynewedTheme.of(context).headlineLarge,
        ),
        LynewedGap.verticalMd,
        Container(
          width: double.infinity,
          padding: LynewedSpacing.allLg,
          decoration: LynewedComponentStyles.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Card Title',
                style: LynewedTheme.of(context).titleMedium,
              ),
              LynewedGap.verticalSm,
              Text(
                'This is a card component using the design system. It should match the MVP card styling exactly.',
                style: LynewedTheme.of(context).bodyMedium,
              ),
            ],
          ),
        ),
        LynewedGap.verticalMd,
        Container(
          width: double.infinity,
          padding: LynewedSpacing.allLg,
          decoration: LynewedComponentStyles.surfaceDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Surface Card',
                style: LynewedTheme.of(context).titleMedium,
              ),
              LynewedGap.verticalSm,
              Text(
                'This card uses the surface background color.',
                style: LynewedTheme.of(context).bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpacingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spacing Test',
          style: LynewedTheme.of(context).headlineLarge,
        ),
        LynewedGap.verticalMd,
        Container(
          width: double.infinity,
          height: 40,
          color: LynewedColors.gray200,
          child: const Center(child: Text('40px height')),
        ),
        LynewedGap.verticalSm,
        Container(
          width: double.infinity,
          height: 20,
          color: LynewedColors.gray300,
          child: const Center(child: Text('20px height')),
        ),
        LynewedGap.verticalMd,
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              color: LynewedColors.primary,
            ),
            LynewedGap.horizontalMd,
            Container(
              width: 60,
              height: 60,
              color: LynewedColors.gray200,
            ),
            LynewedGap.horizontalXl,
            Container(
              width: 60,
              height: 60,
              color: LynewedColors.gray300,
            ),
          ],
        ),
        LynewedGap.verticalLg,
        Text('Safe Area Padding Examples:'),
        LynewedGap.verticalSm,
        Container(
          width: double.infinity,
          padding: LynewedSpacing.pageContent,
          decoration: LynewedComponentStyles.cardDecoration(),
          child: Text('Page Content Padding (20, 70, 20, 0)'),
        ),
      ],
    );
  }
}

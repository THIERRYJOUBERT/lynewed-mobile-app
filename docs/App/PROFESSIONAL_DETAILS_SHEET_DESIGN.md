# Professional Details Sheet - Design System v2.0

## Overview
The `ProfessionalDetailsSheet` is a standardized bottom sheet for displaying professional information on the map. It follows the Lynewed Design System v2.0 specifications and uses reusable components.

## Layout Structure

```
┌─────────────────────────────────────────────────────┐
│  [Avatar]  Name (sheetTitle)          [♡]          │
│            Business name (top)                       │
│            │                                        │
│            │                                        │ ← Spacer
│            │                                        │
│            🏢 Profession (bottom)                    │
├─────────────────────────────────────────────────────┤
│ About (sectionTitle)                                 │
│                                                     │
│ 📍 City (12km) │ 💶 Budget Range                   │ ← Location & Budget
│                                                     │
│ [10px gap]                                         │
│ Description text...                                │
├─────────────────────────────────────────────────────┤
│ Portfolio (sectionTitle)                            │
│ [Image preview grid]                                │
├─────────────────────────────────────────────────────┤
│ Links (sectionTitle)                                │
│ [📷 Instagram] [🌐 Website]                        │
├─────────────────────────────────────────────────────┤
│ [View Profile] [Contact]                            │ ← Action buttons
└─────────────────────────────────────────────────────┘
```

## Design System Tokens

### Typography
- **Sheet Title**: `LynewedTextStyles.sheetTitle` (18px, w500)
- **Section Title**: `LynewedTextStyles.sectionTitle` (16px, w600)
- **Body Text**: `LynewedTextStyles.bodyMedium` (16px, w400)
- **Small Text**: `LynewedTextStyles.bodySmall` (14px, w500 for location/budget)

### Colors
- **Primary**: `LynewedColors.primary` (Black #000000)
- **Background**: `LynewedColors.background` (White #FFFFFF)
- **Text Primary**: `LynewedColors.textPrimary` (Black)
- **Text Secondary**: `LynewedColors.textSecondary` (Gray)
- **Success**: `LynewedColors.success` (Green)
- **Error**: `LynewedColors.error` (Red)

### Spacing
- **Between sections**: 30px (`LynewedSpacing.xxxl`)
- **Label to content**: 10px (`LynewedSpacing.sm`)
- **Vertical separator**: 10px spacing
- **Button height**: 48px (`LynewedSpacing.buttonHeight`)

### Borders
- **Sheet corners**: 24px radius (`LynewedBorders.sheetBorderRadius`)
- **Buttons**: 0px radius (square)
- **Chips**: 4px radius (`LynewedBorders.chipBorderRadius`)

## Key Components

### 1. LynewedDetailsSheet
Reusable container for detail sheets with:
- Handle bar
- Header with avatar, title, subtitle, badge, trailing widget
- Scrollable content area
- Fixed action buttons

### 2. LynewedInfoRow
Standardized info row with icon and text:
```dart
LynewedInfoRow(
  icon: Icons.location_on_outlined,
  text: 'Paris',
  trailing: Text('(12km)'),
)
```

### 3. LynewedInlineInfoRow
Two info rows with vertical separator:
```dart
LynewedInlineInfoRow(
  left: LynewedLocationRow('Paris', '12km'),
  right: LynewedBudgetRow('1000-2000€'),
)
```

### 4. LynewedButton
Standardized buttons:
- **Primary**: Black background, white text
- **Secondary**: Transparent background, black border
- **Destructive**: Error color for delete actions

## Data Flow

### 1. Fixed Location Display
The sheet displays the **city name** from the fixed location point, not the profile location:

```dart
// Extract city from "15 Rue de Rivoli, 75001 Paris" → "Paris"
final fixedLocationCity = _extractCityFromAddress(locationLabel);

// Pass to sheet
ProfessionalDetailsSheet(
  details: proDetails,
  fixedLocation: fixedLocationCity, // City name only
)
```

### 2. Header Layout
```
┌─────────────────────────────────────┐
│  [Avatar]  Name (sheetTitle)        │
│            Business name (top)       │ ← If different
│            │                         │
│            │                         │ ← Spacer
│            │                         │
│            🏢 Profession (bottom)    │ ← With icon
└─────────────────────────────────────┘
```

### 3. About Section
- **Location**: City from fixed location + distance
- **Budget**: Professional's budget range
- **Description**: Professional's description (optional)

## Usage Examples

### Basic Usage
```dart
ProfessionalDetailsSheet(
  details: professionalDetails,
  fixedLocation: 'Paris',
  onContact: () => _handleContact(),
  onFavoriteToggle: () => _handleFavorite(),
  onViewProfile: () => _handleViewProfile(),
  showFavoriteButton: userRole == 'bride',
)
```

### With Custom Actions
```dart
ProfessionalDetailsSheet(
  details: professionalDetails,
  fixedLocation: 'Paris',
  actions: [
    LynewedButton(
      text: 'Custom Action',
      onPressed: _handleCustomAction,
    ),
  ],
)
```

## Implementation Notes

### 1. Location Extraction
The `_extractCityFromAddress` function handles multiple address formats:
- French: "15 Rue de Rivoli, 75001 Paris" → "Paris"
- UK: "10 Downing Street, London SW1A 2AA" → "London"
- Fallback: Last part of address

### 2. Database Integration
The `search_map_bundle` RPC includes `locationLabel` for fixed locations:
```sql
'styleInfo', jsonb_build_object(
  'locationLabel', fl.label  -- Full address from professional_fixed_locations
)
```

### 3. Reusable Patterns
- Use `LynewedDetailsSheet` for all detail sheets
- Use `LynewedInfoRow` for consistent info display
- Use `LynewedButton` for all actions
- Follow the 30px section spacing rule

## Validation Checklist

- [ ] Typography uses correct styles (w500 max, w600 for CTAs only)
- [ ] Spacing follows 30px between sections, 10px label-content
- [ ] Colors use LynewedColors tokens
- [ ] Borders use correct radius (24px sheets, 0px buttons, 4px chips)
- [ ] Location shows city from fixed location, not profile location
- [ ] Header has profession at bottom with icon
- [ ] About section has location+budget inline with separator
- [ ] Action buttons use correct styles (primary/secondary)
- [ ] All components are reusable from design system

## Migration from FlutterFlow

### Before (FlutterFlow)
```dart
FlutterFlowTheme.of(context).primaryText
FontWeight.bold
BorderRadius.circular(12)
```

### After (Design System v2)
```dart
LynewedColors.textPrimary
FontWeight.w500 (max)
LynewedBorders.chipBorderRadius (4px)
```

## Future Enhancements

1. **Animation**: Add subtle animations for transitions
2. **Accessibility**: Improve screen reader support
3. **Localization**: Support multiple languages for address extraction
4. **Performance**: Optimize image loading in portfolio section
5. **Testing**: Add comprehensive widget tests

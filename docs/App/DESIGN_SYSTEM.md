# LYNEWED Design System V4

**Version:** 4.0  
**Last Updated:** 2025-12-08  
**Status:** Authoritative Reference

---

## Quick Start

```dart
// Single import for all Design System components
import '/core/design/design.dart';

// For widgets (sheets, buttons, text fields, etc.)
import '/core/design/widgets/widgets.dart';
```

### Basic Usage

```dart
// Access colors
LynewedColors.primary          // Black (#000000)
LynewedColors.textPrimary      // Dark text (#141414)
LynewedColors.textSecondary    // Gray text (#545454)

// Access text styles
LynewedTextStyles.sheetTitle   // 18px, w500
LynewedTextStyles.sectionTitle // 16px, w500
LynewedTextStyles.bodyMedium   // 14px, w400 (default)

// Access spacing
LynewedSpacing.sheetHorizontalPadding // 20px
LynewedSpacing.buttonHeight           // 48px

// Theme API (mirrors FlutterFlowTheme)
LynewedTheme.of(context).primaryBackground
LynewedTheme.of(context).bodyMedium
```

---

## Typography

### Font Family

```dart
static const String fontFamily = 'Haas Grot Text Trial';
```

### Size Scale

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `displayLarge` | 48px | w500 | 1.15 | Hero screens only |
| `displayMedium` | 36px | w500 | 1.2 | Splash screens |
| `displaySmall` | 28px | w500 | 1.2 | Large headings |
| `headlineLarge` | 24px | w500 | 1.25 | Page titles |
| `headlineMedium` | 20px | w500 | 1.3 | Major sections |
| `headlineSmall` | 18px | w500 | 1.3 | Sub-sections |
| `titleLarge` | 18px | w500 | 1.3 | Dialog titles |
| `titleMedium` | 16px | w500 | 1.35 | Section titles (`sectionTitle`) |
| `titleSmall` | 14px | w500 | 1.35 | Sub-titles |
| `bodyLarge` | 16px | w400 | 1.5 | Important body text |
| `bodyMedium` | 14px | w400 | 1.5 | **Default text** |
| `bodySmall` | 13px | w400 | 1.45 | Secondary text |
| `labelLarge` | 12px | w400 | 1.4 | Large labels |
| `labelMedium` | 11px | w400 | 1.4 | Medium labels |
| `labelSmall` | 10px | w400 | 1.4 | Captions, hints |
| **`sheetTitle`** | **20px** | **w500** | 1.3 | **Sheet/Page headers** |

### Semantic Styles (Use These)

```dart
// Sheet/Page header title
LynewedTextStyles.sheetTitle    // 20px, w500

// Form section titles (e.g., "Wedding Date *")
LynewedTextStyles.sectionTitle  // = titleMedium (16px, w500)

// List items, menu items
LynewedTextStyles.listItem      // = bodyMedium (14px, w400)

// Input hint text
LynewedTextStyles.inputHint     // bodyMedium + gray300 color

// Button text (handled internally by LynewedButton)
// Uses: bodyMedium (15px) + w400 + white

// Chip text
LynewedTextStyles.chipText      // = bodyMedium (14px, w400)
```

### Weight Rules

| Weight | Usage |
|--------|-------|
| **w300** | Input text values, date picker text, chip text, "X selected" counters |
| **w400** | **Default** - Body text, labels, buttons, list items, error messages |
| **w500** | **MAX** - Section titles, sheet titles, currency symbols, option card titles |
| **w600+** | ❌ **NEVER USE** |

> ⚠️ **CRITICAL:** Never use fontWeight > w500. The design is intentionally light for elegance.
> - **Buttons = w400** (not bold)
> - **Section/Sheet titles = w500** (max emphasis)
> - **Input values = w300** (lighter than labels)

---

## Colors

### Primary Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#000000` | Buttons, selected states |
| `background` | `#FFFFFF` | Page/sheet backgrounds |
| `surface` | `#F5F5F5` | Cards, elevated surfaces |
| `border` | `#EBEBEB` | Borders, dividers |
| `textPrimary` | `#141414` | Primary text |
| `textSecondary` | `#545454` | Secondary text, hints |

### Neutral Grays

| Token | Hex | Usage |
|-------|-----|-------|
| `gray100` | `#727272` | Icons, tertiary text |
| `gray200` | `#D9D9D9` | Chip backgrounds, borders |
| `gray300` | `#BFBFBF` | Placeholder text, disabled |

### Functional Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#249689` | Success states, confirmations |
| `warning` | `#F9CF58` | Warnings, pending states |
| `error` | `#FF5963` | Errors, destructive actions |
| `info` | `#FFFFFF` | Info states |

### Special Colors

```dart
LynewedColors.textOnDark      // White - text on dark backgrounds
LynewedColors.textOnPrimary   // White - text on primary buttons
LynewedColors.inputBorderColor // #EBEBEB - input field borders
```

### Color Rules

> ⚠️ **CRITICAL:** The app is BLACK & WHITE. Colors are used ONLY for:
> - Error states (red)
> - Success states (green)
> - Warning states (yellow)
> - Never for decoration or branding

---

## Spacing

### Base Grid

The spacing system uses a **4px baseline grid**.

| Token | Value | Usage |
|-------|-------|-------|
| `xxs` | 2px | Micro spacing |
| `xs` | 4px | Tight spacing |
| `sm` | 8px | Small gaps |
| `md` | 12px | Medium gaps |
| `lg` | 16px | Large gaps |
| `xl` | 20px | Extra large gaps |
| `xxl` | 24px | Section spacing |
| `xxxl` | 32px | Major sections |

### Critical Spacing Rules

| Context | Value | Notes |
|---------|-------|-------|
| **Inter-section spacing** | **30px** | Between form sections |
| **Label to content** | **10px** | Section title to first element |
| **Items within section** | 8-12px | Between chips, inputs |
| **Horizontal margins** | **20px** | Sheet/page content padding |

### Sheet Layout

```dart
// Sheet header padding
EdgeInsets.fromLTRB(20, 20, 20, 12)  // left, top, right, bottom

// Sheet content padding
EdgeInsets.symmetric(horizontal: 20, vertical: 16)

// Handle bar margin
EdgeInsets.only(top: 12)
```

### Component Heights

| Element | Height |
|---------|--------|
| Buttons | **48px** |
| Text inputs | **48px** |
| Date pickers | **48px** |
| Dropdowns | **48px** |
| Header action circles | **44px** |

### Gap Utilities

```dart
// Vertical gaps
LynewedGap.verticalSm   // 8px
LynewedGap.verticalMd   // 12px
LynewedGap.verticalLg   // 16px
LynewedGap.verticalXl   // 20px
LynewedGap.verticalXxl  // 24px
LynewedGap.verticalXxxl // 32px

// Horizontal gaps
LynewedGap.horizontalSm  // 8px
LynewedGap.horizontalMd  // 12px
// ... etc

// Custom gaps
LynewedGap.vertical(30)  // 30px vertical
LynewedGap.horizontal(10) // 10px horizontal
```

---

## Border Radius

| Element | Radius | Token |
|---------|--------|-------|
| **Buttons** | **0px** | `LynewedBorders.none` |
| **Sheets (top)** | **24px** | `LynewedBorders.xl` |
| **Chips/Cards/Items** | **4px** | `LynewedBorders.xs` |
| **Inputs** | **4px** | `LynewedBorders.xs` |
| **Avatars** | Circle | `BorderRadius.circular(100)` |

### Border Radius Utilities

```dart
LynewedBorders.borderRadiusNone  // 0px - buttons
LynewedBorders.borderRadiusSm    // 2px - handle bars
LynewedBorders.borderRadiusMd    // 8px - cards
LynewedBorders.borderRadiusLg    // 12px - modals
LynewedBorders.borderRadiusXl    // 24px - sheets

// Sheet-specific
LynewedBorders.sheetBorderRadius // Top corners only: 24px
```

---

## Components

### Sheets

Use `LynewedSheet` for all bottom sheets with forms/actions.

```dart
LynewedSheet(
  title: 'Create Wedding',
  onClose: () => Navigator.pop(context),
  bottomAction: LynewedButton(
    text: 'Save',
    onPressed: _save,
    width: double.infinity,
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section 1
      _buildSectionTitle('Wedding Date *'),
      _buildDateInput(),
      const SizedBox(height: 30), // Inter-section spacing
      
      // Section 2
      _buildSectionTitle('Venue *'),
      AddressSearchWidget(...),
      const SizedBox(height: 30),
      
      // ... more sections
    ],
  ),
)
```

#### Sheet Structure

```
┌─────────────────────────────────────┐
│           Handle Bar (40x4)         │  ← 12px top margin
├─────────────────────────────────────┤
│  Title (left)          Close (right)│  ← padding: 20, 20, 20, 12
│  [Subtitle if any]                  │
├─────────────────────────────────────┤
│           Divider (1px)             │
├─────────────────────────────────────┤
│                                     │
│         Scrollable Content          │  ← padding: 20, 16, 20, 0
│                                     │
│  Section Title                      │
│  [10px gap]                         │
│  Content                            │
│  [30px gap]                         │
│  Section Title                      │
│  ...                                │
│                                     │
├─────────────────────────────────────┤
│         Bottom Action               │  ← 32px top, 20px bottom
└─────────────────────────────────────┘
```

#### Sheet Variants

| Type | Widget | Use Case |
|------|--------|----------|
| Form Sheet | `LynewedSheet` | Create/Edit forms |
| Details Sheet | `LynewedDetailsSheet` | View entity details |
| Filter Sheet | Custom (no divider) | Filters with DraggableScrollable |

### Buttons

Use `LynewedButton` for all buttons.

```dart
// Primary button (black background)
LynewedButton(
  text: 'Save Changes',
  onPressed: _save,
  width: double.infinity,
)

// Secondary button (outlined)
LynewedButton(
  text: 'Cancel',
  onPressed: _cancel,
  type: LynewedButtonType.secondary,
)

// Ghost button (text only)
LynewedButton(
  text: 'Skip',
  onPressed: _skip,
  type: LynewedButtonType.ghost,
)

// Destructive button (red text)
LynewedButton(
  text: 'Delete',
  onPressed: _delete,
  type: LynewedButtonType.destructive,
)

// Destructive filled (red background)
LynewedButton(
  text: 'Delete Account',
  onPressed: _deleteAccount,
  type: LynewedButtonType.destructiveFilled,
)

// With loading state
LynewedButton(
  text: 'Saving...',
  onPressed: _save,
  isLoading: _isLoading,
)

// With icon
LynewedButton(
  text: 'Add Photo',
  onPressed: _addPhoto,
  icon: Icons.add_photo_alternate,
)
```

#### Button Specifications

| Property | Value |
|----------|-------|
| Height | 48px |
| Border radius | 0px (square) |
| Horizontal padding | 24px |
| Font size | 15px |
| Font weight | **w400** (not bold) |
| Primary background | Black |
| Primary text | White |

### Text Fields

Use `LynewedTextField` for all text inputs.

```dart
// Standard input (gray background, no border)
LynewedTextField(
  controller: _nameController,
  label: 'Wedding Name (optional)',
  hint: 'e.g., Sophie & Thomas Wedding',
)

// Value input (transparent background, border)
LynewedTextField(
  controller: _budgetController,
  hint: 'Min',
  keyboardType: TextInputType.number,
  isValueInput: true,  // ← Transparent bg + border
)

// Multi-line
LynewedTextField(
  controller: _descriptionController,
  label: 'Description *',
  hint: 'Describe your request...',
  maxLines: 4,
  maxLength: 500,
)

// With validation
LynewedTextField(
  controller: _titleController,
  label: 'Title *',
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    return null;
  },
)
```

#### Text Field Specifications

| Property | Standard | Value Input |
|----------|----------|-------------|
| Background | `#F2F2F2` | Transparent |
| Border | None | `gray200` |
| Border radius | 4px | 4px |
| Content padding | 16px H, 14px V | 16px H, 14px V |
| Text style | bodyMedium, w300 | bodyMedium, w300 |

### Chips

Use `LynewedChip` for selectable tags/filters.

```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: professions.map((profession) {
    return LynewedChip(
      label: profession.displayName,
      selected: _selected.contains(profession),
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selected.add(profession);
          } else {
            _selected.remove(profession);
          }
        });
      },
    );
  }).toList(),
)
```

#### Chip Specifications

| Property | Unselected | Selected |
|----------|------------|----------|
| Background | `#F2F2F2` | Black |
| Text color | Black | White |
| Text weight | w300 | w300 |
| Border radius | 4px | 4px |
| Padding | 12px H, 8px V | 12px H, 8px V |

### Section Titles

Use `LynewedSectionTitle` or inline pattern.

```dart
// Using widget
const LynewedSectionTitle('Wedding Date *'),
const SizedBox(height: 10),
_buildDateInput(),

// Inline pattern (preferred in sheets)
Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title, style: LynewedTextStyles.sectionTitle),
  );
}
```

### Sliders

Use `LynewedSlider` for single-value selection.

```dart
LynewedSlider(
  value: _searchRadius,
  steps: [5, 10, 20, 50, 100],
  suffix: ' km',
  formatValue: (value) => '$value km',
  onChanged: (value) => setState(() => _searchRadius = value),
)
```

### Date Inputs

Pattern for date selection fields:

```dart
Widget _buildDateInput({
  required DateTime? date,
  required String placeholder,
  required VoidCallback? onTap,
}) {
  final dateFormat = DateFormat('MMM d, yyyy');
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: LynewedColors.gray200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: date != null 
                ? LynewedColors.textPrimary 
                : LynewedColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            date != null ? dateFormat.format(date) : placeholder,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: date != null 
                  ? LynewedColors.textPrimary 
                  : LynewedColors.textSecondary,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    ),
  );
}
```

### Error Banners

Use `LynewedComponentStyles.errorBannerDecoration()`.

```dart
Widget _buildErrorBanner() {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(12),
    decoration: LynewedComponentStyles.errorBannerDecoration(),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: LynewedColors.error, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _errorMessage!,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.error,
            ),
          ),
        ),
      ],
    ),
  );
}
```

---

## Pages

### Page Header (No Navbar)

For pages without bottom navbar (e.g., MessagesPage, ChatDetailsPage):

```dart
Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
    child: Row(
      children: [
        // Back button - 44x44 tap target
        LynewedComponentStyles.backButton(context),
        
        const SizedBox(width: 4),
        
        // Title - same style as LynewedSheet
        Expanded(
          child: Text(
            'Messages',
            style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
          ),
        ),
        
        // Action button (optional) - 44x44 circle
        GestureDetector(
          onTap: _showArchived,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: LynewedColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.archive_outlined,
              size: 22,
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}
```

### Page Structure

```dart
Scaffold(
  backgroundColor: LynewedColors.background,
  body: SafeArea(
    child: Column(
      children: [
        // Header
        _buildHeader(),
        
        // Divider (same as LynewedSheet)
        const Divider(height: 1, color: LynewedColors.gray200),
        
        // Body
        Expanded(
          child: _buildBody(),
        ),
      ],
    ),
  ),
)
```

---

## Modals / Popup Menus

Use `LynewedMoreMenu` for action menus.

```dart
LynewedHeaderActions(
  isFavorited: _isFavorited,
  onFavoriteToggle: _toggleFavorite,
  menuItems: [
    LynewedMenuItem(
      icon: Icons.flag_outlined,
      label: 'Report',
      onTap: _showReportSheet,
    ),
    LynewedMenuItem(
      icon: Icons.block,
      label: 'Block',
      onTap: _blockUser,
      isDestructive: true,
    ),
  ],
)
```

### Menu Item Specifications

| Property | Value |
|----------|-------|
| Height | 48px |
| Icon size | 20px |
| Icon-text gap | 12px |
| Text style | bodyMedium |
| Destructive color | `LynewedColors.error` |

---

## Patterns

### Form Sections

Standard pattern for form sections in sheets:

```dart
// Section title with required indicator
_buildSectionTitle('Wedding Date *'),

// Content
_buildDateInput(...),

// Inter-section spacing
const SizedBox(height: 30),

// Next section
_buildSectionTitle('Venue *'),
```

### Selected Count Indicator

Show count above chip groups:

```dart
if (_selectedProfessions.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      '${_selectedProfessions.length} selected',
      style: LynewedTextStyles.labelSmall.copyWith(
        color: LynewedColors.textSecondary,
        fontWeight: FontWeight.w300,
      ),
    ),
  ),
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [...chips],
)
```

### Location Status Indicator

Show validation status for address fields:

```dart
Widget _buildLocationStatus() {
  final hasLocation = _lat != null && _lng != null;
  return Row(
    children: [
      Icon(
        hasLocation ? Icons.check_circle : Icons.warning_amber_rounded,
        size: 16,
        color: hasLocation ? LynewedColors.success : LynewedColors.warning,
      ),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          hasLocation 
              ? 'Location confirmed - will appear on map'
              : 'Please select an address from suggestions',
          style: LynewedTextStyles.labelSmall.copyWith(
            color: hasLocation ? LynewedColors.success : LynewedColors.warning,
          ),
        ),
      ),
    ],
  );
}
```

### Visibility Options (Radio-style)

```dart
Widget _buildVisibilityOption(
  Visibility value,
  IconData icon,
  String title,
  String subtitle,
) {
  final isSelected = _visibility == value;
  return InkWell(
    onTap: () => setState(() => _visibility = value),
    child: Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.black : LynewedColors.gray200,
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.black : LynewedColors.textSecondary, size: 20),
          const SizedBox(height: 4),
          Text(title, style: LynewedTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : LynewedColors.textPrimary,
          )),
          Text(subtitle, style: LynewedTextStyles.labelSmall.copyWith(
            color: LynewedColors.textSecondary,
          )),
        ],
      ),
    ),
  );
}
```

---

## Do's and Don'ts

### ✅ DO

- **Always** use `LynewedSheet` for bottom sheets with forms
- **Always** use `LynewedButton` for buttons
- **Always** use `LynewedTextField` for text inputs
- **Always** use `LynewedChip` for selectable tags
- **Always** use 30px spacing between form sections
- **Always** use 10px spacing between label and content
- **Always** use 20px horizontal padding in sheets/pages
- **Always** use 48px height for buttons and inputs
- **Always** use 4px border radius for chips, inputs, cards
- **Always** use 24px border radius for sheet top corners
- **Always** use 0px border radius for buttons
- **Always** use `LynewedColors` for all colors
- **Always** use `LynewedTextStyles` for all text
- **Always** import from `/core/design/design.dart`

### ❌ DON'T

- **Never** use `FlutterFlowTheme` - use `LynewedTheme`
- **Never** use fontWeight > w500 (except button text)
- **Never** use colors for decoration (only for states)
- **Never** hardcode color values - use tokens
- **Never** skip the divider after sheet headers
- **Never** use different spacing between sections
- **Never** create custom button styles
- **Never** use rounded buttons (radius must be 0)
- **Never** use `.withOpacity()` - use `.withValues(alpha:)`

---

## Migration from FlutterFlow

### Color Migration

```dart
// Before
FlutterFlowTheme.of(context).primaryBackground
FlutterFlowTheme.of(context).primaryText
FlutterFlowTheme.of(context).error

// After
LynewedColors.background
LynewedColors.textPrimary
LynewedColors.error

// Or via theme API
LynewedTheme.of(context).primaryBackground
LynewedTheme.of(context).primaryText
LynewedTheme.of(context).error
```

### Typography Migration

```dart
// Before
FlutterFlowTheme.of(context).bodyMedium
FlutterFlowTheme.of(context).titleLarge

// After
LynewedTextStyles.bodyMedium
LynewedTextStyles.titleLarge

// Or via theme API
LynewedTheme.of(context).bodyMedium
LynewedTheme.of(context).titleLarge
```

### Component Migration

```dart
// Before (FlutterFlow button)
FFButtonWidget(
  text: 'Save',
  onPressed: _save,
  options: FFButtonOptions(
    height: 48,
    color: Colors.black,
  ),
)

// After
LynewedButton(
  text: 'Save',
  onPressed: _save,
  width: double.infinity,
)
```

---

## File Structure

```
lib/core/design/
├── design.dart                    # Barrel export (main import)
├── lynewed_colors.dart           # Color tokens
├── lynewed_text_styles.dart      # Typography tokens
├── lynewed_spacing.dart          # Spacing tokens
├── lynewed_borders.dart          # Border radius utilities
├── lynewed_component_styles.dart # Component styles (buttons, inputs)
├── lynewed_design_system.dart    # Main API (LynewedTheme)
├── lynewed_app_theme.dart        # Complete ThemeData
├── test_design_system_widget.dart # Validation widget
└── widgets/                      # Reusable widgets
    ├── widgets.dart              # Barrel export for widgets
    ├── lynewed_sheet.dart        # Form sheets
    ├── lynewed_details_sheet.dart # Details sheets
    ├── lynewed_button.dart       # Buttons
    ├── lynewed_text_field.dart   # Text inputs
    ├── lynewed_chip.dart         # Chips
    ├── lynewed_slider.dart       # Single value slider
    ├── lynewed_range_slider.dart # Range slider
    ├── lynewed_budget_slider.dart # Budget-specific slider
    ├── lynewed_distance_slider.dart # Distance slider
    ├── lynewed_section_title.dart # Section titles
    ├── lynewed_header_actions.dart # Header with favorite + menu
    ├── lynewed_more_menu.dart    # Popup menu
    ├── lynewed_info_row.dart     # Info display rows
    └── lynewed_about_section.dart # About/description section
```

---

## Reference Screens

These screens are the authoritative references for Design System implementation:

| Screen | Path | Reference For |
|--------|------|---------------|
| WeddingCreateSheet | `lib/features/map/presentation/sheets/wedding_create_sheet.dart` | Form sheets, sections, spacing |
| AlertCreateSheet | `lib/features/map/presentation/sheets/alert_create_sheet.dart` | Form sheets, dropdowns |
| ReportUserSheet | `lib/features/chat/presentation/sheets/report_user_sheet.dart` | Radio selection pattern |
| FilterSheet | `lib/features/map/presentation/widgets/filter_sheet.dart` | Filter sheets (no divider) |
| MessagesPage | `lib/features/chat/presentation/pages/messages_page.dart` | Page headers, lists |

---

## Extracted Reference Values

**Source:** `wedding_create_sheet.dart` (Primary Reference Screen)

### Typography Usage

| Element | Style | Size | Weight | Notes |
|---------|-------|------|--------|-------|
| Sheet title | `sheetTitle` | 20px | w500 | Header title |
| Section title | `sectionTitle` | 16px | w500 | "Wedding Date *" |
| Body text | `bodyMedium` | 14px | w400 | Default |
| Input text | `bodyMedium` | 14px | **w300** | Lighter for inputs |
| Date picker text | `bodyMedium` | 14px | **w300** | Lighter for values |
| "X selected" count | `labelSmall` | 10px | **w300** | Counter text |
| Location status | `labelSmall` | 10px | w400 | Status messages |
| Currency symbol | `bodyMedium` | 14px | w500 | € symbol |
| Option card title | `labelMedium` | 11px | w500 | "Private", "Visible" |
| Option card subtitle | `labelSmall` | 10px | w400 | Description |
| Error message | `bodySmall` | 13px | w400 | Error text |
| List item | `bodyMedium` | 14px | w400 | Currency list |
| Button text | `buttonPrimary` | 15px | **w400** | NOT bold |

### Spacing Usage

| Context | Value | Code |
|---------|-------|------|
| Inter-section | **30px** | `SizedBox(height: 30)` |
| Label → content | **10px** | `Padding(bottom: 10)` |
| Items in Wrap | **8px** | `spacing: 8, runSpacing: 8` |
| Date inputs gap | **12px** | `SizedBox(width: 12)` |
| Icon → text | **8px** | `SizedBox(width: 8)` |
| Location status gap | **4px** | `SizedBox(width: 4)` |
| Error banner margin | **20px** | `margin: bottom: 20` |

### Component Dimensions

| Component | Height | Padding | Radius |
|-----------|--------|---------|--------|
| Button | 48px | H24 | 0px |
| Text input | 48px | H16, V14 | 4px |
| Date input | 48px | H12 | 4px |
| Currency selector | 48px | H12 | 4px |
| Visibility option | 80px | 12 | 4px |
| Chip | auto | H12, V8 | 4px |
| Error banner | auto | 12 | 4px |

### Color Usage

| Element | Color | Token |
|---------|-------|-------|
| Sheet background | #FFFFFF | `background` |
| Input background | #F2F2F2 | Custom |
| Input border | #D9D9D9 | `gray200` |
| Primary text | #141414 | `textPrimary` |
| Secondary text | #545454 | `textSecondary` |
| Placeholder | #BFBFBF | `gray300` |
| Selected chip bg | #000000 | `primary` |
| Unselected chip bg | #F2F2F2 | Custom |
| Error | #FF5963 | `error` |
| Success | #249689 | `success` |
| Warning | #F9CF58 | `warning` |

---

## Changelog

### V4.0 (2025-12-08)
- Complete documentation rewrite
- Extracted exact values from reference screens
- Added comprehensive code examples
- Documented all patterns and components
- Added migration guide from FlutterFlow
- **Fixed:** sheetTitle now 20px (was 18px)
- **Fixed:** buttonPrimary now w400 (was w500)
- **Fixed:** formSectionGap now 30px (was 20px)
- **Fixed:** All w600 usages → w500 (max allowed)
- **Fixed:** LynewedChip count badge w700 → w500
- **Fixed:** LynewedTextField label gap 12px → 10px

### V3.0 (Previous)
- Initial Design System implementation
- Basic tokens and widgets

---

**Document Owner:** Design System Team  
**Last Validated:** 2025-12-08

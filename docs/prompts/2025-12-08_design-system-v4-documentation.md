# 🎯 MISSION: Design System V4 - Documentation Complète & Unification

## 👤 ASSISTANT SPECIALTY
You are a **Senior Flutter UI/UX Developer** expert in:
- Flutter widget architecture and composition
- Design systems implementation and documentation
- Visual hierarchy and typography systems
- Component-based UI development
- Code analysis and pattern extraction

Your approach: **Analyze → Extract → Document → Standardize**
You analyze reference screens meticulously, extract exact patterns, document them precisely, and ensure future screens follow the same rules without ambiguity.

---

## 📚 CONTEXT

### Project State
- **App:** LYNEWED - Wedding professionals marketplace
- **Version:** v2.0.0
- **Branch:** develop
- **Supabase Project ID:** hekyovgnovhfhmkpfrna (DEV)
- **Design System:** V3 exists but needs complete rewrite as V4

### Current Situation
V1 refactoring is complete. The Design System exists in `lib/core/design/` but the documentation was deleted during cleanup. We need a **complete, authoritative guide** that explains exactly how to build screens that match the reference designs. The goal is that any developer (human or AI) can create pixel-perfect screens by following this guide.

### What Has Been Done
- Design System tokens exist (`lynewed_colors.dart`, `lynewed_text_styles.dart`, `lynewed_spacing.dart`, `lynewed_borders.dart`)
- Reusable widgets exist (`LynewedSheet`, `LynewedButton`, `LynewedTextField`, `LynewedChip`, etc.)
- Reference screens are validated and working

### What Remains
- Analyze ALL reference screens in detail
- Document EXACT rules for every UI element
- Identify inconsistencies and propose fixes
- Create comprehensive DESIGN_SYSTEM.md guide
- Add missing widgets to `/core/design/widgets/` if needed

---

## 📁 KEY FILES TO READ FIRST

**MANDATORY - Read before any action:**
1. `docs/PROJECT.md` - Project state
2. `docs/PROJECT_TODO.md` - Task list

**Design System Code (ANALYZE COMPLETELY):**
```
lib/core/design/
├── design.dart                    # Barrel export
├── lynewed_colors.dart           # Color tokens
├── lynewed_text_styles.dart      # Typography tokens  
├── lynewed_spacing.dart          # Spacing tokens
├── lynewed_borders.dart          # Border radius utilities
├── lynewed_component_styles.dart # Component styles
├── lynewed_design_system.dart    # Main API
├── lynewed_app_theme.dart        # ThemeData
└── widgets/                      # Reusable widgets
    ├── lynewed_sheet.dart        # Base sheet
    ├── lynewed_button.dart       # Buttons
    ├── lynewed_text_field.dart   # Text inputs
    ├── lynewed_chip.dart         # Chips
    ├── lynewed_section_title.dart
    └── ... (all other widgets)
```

**REFERENCE SCREENS (ANALYZE IN DETAIL):**

### Sheets (Base Pattern)
1. `lib/features/map/presentation/sheets/wedding_create_sheet.dart` - **PRIMARY REFERENCE**
2. `lib/features/map/presentation/sheets/alert_create_sheet.dart` - **PRIMARY REFERENCE**
3. `lib/features/chat/presentation/sheets/report_user_sheet.dart` - **PRIMARY REFERENCE**
4. `lib/features/map/presentation/widgets/filter_sheet.dart` - Alternative header style (no divider)

### Pages
5. `lib/features/chat/presentation/pages/messages_page.dart` - **Page header reference (no navbar)**
6. `lib/pages/bride/feed_brides/feed_brides_widget.dart` - **Page with navbar**
7. Find and analyze `ProDetailsWidget` - **Header with blur image**

### Modals
8. Look for `more_vert` popup menu in ProDetails - **Modal reference**

---

## 🎯 TASKS TO COMPLETE

### Task 1: Deep Analysis of Reference Screens
**Priority:** 🔴 HIGH
**Estimated:** 2-3 hours

**Steps:**
1. Read EVERY reference file completely
2. Extract EXACT values for:
   - Padding (top, left, right, bottom for every element)
   - Font sizes and weights
   - Spacing between elements (inter-section, intra-section)
   - Border radius values
   - Icon sizes
   - Colors used
3. Document any inconsistencies between screens
4. Create a comparison table

**Acceptance criteria:**
- [ ] All 8+ reference screens analyzed
- [ ] Exact pixel values documented
- [ ] Inconsistencies listed with recommendations

### Task 2: Create DESIGN_SYSTEM.md Documentation
**Priority:** 🔴 HIGH  
**Estimated:** 3-4 hours

**Location:** `docs/App/DESIGN_SYSTEM.md`

**Structure:**
```markdown
# LYNEWED Design System V4

## Quick Start
- Import statement
- Basic usage example

## Typography
- Font family
- Size scale with usage context
- Weight rules (w400 default, w500 max, w600 only for CTAs)
- Semantic styles (sheetTitle, sectionTitle, bodyMedium, etc.)

## Colors
- Primary palette (black, white, grays)
- Semantic colors (error, success, warning)
- When to use color (almost never - only for states)

## Spacing
- Base grid (4px)
- Inter-section spacing: 30px
- Intra-section spacing: 10-12px
- Horizontal margins: 20px
- Exact padding for headers, content, buttons

## Components

### Sheets
- LynewedSheet usage
- Header structure (title left, close right)
- Divider placement
- Content padding
- Bottom action placement
- Code example

### Pages
- Header structure (back button, title, action)
- With/without navbar
- SafeArea handling
- Code example

### Modals
- When to use (small actions)
- Structure
- Code example

### Buttons
- LynewedButton types
- 48px height, 0 radius
- Full width vs inline
- Loading state

### Text Fields
- LynewedTextField usage
- Label placement
- Validation styling

### Chips
- LynewedChip usage
- 4px radius
- Selection state

### Lists
- Item structure
- Spacing between items
- Divider usage

## Patterns

### Form Sections
- Section title style
- Spacing rules
- Required field indicator (*)

### Error States
- Banner style
- Inline validation

### Loading States
- Button loading
- Page loading

## Do's and Don'ts
- ✅ Always use LynewedSheet for bottom sheets
- ✅ Always use 30px between sections
- ❌ Never use colors except for states
- ❌ Never use font weight > w500 except CTAs
```

**Acceptance criteria:**
- [ ] Complete documentation created
- [ ] Every rule has exact values
- [ ] Code examples for each component
- [ ] Do's and Don'ts section

### Task 3: Identify and Fix Inconsistencies
**Priority:** 🟡 MEDIUM
**Estimated:** 1-2 hours

**Steps:**
1. List all inconsistencies found in Task 1
2. Propose the "correct" value based on most common usage
3. Report to user for validation
4. Apply fixes if approved

**Acceptance criteria:**
- [ ] Inconsistencies documented
- [ ] Recommendations provided
- [ ] User validated fixes

### Task 4: Add Missing Widgets
**Priority:** 🟡 MEDIUM
**Estimated:** 1-2 hours

**Steps:**
1. Identify patterns that repeat but have no widget
2. Create new widgets in `lib/core/design/widgets/`
3. Export in `design.dart`
4. Document in DESIGN_SYSTEM.md

**Potential missing widgets:**
- `LynewedPageHeader` - Standard page header
- `LynewedFormSection` - Section with title and content
- `LynewedListItem` - Standard list item
- `LynewedModal` - Small modal wrapper

**Acceptance criteria:**
- [ ] Missing patterns identified
- [ ] New widgets created if needed
- [ ] Widgets exported and documented

---

## ⚠️ CRITICAL RULES

1. **Analyze Before Writing** - Read ALL reference files before documenting anything
2. **Exact Values Only** - No approximations. Document exact pixel values.
3. **Black & White** - No colors except for error/success/warning states
4. **Weight Limit** - Never use fontWeight > w500 except for button text
5. **30px Sections** - Always 30px between sections, 10-12px within sections
6. **20px Margins** - Horizontal padding is always 20px
7. **48px Buttons** - All buttons are 48px height, 0 radius
8. **24px Sheet Radius** - Top corners of sheets are 24px
9. **4px Item Radius** - Chips, cards, list items use 4px radius
10. **Use Existing Widgets** - Always use `LynewedSheet`, `LynewedButton`, etc.

---

## 🚫 PITFALLS TO AVOID

- **Don't guess values** - If unsure, read the code
- **Don't create new patterns** - Follow existing reference screens
- **Don't use FlutterFlowTheme** - Always use LynewedColors, LynewedTextStyles
- **Don't hardcode colors** - Use semantic color names
- **Don't skip the divider** - Sheets have a divider after header (except filter_sheet style)
- **Don't forget SafeArea** - Pages need proper safe area handling

---

## ✅ VALIDATION

When tasks are complete:
1. Documentation covers ALL components
2. Every rule has an exact value
3. Code examples compile and work
4. Reference screens match documented rules
5. User validates the final document

---

## 🚀 START HERE

1. **Read** `lib/core/design/` completely (all files)
2. **Read** all 8 reference screens listed above
3. **Create** a detailed analysis with exact values
4. **Present** findings and inconsistencies to user
5. **Write** DESIGN_SYSTEM.md after user validation
6. **Add** missing widgets if needed

**First action:** Read and analyze `lib/core/design/widgets/lynewed_sheet.dart` and `lib/features/map/presentation/sheets/wedding_create_sheet.dart` to understand the base sheet pattern.

---

## 📋 REFERENCE VALUES (From Analysis)

### Typography Hierarchy
| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| sheetTitle | 20px | w500 | Sheet/Page headers |
| sectionTitle | 16px | w500 | Form section titles |
| bodyLarge | 16px | w400 | Important body text |
| bodyMedium | 14px | w400 | Default text |
| bodySmall | 13px | w400 | Secondary text |
| labelSmall | 10px | w400 | Captions, hints |

### Spacing Rules
| Context | Value |
|---------|-------|
| Inter-section | 30px |
| Label to content | 10px |
| Items in section | 8-12px |
| Horizontal margin | 20px |
| Sheet header padding | `EdgeInsets.fromLTRB(20, 20, 20, 12)` |
| Sheet content padding | `EdgeInsets.symmetric(horizontal: 20, vertical: 16)` |

### Border Radius
| Element | Radius |
|---------|--------|
| Buttons | 0px |
| Sheets (top) | 24px |
| Chips/Cards/Items | 4px |
| Inputs | 4px |

### Heights
| Element | Height |
|---------|--------|
| Buttons | 48px |
| Inputs | 48px |
| Header action circle | 44px |

---

**Output:** Create `docs/App/DESIGN_SYSTEM.md` with complete, authoritative documentation.

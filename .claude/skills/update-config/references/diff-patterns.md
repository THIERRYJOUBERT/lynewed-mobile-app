# Diff Patterns for Update Config

> Patterns for detecting and handling file differences between local and template.

---

## File Classification Logic

### 1. NEW (File exists only in template)

```bash
# Detection
[ ! -f "$LOCAL_PATH" ] && [ -f "$TEMPLATE_PATH" ]
```

**Action**: Always add to local

---

### 2. IDENTICAL (Same content)

```bash
# Detection using checksum
LOCAL_HASH=$(md5 -q "$LOCAL_PATH" 2>/dev/null || md5sum "$LOCAL_PATH" | cut -d' ' -f1)
TEMPLATE_HASH=$(md5 -q "$TEMPLATE_PATH" 2>/dev/null || md5sum "$TEMPLATE_PATH" | cut -d' ' -f1)

[ "$LOCAL_HASH" = "$TEMPLATE_HASH" ]
```

**Action**: Skip (nothing to do)

---

### 3. MODIFIED_REMOTE (Local unchanged, template updated)

This requires knowing the "original" version. Options:

**Option A: Git-based detection**
```bash
# Check if local file matches last committed version
git diff --quiet HEAD -- "$LOCAL_PATH"
# Exit 0 = no changes, Exit 1 = changes
```

**Option B: Marker-based detection**
Store original checksums in `.claude/.template-checksums`:
```
.claude/skills/debug/SKILL.md:abc123
.claude/rules/core-rules.md:def456
```

Compare local checksum against stored original:
- If local == stored original: Local unchanged → safe to update
- If local != stored original: Local was modified

**Action**: Update local with template version

---

### 4. MODIFIED_LOCAL (Local changed, template same as original)

```bash
# Local differs from stored original
# Template matches stored original
```

**Action**: Skip (preserve local customization)

---

### 5. CONFLICT (Both local and template changed)

```bash
# Local differs from stored original
# Template differs from stored original
# Local differs from template
```

**Action**: Ask user how to resolve

---

## Protected Files (Never Update)

These files are always considered "local customizations":

```
CLAUDE.md                           # Project-specific
.claude/rules/project-preferences.md # User preferences
.claude/settings.local.json          # Local settings
.claude/settings.json                # If customized
```

---

## Checksum Storage

After first install or update, store checksums:

```bash
# Generate checksums file
find .claude -type f -name "*.md" -o -name "*.yaml" | while read file; do
    hash=$(md5 -q "$file" 2>/dev/null || md5sum "$file" | cut -d' ' -f1)
    echo "$file:$hash"
done > .claude/.template-checksums
```

This file should be:
- Created on install
- Updated after each `/update-config`
- NOT committed to git (add to .gitignore)

---

## Diff Display for Conflicts

Show meaningful diff for user decision:

```bash
# Show side-by-side diff (first 20 lines of changes)
diff -y --width=120 "$LOCAL_PATH" "$TEMPLATE_PATH" | head -40
```

Or summarize:
```bash
# Count changes
LOCAL_LINES=$(wc -l < "$LOCAL_PATH")
TEMPLATE_LINES=$(wc -l < "$TEMPLATE_PATH")
DIFF_LINES=$(diff "$LOCAL_PATH" "$TEMPLATE_PATH" | grep "^[<>]" | wc -l)

echo "Local: $LOCAL_LINES lines"
echo "Template: $TEMPLATE_LINES lines"
echo "Differences: $DIFF_LINES lines"
```

---

## Backup Strategy

Before overwriting any file:

```bash
BACKUP_DIR=".claude/.backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Preserve directory structure in backup
RELATIVE_PATH="${LOCAL_PATH#.claude/}"
mkdir -p "$BACKUP_DIR/$(dirname "$RELATIVE_PATH")"
cp "$LOCAL_PATH" "$BACKUP_DIR/$RELATIVE_PATH"
```

---

## Merge Strategies (Future Enhancement)

For text files, could attempt automatic merge:

```bash
# 3-way merge if we have original, local, and template
git merge-file -p "$LOCAL_PATH" "$ORIGINAL_PATH" "$TEMPLATE_PATH" > "$MERGED_PATH"

# Check for conflicts (<<<< markers)
if grep -q "^<<<<<<" "$MERGED_PATH"; then
    echo "Merge conflict - manual resolution needed"
else
    echo "Auto-merged successfully"
fi
```

---

## Example Workflow

```
1. Clone template to temp dir
2. Load .claude/.template-checksums (or create if missing)
3. For each file in template/.claude/:
   a. Get template hash
   b. Get local hash (if exists)
   c. Get original hash (from checksums file)
   d. Classify: NEW | IDENTICAL | MODIFIED_REMOTE | MODIFIED_LOCAL | CONFLICT
4. Present classification to user
5. Execute based on user choices
6. Update .claude/.template-checksums with new hashes
7. Clean up temp dir
```

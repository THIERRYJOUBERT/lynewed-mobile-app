---
description: Git Commit & Push to develop branch (SAFETY-FIRST - NO DELETION)
---

## 🚨 CRITICAL SAFETY WORKFLOW - READ EVERY TIME

### 📋 WHY THIS EXISTS
> **Incident**: `alert_create_sheet.dart` was permanently deleted by `git clean -fd` without backup.
> **Rule**: NEVER trust automated cleanup. ALWAYS verify what will be deleted.

### 🔒 GOLDEN SAFETY RULES
1. **NEVER USE `git clean`** - This command permanently deletes files without any recovery option.
2. **NEVER USE `git add .` WITHOUT REVIEW** - Always check `git status` first.
3. **ALWAYS VERIFY DELETIONS** - If you see files marked as "deleted" in `git status`, confirm you intended to delete them.
4. **BACKUP BEFORE MAJOR CHANGES** - Use `git stash` or create a backup branch.

---

## 🔄 COMPLETE SAFE COMMIT PROCESS

### STEP 0: PRE-COMMIT SAFETY CHECKLIST
**Answer these questions BEFORE proceeding:**
- [ ] Did you run `git status` and review EVERY line?
- [ ] Are there any files marked as "deleted" that you didn't expect?
- [ ] Are you about to run `git clean`? (IF YES, STOP!)
- [ ] Have you backed up important files you're modifying?

### STEP 1: CLEAN GHOST FILES (SAFE ONLY)
```bash
# ONLY remove known duplicate files ( NEVER use git clean )
find ios/Flutter -name "* *" -type f -delete
find . -maxdepth 1 -name ".flutter-plugins-dependencies *" -type f -delete
```

### STEP 2: SUPABASE SYNC ( MANUAL PROCESS )
**Problem**: Supabase CI checks if local migrations match remote database.
**Cause**: You made changes via Dashboard/MCP, but GitHub doesn't know.
**Solution**: Pull remote state to match.

```bash
# Attempt to sync ( database migrations )
# If this fails, it's OK - your app will still work
supabase db pull --schema-only
```

**If sync fails** ( the usual case ):
- Don't worry about the "Supabase Preview" check failure
- Your database is already up-to-date
- The check failure is just GitHub being confused

### STEP 3: DETAILED STATUS REVIEW
```bash
git status --porcelain
```
**Review EVERY line:**
- `M` = Modified ( OK to commit )
- `A` = Added ( OK to commit )
- `D` = DELETED ( ⚠️ DANGER - VERIFY! )
- `??` = Untracked ( Usually OK, but review )

### STEP 4: SELECTIVE STAGING ( the safe way )
```bash
# Add files ONE BY ONE or by type to avoid accidents
git add lib/           # Add all lib changes
git add docs/          # Add documentation
git add .gitignore     # Add gitignore changes

# NEVER do this without reviewing git status first:
# git add .            # ⚠️ DANGEROUS - can stage unwanted deletions
```

### STEP 5: FINAL VERIFICATION
```bash
git status --short
```
**Confirm:**
- No important files are marked for deletion
- Only intended changes are staged

### STEP 6: COMMIT WITH CLEAR MESSAGE
```bash
git commit -m "type(scope): brief description

Detailed explanation:
- What changed and why
- Impact on the application
- Any breaking changes

Files modified:
- lib/features/map/alert_create_sheet.dart: restored file
- docs/PROJECT.md: updated status
"
```

### STEP 7: PUSH TO DEVELOP
```bash
git push origin develop
```

---

## 🚨 EMERGENCY RECOVERY PROCEDURES

### If you accidentally deleted a file:
1. **IMMEDIATELY STOP** - Don't run any more git commands
2. **Check reflog**:
   ```bash
   git reflog --all --grep="deleted" --oneline
   ```
3. **Restore from reflog**:
   ```bash
   git checkout <commit_hash> -- path/to/deleted/file.dart
   ```
4. **Commit the restored file**:
   ```bash
   git add path/to/deleted/file.dart
   git commit -m "restore: accidentally deleted file"
   ```

### If you pushed the deletion:
1. **Find the last good commit**:
   ```bash
   git log --oneline --follow path/to/deleted/file.dart
   ```
2. **Create recovery branch**:
   ```bash
   git checkout -b recovery <good_commit_hash>
   git checkout recovery -- path/to/deleted/file.dart
   git checkout develop
   git merge recovery --no-ff
   git push origin develop
   ```

---

## ⚠️ COMMON DANGERS & SOLUTIONS

| Danger | What Happens | Safe Alternative |
|--------|--------------|------------------|
| `git clean -fd` | Deletes untracked files PERMANENTLY | `find . -name "*.tmp" -delete` ( specific only |
| `git add .` | Stages EVERYTHING including accidental deletions | `git add lib/ docs/` ( specific folders |
| `git reset --hard` | Loses staged changes | `git reset --soft` ( keeps changes staged |
| Ignoring `git status` | Misses accidental deletions | ALWAYS review `git status --porcelain` |

---

## 📝 SUPABASE SYNC EXPLAINED

### Why the "Supabase Preview" check fails:
1. You made schema changes via Dashboard/MCP
2. Supabase applied them to your database
3. GitHub sees these migrations in your database
4. But GitHub doesn't find the corresponding SQL files in your branch
5. GitHub thinks you're missing migrations and fails the check

### This is NOT a problem for your app because:
- Your database already has the changes
- Your Flutter code works with the updated schema
- The check failure is just a "documentation" mismatch

### To fix it ( manual process ):
1. Pull remote migrations: `supabase db pull`
2. If that fails, your app still works
3. The check failure can be ignored for now

---

## ✅ FINAL CHECKLIST BEFORE COMMIT

- [ ] Reviewed `git status --porcelain` line by line
- [ ] No unexpected `D` ( deleted file markers |
- [ ] Used `git add <specific>` instead of `git add .`
- [ ] Backed up any important changes
- [ ] Written clear commit message
- [ ] Ready to push to `develop`

**Remember**: It's better to commit slowly and safely than to lose hours of work to a single bad command.

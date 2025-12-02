---
description: Git Commit & Push to develop branch (CASCADE'S SAFE METHOD)
---

# 🚨 CASCADE'S SAFE COMMIT WORKFLOW

## 📋 WHY THIS WORKFLOW EXISTS
> **Incident**: `alert_create_sheet.dart` was permanently deleted by `git clean -fd` without backup.
> **Rule**: NEVER trust automated cleanup. ALWAYS verify what will be deleted.

## 🎯 OBJECTIVE
Create a **safe, automated commit process** that:
1. **NEVER deletes files accidentally**
2. **ALWAYS verifies changes before staging**
3. **Provides clear commit messages**
4. **Pushes safely to develop branch**

---

## 🤖 ASSISTANT PROMPT - COMPLETE IMPLEMENTATION

When user runs `/commit-github-develop`, execute this EXACT workflow:

### STEP 1: INITIAL STATUS CHECK
```bash
# First, check current state
git status --porcelain
```

**Analysis:**
- Look for `D` markers (deleted files) - these need special attention
- Count `M` (modified), `A` (added), `??` (untracked) files
- If any `D` files are found, STOP and ask user to confirm

### STEP 2: DETAILED STATUS REVIEW
```bash
# Get full status for analysis
git status
```

**Safety Checklist:**
- ✅ Are there any files marked as "deleted" that you didn't expect?
- ✅ Are there any `??` files that should be ignored (build artifacts, temp files)?
- ✅ Is this a normal commit or a refactor with intentional deletions?

### STEP 3: CLEAN GHOST FILES (SAFE ONLY)
```bash
# ONLY remove known duplicate/build files (NEVER use git clean)
find ios -maxdepth 1 -name "Podfile *" -type f -delete
find . -maxdepth 1 -name ".flutter-plugins-dependencies *" -type f -delete
find ios/Flutter -name "* *" -type f -delete 2>/dev/null || true
```

### STEP 4: SELECTIVE STAGING - THE SAFE WAY

**PATTERN 1: Normal commit (no deletions)**
```bash
# Stage by folder for safety
git add lib/           # All lib changes
git add docs/          # Documentation changes  
git add supabase/      # Database changes
git add .windsurf/     # Workflow changes
git add test/          # Test changes
```

**PATTERN 2: Refactor with intentional deletions**
```bash
# Stage everything BUT verify deletions first
git add -A
# Then show what will be deleted for confirmation
git status --short | grep "^D"
```

### STEP 5: FINAL VERIFICATION
```bash
# Check what will be committed
git status --short
```

**Confirm:**
- ✅ No unexpected `D` (deleted file markers)
- ✅ Only intended changes are staged
- ✅ Build artifacts are not included

### STEP 6: COMMIT WITH DETAILED MESSAGE

**Template for commit message:**
```bash
git commit -m "type(scope): brief description

Detailed explanation:
- What changed and why
- Impact on the application  
- Any breaking changes

Files added: X (Y Dart + Z Markdown + ...)
Files modified: N
Files deleted: M (if any, explain why)

Key features:
- ✅ Feature 1 implemented
- ✅ Feature 2 added
- ✅ Integration with module X

Architecture:
- Clean Architecture maintained
- Design System integration
- Performance considerations
"
```

**Commit Types:**
- `feat`: New feature
- `fix`: Bug fix  
- `refactor`: Code refactoring (no functional changes)
- `docs`: Documentation only
- `style`: Code style changes (formatting, etc.)
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### STEP 7: PUSH TO DEVELOP
```bash
# Push to develop branch
git push origin develop
```

### STEP 8: FINAL VERIFICATION
```bash
# Confirm working tree is clean
git status
```

**Expected output:**
```
On branch develop
Your branch is up to date with 'origin/develop'.

nothing to commit, working tree clean
```

---

## 🚨 EMERGENCY HANDLING

### IF YOU SEE UNEXPECTED DELETIONS:
1. **STOP IMMEDIATELY** - Don't commit
2. **Ask user**: "I see files marked for deletion: [list]. Is this intentional?"
3. **If accidental**: Use `git restore <file>` to recover
4. **If intentional**: Proceed with staging

### IF COMMIT FAILS:
1. **Check error message** - Usually merge conflicts
2. **Pull latest changes**: `git pull origin develop`
3. **Resolve conflicts** if any
4. **Retry commit**

### IF PUSH FAILS:
1. **Check network** - Simple connectivity issue
2. **Force push only if necessary**: `git push --force-with-lease origin develop`
3. **Otherwise**: `git pull origin develop` then retry

---

## 📊 EXAMPLE EXECUTIONS

### Example 1: Normal Feature Commit
```
$ git status --porcelain
 M lib/features/chat/data/repositories/chat_repository_impl.dart
 M lib/features/chat/presentation/pages/chat_details_page.dart
 ?? docs/CHAT_PHASE4_MASTER_PROMPT.md

$ git add lib/ docs/

$ git status --short  
M lib/features/chat/data/repositories/chat_repository_impl.dart
M lib/features/chat/presentation/pages/chat_details_page.dart
A  docs/CHAT_PHASE4_MASTER_PROMPT.md

$ git commit -m "feat(chat): Phase 4 - Chat Details implementation

- Added ChatDetails page with realtime message updates
- Implemented message composer and list widgets
- Added contact request handling in chat
- Created comprehensive documentation

Files added: 1 (Markdown)
Files modified: 2"

$ git push origin develop
```

### Example 2: Refactor with Deletions
```
$ git status --porcelain
 D docs/CHAT_PHASE4_REALTIME_SPEC.md
 M lib/features/chat/README.md
 A docs/CHAT_PHASE4_MASTER_PROMPT.md

# Assistant should ask:
"I see docs/CHAT_PHASE4_REALTIME_SPEC.md will be deleted. Is this intentional?"

# After user confirmation:
$ git add -A

$ git status --short
A docs/CHAT_PHASE4_MASTER_PROMPT.md  
D docs/CHAT_PHASE4_REALTIME_SPEC.md
M lib/features/chat/README.md

$ git commit -m "refactor(chat): Consolidate Phase 4 documentation

- Replaced CHAT_PHASE4_REALTIME_SPEC.md with CHAT_PHASE4_MASTER_PROMPT.md
- Updated README.md with consolidated spec
- Centralized all Phase 4 implementation details

Files added: 1
Files modified: 1  
Files deleted: 1 (replaced with master prompt)"

$ git push origin develop
```

---

## ✅ SUCCESS CRITERIA

A successful commit workflow results in:
1. ✅ **No accidental file deletions**
2. ✅ **Clear, detailed commit message** 
3. ✅ **Working tree clean** after push
4. ✅ **All changes pushed to develop**
5. ✅ **Build artifacts excluded**

---

## 🔧 TROUBLESHOOTING

### Common Issues:
- **"Changes not staged for commit"**: Run `git add` again
- **"Nothing to commit"**: All changes already committed
- **"Failed to push"**: Check network or pull latest changes
- **"Merge conflicts"**: Pull and resolve before pushing

### Recovery Commands:
```bash
# Unstage all changes (safe)
git reset

# Restore specific file from last commit
git restore <file>

# See commit history
git log --oneline -10

# Undo last commit (keep changes)
git reset --soft HEAD~1
```

---

## 📝 NOTES FOR ASSISTANT

1. **ALWAYS run `git status --porcelain` first** - This is your safety net
2. **NEVER use `git clean`** - Permanent deletion risk
3. **NEVER use `git add .` without review** - Can stage accidental deletions
4. **ALWAYS explain what you're doing** - User should understand each step
5. **ALWAYS verify deletions are intentional** - Ask if unsure
6. **ALWAYS provide detailed commit messages** - Future you will thank you

**Remember**: It's better to commit slowly and safely than to lose hours of work to a single bad command.

---

## 🎉 FINAL RESULT

When executed correctly, this workflow provides:
- **Zero-risk commits** (no accidental deletions)
- **Clear documentation** (detailed commit messages)
- **Clean repository** (no build artifacts)
- **Traceable history** (structured commits)
- **Peace of mind** (safe, repeatable process)

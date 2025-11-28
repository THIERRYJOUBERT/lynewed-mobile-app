---
description: Git Commit & Push to develop branch
auto_execution_mode: 1
---

## Git Commit Workflow for LYNEWED Mobile App

### Objective
Commit and push changes to the `develop` branch of the `lynewed-mobile-app` repository.

### Process Steps

1. **Check Git Status**
   ```bash
   git status
   ```

2. **Sync Supabase Migrations** (CRITICAL - prevents migration conflicts)
   ```bash
   supabase migration list
   # If sync error appears, run:
   # supabase migration repair --status reverted <migration_id>
   # supabase migration repair --status applied <migration_id>
   ```

3. **Clean Temporary Files**
   ```bash
   # Preview what will be removed (safe dry-run)
   git clean -n
   # Remove untracked temporary files AND directories
   git clean -fd
   # Final verification - should show no untracked files
   git status --short
   ```

4. **Stage Relevant Files**
   - Add all relevant files: `git add .`
   - **Verify staging**: Run `git status` to confirm only intended files are staged
   - Exclude temporary files (.dart_tool/, build/, .flutter-plugins-dependencies, iOS/Android build artifacts)
   - **Check .gitignore effectiveness**: Ensure patterns below exist and work:
     ```
     .dart_tool*/
     .flutter-plugins-dependencies*
     build/
     android/build/
     ios/build/
     ios/Flutter/Flutter*.podspec
     ios/Flutter/Generated*.xcconfig
     ios/Flutter/flutter_export_environment*.sh
     .windsurf/
     ```

5. **Pre-commit Checklist**
   - Review `git status` output - confirm no unwanted files staged
   - Check commit message follows conventional format
   - Verify Supabase migrations are synced (no remote/local conflicts)
   - Ensure build artifacts and temporary files are excluded
   ```bash
   git commit -m "type: brief description
   
   Detailed explanation of changes:
   - What was modified
   - Why it was modified  
   - Impact on the application
   
   Files changed:
   - module/*: specific changes
   - docs/*: documentation updates"
   ```

4. **Push to develop Branch**
   ```bash
   git push origin develop
   ```

### Important Notes

- **Source of Truth**: Local project files are the primary source of truth
- **Supabase Changes**: If Supabase schema changes were made, ensure migrations are included but don't overwrite remote changes
- **File Management**: Always exclude build artifacts and temporary files
- **Branch Strategy**: Work on `develop` branch, never commit directly to `main`
- **Commit Messages**: Follow conventional commits format (feat:, fix:, docs:, etc.)

### Common Issues & Solutions

- **Temporary files included**: Use `git reset --soft HEAD~1` to undo, then restage properly
- **Missing .gitignore patterns**: Add patterns for `.dart_tool/`, `build/`, `.flutter-plugins-dependencies`
- **Supabase sync conflicts**: Review migration files and ensure they complement remote changes
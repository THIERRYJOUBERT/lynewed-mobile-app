# 🎯 MISSION: Fix Video Call Notifications & Prominent UI

## 👤 ASSISTANT SPECIALTY
You are a **Senior Flutter/Supabase Developer** expert in:
- Flutter mobile development (iOS/Android)
- Supabase backend architecture (database, auth, storage, edge functions)
- Real-time notifications and FCM push notifications
- Agora video SDK integration
- UI/UX for incoming call interfaces

Your approach: Analyze the notification flow, identify asymmetric issues, and implement both backend fixes and prominent UI overlays for incoming calls.

---

## 📚 CONTEXT

### Project State
- **App:** LYNEWED - Wedding professionals marketplace
- **Version:** v2.0.0
- **Branch:** develop
- **Supabase Project ID:** hekyovgnovhfhmkpfrna (DEV)

### Current Situation
Video call notifications work Pro→Bride but fail Bride→Pro. Pro users don't receive push notifications for incoming calls from brides, only see in-app bell notifications. Additionally, incoming calls lack prominent UI - they just redirect to call page without clear visual indication.

### What Has Been Done
- Fixed unread message/notification counters with `notifyListeners()`
- Added iOS app badge support with `flutter_app_badger`
- Analyzed notification flow in `handle_notification_redirection.dart`
- Examined `notifications_outbox_drain` edge function

### What Remains
- Fix Bride→Pro push notification delivery
- Create prominent incoming call UI modal
- Implement missed call notification increment
- Add in-app call overlay when both users are active

---

## 📁 KEY FILES TO READ FIRST

**MANDATORY - Read before any action:**
1. `docs/PROJECT.md` - Project state
2. `docs/PROJECT_TODO.md` - Task list
3. `lib/custom_code/actions/handle_notification_redirection.dart` - Current notification handling
4. `supabase/functions/notifications_outbox_drain/index.ts` - Notification sending logic

**Module code:**
- `lib/custom_code/actions/init_push_notifications.dart` - FCM initialization
- `lib/backend/supabase/database/tables/device_tokens.dart` - Device token storage
- `lib/auth/supabase_auth/supabase_auth_manager.dart` - Auth flow

---

## 🎯 TASKS TO COMPLETE

### Task 1: Debug Bride→Pro Notification Issue
**Priority:** 🔴 HIGH
**Estimated:** 2 hours

**Steps:**
1. Check if Pro users register device tokens correctly (query device_tokens table)
2. Verify if `processVideoIncoming()` in edge function works asymmetrically
3. Test device token registration flow for Pro vs Bride accounts
4. Fix any role-based token registration issues

**Acceptance criteria:**
- [ ] Pro users receive push notifications when Bride calls
- [ ] Device tokens are properly registered for both roles
- [ ] Notification flow works bidirectionally

### Task 2: Create Prominent Incoming Call UI
**Priority:** 🔴 HIGH
**Estimated:** 3 hours

**Steps:**
1. Create `IncomingCallModal` widget with full-screen overlay
2. Implement global overlay system using `Overlay.of(context).insert()`
3. Add accept/decline buttons with caller info
4. Show caller avatar, name, and "Video Call" text
5. Auto-dismiss after 30 seconds with missed call notification

**Acceptance criteria:**
- [ ] Full-screen incoming call modal appears over any app content
- [ ] Shows caller photo, name, and video call indicator
- [ ] Accept button joins call, Decline button dismisses
- [ ] Auto-dismiss creates missed call notification

### Task 3: Missed Call Notification Increment
**Priority:** 🟡 MEDIUM
**Estimated:** 1 hour

**Steps:**
1. Add missed call notification type to system
2. Increment notification count when call is missed
3. Update `FFAppState` counters accordingly
4. Sync with iOS app badge

**Acceptance criteria:**
- [ ] Missed calls increment notification count
- [ ] iOS badge updates with missed calls
- [ ] In-app notifications show missed calls

### Task 4: In-App Call Status Indicator
**Priority:** 🟡 MEDIUM
**Estimated:** 2 hours

**Steps:**
1. Detect when both users are active in app
2. Show in-app banner instead of push notification
3. Add floating call button when session is active
4. Handle app state changes gracefully

**Acceptance criteria:**
- [ ] Active users see in-app call UI instead of push
- [ ] Floating call indicator appears during active sessions
- [ ] Smooth transitions between in-app and push states

---

## ⚠️ CRITICAL RULES

1. **Option B ALWAYS** - Never reuse FlutterFlow components
2. **Design System** - Use `lib/core/design/` for all UI
3. **Clean Architecture** - domain/data/presentation layers
4. **No print()** - Use SecureLogger for debugging
5. **Real-time First** - Use Supabase Realtime for call status updates
6. **Error Handling** - Graceful fallbacks for notification failures

---

## 🚫 PITFALLS TO AVOID

- **Assuming symmetric flow** - Bride→Pro and Pro→Bride may have different logic
- **Breaking existing notifications** - Test all notification types after changes
- **Missing device tokens** - Pro users may have different token registration
- **Overlay conflicts** - Ensure call modal doesn't conflict with other overlays
- **Memory leaks** - Properly dispose overlay and timers

---

## 🔍 DEBUGGING CHECKPOINTS

1. **Device Token Verification:**
   ```sql
   SELECT profile_id, token, platform, last_seen_at 
   FROM device_tokens 
   WHERE profile_id = '[pro_user_id]';
   ```

2. **Notification Outbox Check:**
   ```sql
   SELECT * FROM notifications_outbox 
   WHERE event_type = 'videoIncoming' 
   ORDER BY created_at DESC LIMIT 10;
   ```

3. **Push Notification Payload:**
   - Verify FCM payload contains all required fields
   - Check `isHighPriority: true` for video calls
   - Test TTL of 60 seconds for incoming calls

---

## ✅ VALIDATION

When tasks are complete:
1. Test Bride→Pro call notifications (both users logged in)
2. Test Pro→Bride call notifications (regression test)
3. Test incoming call modal appearance and behavior
4. Test missed call notification increment
5. Run `flutter analyze` - Should have no new errors
6. Update `docs/PROJECT.md` if needed
7. Use `/update-docs-after-work` to document progress

---

## 🚀 START HERE

1. Read the mandatory files listed above
2. Query device_tokens table to check Pro user token registration
3. Examine video session creation flow for role differences
4. Propose your debugging plan for the asymmetric notification issue
5. Wait for validation before implementing fixes

# InkWell Session Handoff - Build 64 (v4.26036.3)

**Date**: February 5, 2026  
**Mobile Build**: 4.26036.3 (64) - **SUBMITTED FOR APP STORE REVIEW** 🎉  
**Web**: Deployed to inkwelljournal.io

---

## ⚠️⚠️⚠️ CRITICAL: FIRESTORE DATA STRUCTURE WARNING ⚠️⚠️⚠️

> **BEFORE WRITING ANY NEW CLOUD FUNCTIONS OR ADDING DATA FIELDS:**
> 
> 1. **REVIEW the existing Firestore collections and field names**
> 2. **Check for existing fields** that might already serve your purpose
> 3. **Avoid creating redundant fields** (we've had issues with `manifest` vs `manifests`, date formats, etc.)
> 
> **Key Collections to Review:**
> - `users/{uid}` - User profile, settings, `userTags`, `connectedCoach`, etc.
> - `journalEntries/{entryId}` - Entries with `tags`, `coachReply`, `coachReplyAt`, etc.
> - `manifests/{userId}` - Single document per user (NOT a subcollection!)
> - `coaches/{coachId}` - Coach profiles
> 
> **Past Issues Caused by Not Checking:**
> - Mobile queried `manifest` collection instead of `manifests/{userId}` doc
> - Multiple date format inconsistencies (ISO strings vs Firestore Timestamps)
> - Redundant fields being created instead of using existing ones

---

## ✅ iOS BUILD IS NOW WORKING (Feb 5, 2026)

**CLI builds work!** Previous issues were resolved:
- Fresh `pod install` regenerates codegen files properly
- If build fails with missing `FBReactNativeSpec.h`, run: `cd ios && rm -rf Pods Podfile.lock && pod install`

---

## 🚀 Starter Prompt for New Copilot Session

Copy this to start a new conversation:

```
I'm working on InkWell, a journaling/wellness app.

**Monorepo**: `/Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo`
- `mobile_2/` - React Native 0.74.5 iOS app  
- `web/` - Firebase hosted web app (inkwelljournal.io)
- `shared/` - Cloud Functions backend (source of truth)

**Current Build**: 4.26036.3 (64) - Submitted for App Store Review!
**Web**: Live at inkwelljournal.io (Firebase project: inkwell-alpha)

**Tech Stack**: React Native 0.74.5, TypeScript, Hermes, Firebase (Auth/Firestore/Functions/Messaging), RevenueCat, Claude Haiku AI

**Bundle ID**: com.pegasusrealm.inkwellmobile | **Team ID**: GULD29SRW8

⚠️ IMPORTANT: Before adding new Firestore fields or functions, REVIEW existing data structure to avoid redundancies!

Please read HANDOFF-BUILD-42.md for full context.
```

---

## ✅ What Was Completed (Build 64 - February 5, 2026)

### 1. Manifest Data Fix - COMPLETE
- **Issue:** Mobile entries weren't linking manifest data properly
- **Root Cause:** JournalScreen.tsx queried `manifest` collection (wrong) instead of `manifests/{userId}` doc (correct)
- **Fix:** Changed from collection query with date filter to single document fetch

### 2. Past Entries Coach Reply Fix - COMPLETE
- **Issue:** Calendar didn't show purple date for coach replies, entries not visible initially
- **Root Cause:** Firestore cache returning stale data
- **Fix:** Added `{ source: 'server' }` to bypass cache, auto-select today when new coach replies exist

### 3. Insights Modal Padding - COMPLETE
- **Issue:** 7/30-day insights content was cut off at bottom
- **Fix:** Added `paddingBottom: spacing.xl` to scroll content

### 4. Dark Mode Text Colors - COMPLETE
- **Issue:** Coach name, input labels, picker items hard to read in dark mode
- **Fix:** Changed colors to `brandLight` (#B8E0EA) for labels, added `color` props to Picker items

---

## ✅ What Was Completed (Earlier Builds)

### Tag System (Free Feature) - COMPLETE
- **Web:** Full implementation with CSS, JS, autocomplete, tag management in Past Entries
- **Mobile:** Tag state, UI, and Firestore sync added to JournalScreen.tsx
- **Data Structure:** 
  - `users/{uid}.userTags` - array of user's tags (normalized lowercase)
  - `journalEntries/{entryId}.tags` - tags on each entry

### Export Data Fix - COMPLETE
- **Issue:** `data.createdAt?.toDate()` failed because createdAt can be ISO string OR Firestore Timestamp
- **Fix:** Added `safeToDate()` helper (web) and `safeToISOString()` helper (mobile)

### CORS Fix for Mobile - COMPLETE
- **Issue:** `setupHardenedCORS()` in Cloud Functions blocked mobile requests (no Origin header)
- **Fix:** Added check to allow requests with no origin (mobile/server-to-server)

### Insights URL Fix - COMPLETE
- **Issue:** Mobile used old Cloud Run URL format
- **Fix:** Updated to `https://us-central1-inkwell-alpha.cloudfunctions.net/generatePeriodInsights`

---

## 📁 Key Files Modified

### Mobile
| File | Changes |
|------|---------|
| `mobile_2/src/screens/JournalScreen.tsx` | Tag system, Voice module try/catch fix |
| `mobile_2/src/screens/SettingsScreen.tsx` | Export fix with safeToISOString helper |
| `mobile_2/src/screens/PastEntriesScreen.tsx` | Correct insights Cloud Function URL |
| `mobile_2/src/screens/ManifestScreen.tsx` | Progress bar min 5%, language updates |
| `mobile_2/src/components/WeeklyActivityDots.tsx` | Added marginBottom: 12 |
| `mobile_2/App.tsx` | Debug logging for splash, moved handleSplashFinish |

### Web
| File | Changes |
|------|---------|
| `web/public/app.html` | Tag system (~400 lines), export fixes, currentUser fix, safeToDate helper |

### Backend
| File | Changes |
|------|---------|
| `shared/functions/index.js` | CORS fix in setupHardenedCORS() - allow null origin |

---

## ⚠️ Known Issues / Notes

1. **iOS BUILD BROKEN** - See top of document. xcodebuild CLI archive fails. Xcode GUI may work.

2. **Push Notifications Code Ready** - AppDelegate.mm, notificationService.ts, SettingsScreen.tsx all updated with proper delegate methods and error handling. Just needs a working build to test on TestFlight.

3. **Splash Screen:** User reports not seeing splash on mobile - may be simulator/hot reload issue. Logic is correct (`showSplash=true` initially). Test on real device cold start.

4. **Voice Module:** Wrapped in try/catch due to NativeEventEmitter warning on iOS 26.1. Voice may need testing.

5. **React-perflogger/Fusebox Test File:** This is the ROOT CAUSE of build failures. The file `FuseboxTracerTest.cpp` should not be compiled in Release builds but is being included. Need to patch Podfile or podspec.

---

## 🛠 Quick Commands

```bash
# Build iOS for TestFlight
cd mobile_2/ios
rm -rf ./build/InkWell.xcarchive
xcodebuild -workspace InkWell.xcworkspace -scheme InkWell -configuration Release -archivePath ./build/InkWell.xcarchive archive
xcodebuild -exportArchive -archivePath ./build/InkWell.xcarchive -exportPath ./build/export -exportOptionsPlist exportOptions.plist

# Deploy web
cd web && firebase deploy --only hosting

# Deploy specific functions
cd shared && firebase deploy --only functions:functionName1,functions:functionName2

# Deploy all functions (takes longer)
cd shared && firebase deploy --only functions
```

---

## 🏗 Architecture Reference

- **Monorepo:** `/Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo`
- **Firebase Project:** `inkwell-alpha`
- **Production Domain:** `https://inkwelljournal.io`
- **Cloud Functions:** v2, Node.js 20, us-central1
- **iOS Version:** 4.26036.3 (Build 64) - **Submitted for App Store Review**
- **React Native:** 0.74.5

---

## 📋 Features Status

| Feature | Web | Mobile | Notes |
|---------|-----|--------|-------|
| Tag System | ✅ | ✅ | Free feature, autocomplete works |
| Export Data | ✅ | ✅ | Fixed date handling |
| Smart Search | ✅ | ✅ | CORS fixed |
| 7/30 Day Insights | ✅ | ✅ | CORS + URL fixed |
| Progress Bar | ✅ | ✅ | Min 5% fill |
| Weekly Dots | ✅ | ✅ | Padding added |
| Voice Recording | ✅ | ⚠️ | Wrapped in try/catch |
| Splash Screen | N/A | ⚠️ | Needs real device test |

---

*Build 64 (v4.26036.3) has been submitted for App Store review! 🚀*

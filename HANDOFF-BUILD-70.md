# InkWell — Build & Deploy Handoff

**Last Updated**: March 29, 2026  
**iOS Status**: ✅ STABLE — EAS pipeline working, RN 0.76.9 on Xcode 26.2  
**Android Status**: 🔜 NEXT — first-time build, not on Play Store yet  
**Last Build**: ✅ Build 80 (v26.087.1) — submitted to App Store Connect March 28, 2026  
**Next Build**: **81** | **Next Task**: Android EAS setup  
**Git Tag**: `build-80-v26.087.1` | **GitHub**: `https://github.com/PegasusRealm/inkwell-mobile.git`

---

## 🏁 New AI Session — Orientation

InkWell is a **journaling and wellness app** (React Native). Features: AI-assisted prompts, voice journaling (InkOutLoud), free-writing (InkBlot), manifestation/goals screen. Backend: Firebase. Monetization: RevenueCat (free + paid tiers).

**Monorepo layout:**
```
inkwell-monorepo/
  mobile_2/   ← React Native app (primary work location)
  web/        ← Firebase-hosted web app (inkwelljournal.io)
  shared/     ← Cloud Functions backend
```

**Build pipeline**: ALL iOS builds via EAS cloud (Xcode 26.2). Local Xcode 26.4 is NOT used — incompatible.  
**Next session**: Start Android EAS setup (see Android section below).

---

## 📐 Version Numbering System (ALWAYS FOLLOW THIS)

Format: `YY.JJJ.A`
- `YY` = 2-digit year (e.g., `26` for 2026)
- `JJJ` = 3-digit Julian day (day of year, zero-padded — e.g., March 28 = day 087)
- `A` = attempt number for that day (start at `1`, increment if you build again same day)

**Examples:**
- March 28, 2026, first build → `26.087.1`
- March 28, 2026, second build same day → `26.087.2`
- April 15, 2026, first build → `26.105.1`

**Julian day quick reference:** Jan 31 + Feb 28 + March(day) — add 1 for leap year Feb after Feb 28.

---

## 🔄 Pre-Build Checklist (AI: Follow This Autonomously Every Build)

**Step 1 — Calculate version string and build number:**
- Get today's Julian day from the date
- Version = `26.JJJ.A` (based on day + attempt)
- Build number = next integer after last build (currently: **81**)

**Step 2 — Update these 5 locations (all must match):**

| File | Field | Example Value |
|------|-------|---------------|
| `ios/InkWellMobile/Info.plist` | `CFBundleShortVersionString` | `26.087.1` |
| `ios/InkWellMobile/Info.plist` | `CFBundleVersion` | `80` |
| `ios/InkWell.xcodeproj/project.pbxproj` | `MARKETING_VERSION` (2 places: Debug + Release) | `26.087.1` |
| `ios/InkWell.xcodeproj/project.pbxproj` | `CURRENT_PROJECT_VERSION` (2 places: Debug + Release) | `80` |
| `src/screens/InfoScreen.tsx` | `BUILD_NUMBER` constant | `'80'` |

**Step 3 — Commit:**
```bash
git add -A
git commit -m "Build 81 (v26.JJJ.1) — [brief description of what changed]"
```

**Step 4 — Build and submit:**
```bash
eas build --platform ios --profile production --auto-submit
```

---

## ⚙️ EAS Configuration (eas.json)

Current pinned image: **`macos-sequoia-15.6-xcode-26.2`** (Xcode 26, iOS 26 SDK — required after April 28, 2026)

```json
{
  "cli": { "version": ">= 7.0.0", "appVersionSource": "local" },
  "build": {
    "production": {
      "ios": {
        "image": "macos-sequoia-15.6-xcode-26.2",
        "scheme": "InkWell",
        "buildConfiguration": "Release",
        "autoIncrement": false
      }
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "agrimm979@gmail.com",
        "appleTeamId": "GULD29SRW8",
        "language": "en-US"
      }
    }
  }
}
```

**When Apple raises SDK requirements again:** Update `image` in `eas.json` only. Check available images at https://docs.expo.dev/build-reference/infrastructure/

**EAS Project:** `inkwell` (ID: `3ee4a91f-64ec-4bf4-a72a-44514b1d0c3a`) — PegasusRealm account  
**App Store Connect App ID:** `6755095548`  
**API Key:** Managed by EAS (Key ID: `7JZRN8SA94`)

---

## 🚧 Current Work: React Native Upgrade (0.74.7 → 0.76.9) — ✅ COMPLETE

**Why:** RN 0.74.7 cannot compile with Xcode 26. RN 0.76.9 has official Xcode 26 support.  
**Completed**: March 28, 2026 — Build 80 successfully submitted to App Store Connect.  
**Git commits for this work:**
- `d670ae0` — EAS build infrastructure setup
- `2d5461d` — RN 0.74.7 → 0.76.9 upgrade, React 18.3.1, screens 4.x
- `adf8cca` — Pin react-native-screens to 4.3.0 (codegen fix)
- `54034d1` — Remove stale Podfile.lock from git
- `cbd8578` — Suppress deprecated-declarations warnings in Podfile
- `db8107a` — Bump iOS deployment target 15.1 → 16.0
- `8d2a46b` — Force IPHONEOS_DEPLOYMENT_TARGET=16.0 on all pods ← final fix
- `build-80-v26.087.1` — git tag on working state

---

## ✅ RESOLVED: Xcode 26 Build Issues (March 28, 2026)

All Xcode 26 + RN 0.76.9 issues have been resolved. EAS is the permanent build pipeline.

### Root Causes Found & Fixed:
1. **react-native-screens 4.24+ codegen crash** → pinned to 4.3.0
2. **Stale Podfile.lock (fmt version mismatch)** → removed from git, added to .gitignore
3. **Xcode 26 deprecated-as-errors** → `GCC_TREAT_WARNINGS_AS_ERRORS=NO` in Podfile post_install
4. **swiftCompatibility56 missing linker symbol** → bumped iOS deployment target to 16.0 for app AND all pods

### Required Podfile post_install block:
```ruby
installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    config.build_settings['GCC_TREAT_WARNINGS_AS_ERRORS'] = 'NO'
    config.build_settings['CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS'] = 'NO'
    config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    config.build_settings['WARNING_CFLAGS'] = '$(inherited) -Wno-deprecated-declarations'
    config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = 'YES'
  end
end
```



---

## 🏗 Environment (As of March 28, 2026)

| Item | Value |
|------|-------|
| macOS | 26.x |
| Xcode (local) | 26.4 — NOT used for builds, EAS only |
| Xcode (EAS) | 26.2 via `macos-sequoia-15.6-xcode-26.2` |
| iOS SDK (EAS) | 26.2 |
| iOS Min Deployment | **16.0** (app + all pods) |
| React Native | **0.76.9** |
| React | **18.3.1** |
| Hermes | Enabled |
| New Architecture | **Disabled** (Podfile + gradle.properties) |
| react-native-screens | **4.3.0** (pinned — 4.4+ breaks RN 0.76 codegen) |
| CocoaPods | ~147 total pods |
| Firebase | Auth, Firestore, Storage, Messaging |
| RevenueCat | react-native-purchases |
| Team ID | GULD29SRW8 |
| Bundle ID | com.pegasusrealm.inkwellmobile |
| Last Working Version | 26.087.1 |
| Last Working Build | **80** |
| Stable Git Tag | `build-80-v26.087.1` |
| Monorepo | `/Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo` |
| GitHub | `https://github.com/PegasusRealm/inkwell-mobile.git` |
| Firebase Project | inkwell-alpha (849610731668) |
| Web Domain | https://inkwelljournal.io |

---

## 📋 Build History

| Build | Date | Version | Status |
|-------|------|---------|--------|
| 77 | March 2026 | — | Live on App Store (Apple Sign-In fix) |
| 78 | March 13, 2026 | 26.072.1 | Live on App Store (Google Sign-In fix) |
| 79 | March 26, 2026 | — | Consumed — rejected by Apple (iOS 18.2 SDK, required iOS 26) |
| 80 | March 28, 2026 | 26.087.1 | ✅ Submitted to App Store Connect — EAS + RN 0.76.9 |

---

## 📁 Historical Context (iPad Fixes - Build 75)

<details>
<summary>Click to expand iPad fix details</summary>

### Why Build 75 Was Created — Apple Rejection

Apple rejected Build 70 with:

> **Guideline 2.1 - Performance - App Completeness**
> We found that one or more buttons in your app don't lead to the corresponding feature.
> We experienced this issue on iPad running iPadOS 18.3.1.

The root cause: **ActionSheetIOS crashes on iPad** because it requires a `sourceView`/`sourceRect` anchor that we weren't providing.

### iPad Fix Summary

Created `mobile_2/src/utils/iPad.ts` with:
- `isIPad()` — checks `Platform.isPad`
- `showActionSheet(title, options, cancelIndex, onSelect)` — uses `Alert.alert` on iPad instead of `ActionSheetIOS`
- `iPadContentStyle(screenWidth)` — returns `{maxWidth, alignSelf:'center', width:'100%'}`

Modified 7 screens and 4 components to use these utilities.

</details>

---

## 🤖 Android Build — Next Up

**Status**: Not yet attempted. First-time Android submission.

**Confirmed:**
- NOT on Google Play Store yet — this is a first-time submission
- No existing signing keystore — EAS will generate and manage one
- Google Developer account exists but untouched for this app

**Before starting, confirm with user:**
- [ ] Google Play Console — is the app listing already created, or do we create it?
- [ ] Android bundle ID (expected: `com.pegasusrealm.inkwellmobile` — confirm matches `android/app/build.gradle`)
- [ ] Google Play service account JSON for EAS Submit (needed for auto-submit)

**Current android/ state:**
- `android/gradle.properties` → `newArchEnabled=false`, `hermesEnabled=true`
- `android/app/google-services.json` → present
- `versionCode` and `versionName` → stale, need to align with version system

**Android EAS profile to add to `eas.json`:**
```json
"android": {
  "image": "latest",
  "buildType": "app-bundle",
  "gradleCommand": ":app:bundleRelease"
}
```

**EAS keystore:** Run `eas credentials` to generate and store Android keystore on EAS servers. Never lose this — it cannot be regenerated and is required for all future updates.

---

## 🐛 Known Gotchas & Tech Debt

| Issue | Detail |
|-------|--------|
| `@react-native-voice/voice` | Uses iOS 12 deprecated APIs — functional with warning suppression in Podfile |
| `react-native-screens` | Pinned to `4.3.0` — do NOT upgrade until RN 0.77+ |
| New Architecture | Disabled — voice and blob-util don't support it yet |
| `Podfile.lock` | Not in git — EAS resolves fresh every build |
| Local Xcode 26.4 | Cannot build locally — all builds via EAS |
| Google Sign-In | `webClientId` must be from Firebase project `849610731668`, not `824582728030` |
| Apple Sign-In on iPad | Use `showActionSheet()` from `src/utils/iPad.ts`, never `ActionSheetIOS` directly |

---

## 📁 Historical Reference

<details>
<summary>iOS Xcode 26 fix history (March 28, 2026 — Build 80)</summary>

**Why EAS was adopted:** Local Xcode 26.4 is incompatible with RN 0.74.7 (Folly C++17, fmt consteval, linker errors). After 16+ failed attempts, EAS cloud builds on Xcode 26.2 became the permanent pipeline.

**Issues hit during Build 80 (in order):**
1. `react-native-screens 4.24+` codegen crash → pinned to 4.3.0
2. Stale `Podfile.lock` fmt mismatch → removed from git
3. Xcode 26 deprecated-as-errors on voice library → `GCC_TREAT_WARNINGS_AS_ERRORS=NO`
4. `swiftCompatibility56` linker error (Firebase/RevenueCat Swift) → `IPHONEOS_DEPLOYMENT_TARGET=16.0` on all pods

**Key git commits:** `d670ae0` EAS setup → `2d5461d` RN upgrade → `8d2a46b` final fix  
**Tag:** `build-80-v26.087.1`

</details>

<details>
<summary>iPad compatibility fixes (Builds 75–78)</summary>

Apple rejected Build 70 (Guideline 2.1 — buttons non-functional on iPad). `ActionSheetIOS` crashes on iPad without `sourceView`.

**Fix:** `src/utils/iPad.ts` — `showActionSheet()` uses `Alert.alert` on iPad, `iPadContentStyle()` for layout, `isIPad()` util. Applied to 7 screens, 4 components, navigation.

</details>

---

*Last Updated: March 29, 2026*

# InkWell Code Review - January 15, 2026

A comprehensive review of the InkWell monorepo covering both web and mobile (React Native) implementations.

---

## 🔴 CRITICAL ISSUES

### 1. ~~Firestore Rules Out of Sync (`shared/` vs `web/`)~~ ✅ FIXED
**Status: RESOLVED**  
The `shared/firestore.rules` and `web/firestore.rules` are now synced.

---

### 2. ~~Open Firestore Read Rule for `practitionerInvitations`~~ ✅ FIXED
**Status: RESOLVED**  
Created a `validateInvitation` Cloud Function that securely validates invitation tokens server-side. Direct Firestore reads are now restricted to invitation owners only. The practitioner-register.html page now uses the Cloud Function instead of direct Firestore access.

---

### 3. Inconsistent Firebase Storage Bucket Configuration
**Severity: MEDIUM**  
**Files:** Multiple web HTML files

Different storage bucket formats are used across the codebase:
- `inkwell-alpha.appspot.com` (most files)
- `inkwell-alpha.firebasestorage.app` (practitioner-register.html)

**Affected files:**
- [web/public/practitioner-register.html#L243](web/public/practitioner-register.html#L243) - Uses `.firebasestorage.app`
- All other files use `.appspot.com`

**Recommendation:** Standardize to one format (`.appspot.com` is the legacy format, `.firebasestorage.app` is the new format). Both should work but consistency prevents confusion.

---

### 4. Inconsistent `authDomain` Configuration
**Severity: MEDIUM**  
**Files:** Web HTML files

Different `authDomain` values are used:
- `inkwell-alpha.firebaseapp.com` (most files)
- `www.inkwelljournal.io` (admin-enhanced.html)

**Affected file:**
- [web/public/admin-enhanced.html#L901](web/public/admin-enhanced.html#L901) - Uses `www.inkwelljournal.io`

**Recommendation:** Ensure `www.inkwelljournal.io` is properly configured in Firebase Auth as an authorized domain, or standardize to `inkwell-alpha.firebaseapp.com`.

---

## 🟡 POTENTIAL ISSUES

### 5. Hardcoded API Keys in Mobile Source Code
**Severity: LOW-MEDIUM** (These are client-side keys designed to be public, but worth noting)  
**Files:** [mobile_2/src/services/SubscriptionService.ts#L22](mobile_2/src/services/SubscriptionService.ts#L22)

```typescript
const REVENUECAT_API_KEY = 'appl_MgoxKdevXxWONmSBnChHrgObCqn';
```

The RevenueCat public API key is hardcoded. While this is a public key by design, consider using environment variables for easier key rotation.

**Files with hardcoded credentials:**
- [mobile_2/src/screens/LoginScreen.tsx#L49-L51](mobile_2/src/screens/LoginScreen.tsx#L49-L51) - Google Sign-In client IDs
- [mobile_2/src/services/sophyApi.ts#L10](mobile_2/src/services/sophyApi.ts#L10) - Cloud Functions URL

---

### 6. Debug Logging in Production Code
**Severity: LOW**  
**Files:** Multiple

Extensive console logging is present throughout the codebase:
- FCM tokens logged: [mobile_2/src/services/notificationService.ts#L23](mobile_2/src/services/notificationService.ts#L23)
- RevenueCat DEBUG level: [mobile_2/src/services/SubscriptionService.ts#L66](mobile_2/src/services/SubscriptionService.ts#L66)
- ID tokens partially logged: [mobile_2/src/screens/LoginScreen.tsx#L76](mobile_2/src/screens/LoginScreen.tsx#L76)

**Recommendation:** Consider implementing a logging utility that respects `__DEV__` flag or environment configuration.

---

### 7. Outdated TODO Comments
**Severity: LOW**  
**File:** [mobile_2/src/screens/LoginScreen.tsx#L387-L388](mobile_2/src/screens/LoginScreen.tsx#L387-L388)

```typescript
// TODO: Add Apple Sign In when @invertase/react-native-apple-authentication is installed
// TODO: Add Google Sign In when @react-native-google-signin/google-signin is installed
```

These TODO comments are outdated - both Apple and Google Sign-In are already implemented above in the same file.

---

### 8. Google Sign-In Inconsistent User Profile Handling
**Severity: MEDIUM**  
**Files:** [mobile_2/src/screens/LoginScreen.tsx#L87-L114](mobile_2/src/screens/LoginScreen.tsx#L87-L114)

Google Sign-In uses `{ merge: true }` which **always overwrites** user data on every login, while Apple Sign-In only creates data if the user document doesn't exist.

```typescript
// Google - overwrites every time
await firestore().collection('users').doc(userCredential.user.uid).set({...}, { merge: true });

// Apple - only creates if not exists
const userDoc = await firestore().collection('users').doc(userCredential.user.uid).get();
if (!userDoc.exists) { ... }
```

**Potential issue:** Google Sign-In could reset user preferences, subscription data, or other fields on every login if not carefully managed.

---

### 9. Weak Invitation Token Generation
**Severity: LOW-MEDIUM**  
**File:** [shared/functions/index.js#L2158](shared/functions/index.js#L2158)

```javascript
const invitationToken = Math.random().toString(36).substring(2, 15) + 
                       Math.random().toString(36).substring(2, 15);
```

Using `Math.random()` for security tokens is not cryptographically secure.

**Recommendation:** Use `crypto.randomBytes()` or `crypto.randomUUID()` for token generation.

---

### 10. Missing CORS Origin for Mobile App
**Severity: MEDIUM**  
**File:** [shared/functions/index.js#L79-L87](shared/functions/index.js#L79-L87)

```javascript
const ALLOWED_ORIGINS = [
  'http://localhost:5002', 
  'http://localhost:5000',
  'http://127.0.0.1:5002',
  'http://127.0.0.1:5000',
  'https://inkwell-alpha.web.app',
  'https://inkwell-alpha.firebaseapp.com',
  'https://inkwelljournal.io',
  'https://www.inkwelljournal.io'
];
```

Mobile app requests (React Native) don't use traditional CORS but the hardened CORS check could cause issues. The mobile app calls cloud functions with Bearer tokens so it should work, but ensure the `corsHandler` with `origin: true` is used for mobile-compatible endpoints.

---

### 11. Deprecated Packages in Mobile
**Severity: LOW**  
**File:** [mobile_2/package-lock.json](mobile_2/package-lock.json)

Multiple deprecated packages detected:
- `react-native-audio-recorder-player` - Package deprecated, suggests using `react-native-nitro-sound`
- Various Babel proposal plugins now merged into transforms
- ESLint v8 (use v9+ instead)
- `glob` versions prior to v9
- `inflight` - leaks memory, unsupported

**Recommendation:** Run `npm audit` and update packages where possible.

---

### 12. Paywall Feature Disabled
**Severity: INFORMATIONAL**  
**File:** [web/public/subscription-config.js#L8](web/public/subscription-config.js#L8)

```javascript
PAYWALL_ENABLED: false,
```

The paywall is currently disabled globally. Ensure this is intentional before going to production.

---

## 🟢 BEST PRACTICES OBSERVED

1. ✅ **Secret Management** - Firebase defineSecret() properly used for API keys (SendGrid, Stripe, Twilio, Anthropic, OpenAI)
2. ✅ **Retry Logic** - Robust retry with exponential backoff implemented in Cloud Functions
3. ✅ **User-Friendly Error Messages** - Error mapping function translates technical errors to user-friendly messages
4. ✅ **Firestore Security Rules** - Generally well-structured with proper role checking (coach, admin, journaler)
5. ✅ **Theme System** - Consistent theming implementation in mobile app with dark mode support
6. ✅ **Subscription Gating** - Feature gating properly implemented in mobile with PaywallModal
7. ✅ **AI Usage Limits** - Daily AI call limits for free users implemented with local + Firestore tracking

---

## 📋 RECOMMENDED ACTIONS

### High Priority
1. [ ] Sync `shared/firestore.rules` with `web/firestore.rules` or create symlink
2. [ ] Review `practitionerInvitations` open read rule for potential data exposure
3. [ ] Standardize Firebase storage bucket configuration across all files

### Medium Priority
4. [ ] Replace `Math.random()` token generation with `crypto.randomUUID()`
5. [ ] Fix Google Sign-In to check for existing user before overwriting data
6. [ ] Standardize `authDomain` configuration
7. [ ] Add environment-aware logging utility

### Low Priority
8. [ ] Remove outdated TODO comments in LoginScreen.tsx
9. [ ] Update deprecated npm packages
10. [ ] Consider moving hardcoded API keys to config files

---

## 📊 FILE SUMMARY

| Area | Files Reviewed | Critical Issues | Warnings |
|------|---------------|-----------------|----------|
| Firestore Rules | 2 | 1 | 1 |
| Cloud Functions | 1 | 0 | 2 |
| Mobile Screens | 6 | 0 | 3 |
| Mobile Services | 4 | 0 | 2 |
| Web Config | 7 | 0 | 2 |
| **Total** | **20+** | **1** | **10** |

---

## 🔍 QUESTIONS FOR DEVELOPER

1. ~~**Firestore Rules Deployment:** Which directory (`shared/` or `web/`) is used for production deployments? Should they be symlinked?~~ ✅ RESOLVED - Rules synced to both locations

2. ~~**Practitioner Invitations:** Is the public read access intentional? Are there concerns about exposing practitioner emails?~~ ✅ RESOLVED - validateInvitation Cloud Function added

3. **Mobile Bundle ID:** Docs mention `com.pegasusrealm.inkwell` - is this correct for production?

4. **Beta Code:** Users are tagged with `special_code: 'beta'` - will sunset end of January 2026 per developer

5. ~~**SMS Features:** SMS appears to be a Plus feature - is this enforced server-side?~~ ✅ RESOLVED - Subscription validation added to scheduledDailyPrompts (allows Plus, Connect, and beta testers)

---

## 📝 FIXES APPLIED (January 15, 2026)

1. **Created `validateInvitation` Cloud Function** - Securely validates invitation tokens server-side
2. **Updated `firestore.rules`** - Restricted practitionerInvitations reads to owners only
3. **Updated `practitioner-register.html`** - Now uses Cloud Function instead of direct Firestore reads
4. **Added subscription check to SMS functions** - Only Plus/Connect users (and beta testers) receive SMS prompts
5. **Synced firestore.rules** - Copied web/firestore.rules to shared/firestore.rules

**Deployment Required:**
```bash
# Deploy Cloud Functions
cd /Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo/shared
firebase deploy --only functions

# Deploy Firestore Rules
firebase deploy --only firestore:rules

# Deploy web hosting (for practitioner-register.html)
cd /Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo/web
firebase deploy --only hosting
```

---

*Review conducted on January 15, 2026*
*Reviewer: GitHub Copilot (Claude Opus 4.5)*

# InkWell Session Handoff - Build 70

**Date**: February 7, 2026  
**Mobile Build**: Build 70 - **UPLOADED TO APP STORE CONNECT** 🎉  
**Web**: Live at inkwelljournal.io with full paywall

---

## 🚀 Starter Prompt for New Copilot Session

Copy this to start a new conversation:

```
I'm working on InkWell, a journaling/wellness app.

**Monorepo**: `/Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo`
- `mobile_2/` - React Native 0.74.5 iOS app  
- `web/` - Firebase hosted web app (inkwelljournal.io)
- `shared/` - Cloud Functions backend (source of truth)

**Current State**: Build 70 uploaded to App Store Connect - ready to submit for review
**Web**: Live at inkwelljournal.io with FULL PAYWALL (Firebase project: inkwell-alpha)

**Tech Stack**: React Native 0.74.5, TypeScript, Hermes, Firebase (Auth/Firestore/Functions/Messaging), RevenueCat (mobile IAP), Stripe (web payments), Claude Haiku AI

**Bundle ID**: com.pegasusrealm.inkwellmobile | **Team ID**: GULD29SRW8

**Subscription Tiers**:
- **Free**: Basic journaling, 3 Sophy questions/day, WISH affirmations
- **Plus** ($6.99/mo or $69.99/yr): Unlimited Sophy, file uploads, insights, export, SMS
- **Connect** ($29.99/mo): Plus features + coach connection (4 interactions/month)

⚠️ IMPORTANT: Before adding new Firestore fields or functions, REVIEW existing data structure!

Please read HANDOFF-BUILD-43.md for full context.
```

---

## ✅ What Was Completed (February 7, 2026)

### 1. Complete Web Paywall Implementation - DONE
- **Scope**: Web app had NO paywall - all features exposed to free users
- **Fixed**: Every paid feature now properly gated with upgrade badges
- **Tiers enforced**: 
  - Sophy: Free with 3/day limit, Plus/Connect unlimited
  - File Uploads: Plus/Connect only
  - Period Insights (7/30 day): Plus/Connect only
  - Smart Search: Plus/Connect only  
  - Data Export: Plus/Connect only
  - SMS Notifications: Plus/Connect only
  - Coach Features: Connect only
  - InkOutLoud (audio): Plus/Connect only

### 2. Stripe Integration Fixes - DONE
- **Issue**: Webhook wasn't matching price IDs (hardcoded wrong IDs)
- **Fix**: Changed to `priceId.includes('price_1SeQaJIu1E0bDEgZ')` pattern matching
- **Price IDs**:
  - Plus Monthly: `price_1SeQaJIu1E0bDEgZq6V8lATE`
  - Plus Annual: `price_1SyMozIu1E0bDEgZNZ8zoJt2`
  - Connect: `price_1SeQcGIu1E0bDEgZQWWqkrjK`

### 3. Subscription Cancellation Flow - FIXED
- **Issue**: Canceling subscription immediately revoked access instead of waiting until period end
- **Root Cause**: Webhook set `subscriptionTier: 'free'` on `customer.subscription.updated` event
- **Fix**: 
  - Check `subscription.cancel_at_period_end` flag
  - Store `subscriptionCancelAtPeriodEnd: true` and `subscriptionAccessEndsAt` 
  - Only downgrade tier on `customer.subscription.deleted` (when period actually ends)
- **Deployed**: `firebase deploy --only functions:handleStripeWebhook`

### 4. Billing Portal - DONE
- Users can manage subscriptions via "Manage Subscription" button
- Opens Stripe Customer Portal for cancellation/plan changes
- Shows in Settings section when user has active subscription

### 5. Coach Features (Web) - DONE
- **Coach Selection**: Dropdown to pick from available coaches
- **30-Day Switch Limit**: Can only change coach once per 30 days (matches mobile)
- **Interaction Tracking**: Shows "1 of 4" when sending entry to coach
- **Coach Disconnect**: Working disconnect button with confirmation
- **Firestore Rules**: Added `allow list` permission for coach queries

### 6. OAuth User Creation - FIXED
- New OAuth users (Google/Apple) now correctly set `userRole: 'journaler'`
- Was setting `accountType: 'journaler'` (wrong field name)

### 7. UI/UX Fixes - DONE
- Fixed upgrade badges with proper onclick handlers
- Consolidated duplicate pricing modal code into `subscription-utils.js`
- Fixed subscription modal X button z-index
- Tier-aware welcome messages ("Welcome to Plus!" vs "Welcome to Connect!")

---

## 📁 Key Files Modified

### Web
| File | Changes |
|------|---------|
| `web/public/app.html` | Full paywall gating, coach features, billing portal button, 30-day switch limit |
| `web/public/subscription-utils.js` | Consolidated modal code, tier-aware welcomes, billing portal function |
| `web/firestore.rules` | Added `allow list` for coach queries |

### Backend (shared)
| File | Changes |
|------|---------|
| `shared/functions/index.js` | Fixed webhook price ID matching, cancellation flow, billing portal endpoint |
| `shared/functions/restore-tier.js` | Utility script to restore user tiers |

### Mobile
| File | Changes |
|------|---------|
| `mobile_2/src/screens/LoginScreen.tsx` | Apple Sign-In, OAuth welcome modal |
| `mobile_2/src/services/SubscriptionService.ts` | Tier checking improvements |

---

## 🔧 Build Commands

### iOS Build for TestFlight
```bash
cd /Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo/mobile_2/ios

# Clean and reinstall pods if needed
rm -rf Pods Podfile.lock && pod install

# Archive
xcodebuild -workspace InkWell.xcworkspace -scheme InkWell -configuration Release -archivePath ./build/InkWell.xcarchive archive

# Export IPA
xcodebuild -exportArchive -archivePath ./build/InkWell.xcarchive -exportPath ./build/export -exportOptionsPlist exportOptions.plist

# Upload to App Store Connect
xcrun altool --upload-app -f ./build/export/InkWell.ipa -t ios -u YOUR_APPLE_ID -p @keychain:AC_PASSWORD
```

### Web Deploy
```bash
cd /Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo/web
firebase deploy --only hosting
```

### Functions Deploy
```bash
cd /Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo/shared
firebase deploy --only functions:handleStripeWebhook
firebase deploy --only functions  # all functions
```

---

## ⚠️ Important Notes

### Stripe Webhook URL
```
https://us-central1-inkwell-alpha.cloudfunctions.net/handleStripeWebhook
```
Events to handle: `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`

### User Tier Restore Script
If a user's tier gets incorrectly set, use:
```bash
cd /Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo/shared/functions
# Edit restore-tier.js with correct UID
node restore-tier.js
```

### Firestore User Fields (Subscription Related)
```
subscriptionTier: 'free' | 'plus' | 'connect'
stripeCustomerId: string
stripeSubscriptionId: string  
subscriptionPeriodEnd: Timestamp
subscriptionCancelAtPeriodEnd: boolean (new)
subscriptionAccessEndsAt: Timestamp (new)
```

---

## 🏗 Architecture Reference

- **Monorepo:** `/Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo`
- **Firebase Project:** `inkwell-alpha`
- **Production Domain:** `https://inkwelljournal.io`
- **Cloud Functions:** v2, Node.js 20, us-central1
- **React Native:** 0.74.5

---

## 📋 Features Status

| Feature | Web | Mobile | Tier |
|---------|-----|--------|------|
| Basic Journaling | ✅ | ✅ | Free |
| WISH Affirmations | ✅ | ✅ | Free |
| Sophy (3/day) | ✅ | ✅ | Free |
| Sophy (unlimited) | ✅ | ✅ | Plus+ |
| File Uploads | ✅ | ✅ | Plus+ |
| Period Insights | ✅ | ✅ | Plus+ |
| Smart Search | ✅ | ✅ | Plus+ |
| Data Export | ✅ | ✅ | Plus+ |
| SMS Notifications | ✅ | ✅ | Plus+ |
| InkOutLoud Audio | ✅ | ✅ | Plus+ |
| Coach Connection | ✅ | ✅ | Connect |
| Billing Portal | ✅ | N/A | All |

---

## 🎯 Next Steps

1. ~~Build iOS for App Store Review~~ ✅ **Build 70 uploaded!**
2. **Go to App Store Connect** and submit Build 70 for review
3. Test subscription cancellation flow end-to-end
4. Verify mobile reads `subscriptionCancelAtPeriodEnd` properly

---

*Build 70 uploaded to App Store Connect on February 7, 2026! 🍎*

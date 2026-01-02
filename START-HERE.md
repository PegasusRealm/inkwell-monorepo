# InkWell Monorepo - Start Here

**Last Updated:** January 1, 2026  
**Status:** ✅ Fully Set Up & Ready to Use

---

## 📁 Your Working Directory

**Always work here:** `/Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo/`

```bash
cd /Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo
code .  # Opens everything in one VS Code window
```

---

## 🗂️ Structure

```
inkwell-monorepo/
├── shared/              ← Firebase backend (functions, rules, config)
│   ├── functions/       ← Edit Firebase functions HERE
│   ├── firestore.rules
│   └── firebase.json
│
├── web/                 ← Web application
│   ├── public/          ← Edit web UI here (app.html, etc.)
│   └── functions/       → Symlink to ../shared/functions
│
└── mobile/              ← React Native mobile app (iOS/Android)
    ├── src/screens/     ← Edit mobile UI here
    └── functions/       → Symlink to ../shared/functions
```

**Key Feature:** Both `web/functions` and `mobile/functions` are symlinks to `shared/functions`.  
**This means:** Edit `shared/functions/index.js` once → both apps see the change!

---

## 🚀 Common Tasks

### Edit Shared Backend Code (Firebase Functions)
```bash
# Open the monorepo in VS Code
code /Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo

# Edit functions
nano shared/functions/index.js

# Both web and mobile automatically see this change!
```

### Deploy Firebase Backend
```bash
cd /Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo/shared
firebase deploy --only functions
firebase deploy --only firestore:rules
```

### Work on Web App
```bash
# Edit web UI
nano web/public/app.html

# Deploy web hosting
cd web
firebase deploy --only hosting
```

### Work on Mobile App
```bash
# Edit mobile screens
nano mobile/src/screens/LoginScreen.tsx

# Run on iOS simulator
cd mobile
npx react-native run-ios

# Run on Android
npx react-native run-android
```

---

## 📦 Mobile App Info

- **Framework:** React Native 0.76.6 (stable version)
- **Status:** Fresh install, ready for Firebase integration
- **Screens:** SplashScreen.tsx and LoginScreen.tsx already copied
- **Next Steps:** 
  1. Install Firebase packages
  2. Add GoogleService-Info.plist
  3. Build & test basic app
  4. Integrate authentication

---

## ⚠️ Important Notes

1. **Always edit Firebase functions in `shared/functions/`** - not in web/ or mobile/
2. **The symlinks make changes appear automatically** in both web and mobile
3. **Keep `/inkwell/` folder for now** - it's a backup of your working web app
4. **All redundant folders have been trashed** - recover from Trash if needed

---

## 🧹 What Was Cleaned Up

- ✅ Trashed `inkwell-backup/` (old backup from Dec 16)
- ✅ Trashed `inkwell-shared/` (duplicate of monorepo/shared)
- ✅ Deleted broken mobile app (RN 0.83)
- ✅ Moved fresh mobile app (RN 0.76.6) into monorepo

---

## 🎯 Next Session Goals

1. Install Firebase packages in mobile app
2. Configure Firebase for iOS
3. Get mobile app building successfully
4. Implement Splash → Login flow
5. Add Firebase authentication

---

**You're all set! Everything is organized and ready to build. 🚀**

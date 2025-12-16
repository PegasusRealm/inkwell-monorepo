# Active GitHub Repositories

**Date:** December 16, 2025  
**Status:** ✅ Monorepo Setup Complete

---

## 🎯 Active Repositories (USE THESE)

### 1. **inkwell-monorepo** (This One!)
- **URL:** https://github.com/PegasusRealm/inkwell-monorepo
- **Purpose:** Parent repository that ties everything together
- **Work Here:** This is your main development directory
- **Location:** `/Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo`

### 2. **inkwell**
- **URL:** https://github.com/PegasusRealm/inkwell
- **Purpose:** Web application (submodule in monorepo)
- **Don't work here directly** - work in `inkwell-monorepo/web/` instead

### 3. **inkwell-shared**
- **URL:** https://github.com/PegasusRealm/inkwell-shared
- **Purpose:** Shared Firebase backend (functions, rules, config)
- **Don't work here directly** - work in `inkwell-monorepo/shared/` instead

---

## 🗑️ Delete These Repositories

### 1. **inkwell-web**
- **URL:** https://github.com/PegasusRealm/inkwell-web
- **Status:** DUPLICATE - we use `inkwell` instead
- **Action:** Delete from GitHub

### 2. **InkWellMobile**
- **URL:** https://github.com/PegasusRealm/InkWellMobile (private)
- **Status:** Old mobile attempt from Nov 11
- **Action:** Delete or archive

---

## 📋 How to Delete GitHub Repos

1. Go to https://github.com/PegasusRealm/inkwell-web
2. Click **Settings** (far right tab)
3. Scroll to **Danger Zone** at bottom
4. Click **Delete this repository**
5. Type the repo name to confirm
6. Repeat for InkWellMobile

---

## 🚀 Your Development Workflow

### Daily Work Location
```bash
cd /Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo
```

### Project Structure
```
inkwell-monorepo/          ← Work here!
├── shared/                ← Firebase backend (submodule)
├── web/                   ← Web app (submodule)
├── scripts/               ← Helper scripts
└── ACTIVE-REPOS.md       ← This file
```

### Quick Commands
```bash
# Sync all projects
./scripts/sync-all.sh

# Update shared backend
cd shared
# ... make changes ...
cd .. && ./scripts/push-shared.sh "Your commit message"

# Deploy to Firebase
./scripts/deploy-backend.sh
```

---

## 🎉 What's Working Now

✅ Monorepo structure complete  
✅ Shared backend linked to web app via symlinks  
✅ All code pushed to GitHub  
✅ Helper scripts installed  
✅ Ready to add mobile app when you're ready

---

## 📱 Next Step: Create Mobile App

When you're ready to work on the mobile app:

```bash
cd /Users/Grimm/Documents/Pegasus_Realm/15_App_Projects/inkwell-monorepo

# Create React Native app
npx react-native@latest init InkWellMobile
mv InkWellMobile mobile

# Setup as submodule
cd mobile
git init
git add .
git commit -m "Initial React Native setup"
git remote add origin https://github.com/PegasusRealm/inkwell-mobile.git
git push -u origin main

# Link to shared backend
ln -s ../shared/functions ./functions
ln -s ../shared/firebase.json ./firebase.json
git add .
git commit -m "Link to shared backend"
git push

# Add to monorepo
cd ..
git submodule add https://github.com/PegasusRealm/inkwell-mobile.git mobile
git add .
git commit -m "Add mobile submodule"
git push
```

Then create `inkwell-mobile` repo on GitHub first!

---

## 📚 Documentation

All guides are in the `web/` directory:
- [QUICK-START.md](web/QUICK-START.md) - Initial setup (done!)
- [DEVELOPMENT-WORKFLOW.md](web/DEVELOPMENT-WORKFLOW.md) - Daily workflows
- [MONOREPO-SETUP-GUIDE.md](web/MONOREPO-SETUP-GUIDE.md) - Complete guide

---

**You're all set! 🚀**

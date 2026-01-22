# Admin Account Setup Guide

## Overview
The admin system has been fully integrated with coach verification and email notifications.

## Initial Admin Setup

### Option 1: Firebase Console (Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com/project/inkwell-alpha/firestore)
2. Navigate to **Firestore Database**
3. Find your user document in the `users` collection
4. Click on your user document
5. Add/update the field:
   - **Field**: `userRole`
   - **Type**: string
   - **Value**: `admin`
6. Save the document

### Option 2: Using Firebase CLI
```bash
# Install Firebase tools if needed
npm install -g firebase-tools

# Login
firebase login

# Run this script in Firebase console or use a temporary Cloud Function
firebase firestore:update users/YOUR_USER_ID '{"userRole": "admin"}'
```

### Option 3: Manual Firestore Update Script
Create a temporary file `set-admin.js`:
```javascript
const admin = require('firebase-admin');
admin.initializeApp();

const YOUR_EMAIL = 'your-email@example.com';

async function setAdmin() {
  const usersRef = admin.firestore().collection('users');
  const snapshot = await usersRef.where('email', '==', YOUR_EMAIL).get();
  
  if (snapshot.empty) {
    console.log('User not found');
    return;
  }
  
  const userDoc = snapshot.docs[0];
  await userDoc.ref.update({ userRole: 'admin' });
  console.log('✅ Admin role set successfully');
}

setAdmin().then(() => process.exit());
```

## Admin Portal Access

### URL
https://inkwell-alpha.web.app/admin.html

### Login
1. Use your existing InkWell account credentials
2. Your account must have `userRole: "admin"` in Firestore
3. The system will verify both authentication AND admin role

### Features

#### 1. Coach Application Review
- View all pending applications from `practitionerApplications` collection
- See full details: name, credentials, specialty, license, location, description
- Approve or reject with one click

#### 2. Approve Coach
When you approve:
- ✅ Sets `accountType: "coach"` (grants 25% discount on all tiers)
- ✅ Creates record in `approvedPractitioners` collection
- ✅ Creates revenue tracking in `practitioners` collection  
- ✅ Updates application status to "approved"
- ✅ Sends professional approval email via SendGrid
- ✅ Grants access to coach portal

#### 3. Reject Coach
When you reject:
- ❌ Updates application status to "rejected"
- ❌ Optionally provide reason for rejection
- ❌ Sends professional rejection email via SendGrid
- ❌ Prevents portal access

## Email Notifications

All emails are sent via **SendGrid** using the configured `SENDGRID_API_KEY` secret.

### Email Types Configured

1. **Grace Period Emails** (Auto-sent by scheduled functions)
   - Initial notice (Day 0)
   - Reminder (Day 7)
   - Final warning (Day 13)
   - Downgrade confirmation (Day 14)

2. **Coach Approval Email**
   - Welcome message
   - Portal access link
   - Discount information
   - Next steps guidance

3. **Coach Rejection Email**
   - Professional notification
   - Optional reason
   - Reapplication information

### SendGrid Configuration
- Secret: `SENDGRID_API_KEY` (already configured)
- From: `noreply@inkwelljournal.io`
- Name: "InkWell Journal"

## Cloud Functions Deployed

### Coach Verification
- ✅ `approvePractitioner` - Approve applications, grant coach role, send email
- ✅ `rejectPractitioner` - Reject applications, send email
- ✅ `getPendingPractitioners` - List pending applications (admin only)

### Grace Period Management
- ✅ `checkGracePeriods` - Scheduled daily 4 AM UTC
- ✅ `disconnectPractitioner` - Handle coach disconnection
- ✅ `sendGracePeriodEmail` - Helper function for email sending

## Application Flow

### Coach Registration
1. Coach receives invitation or visits registration page
2. Fills out application form with credentials, license info
3. System creates:
   - Firebase Auth account
   - `practitionerApplications/{userId}` document (status: "pending")
   - `users/{userId}` document (accountType: "standard")

### Admin Review
1. Admin logs into admin portal
2. Views pending application with all details
3. Clicks "Approve" or "Reject"
4. System processes via Cloud Function
5. Applicant receives email notification

### Post-Approval
1. Coach can log into portal
2. Has `accountType: "coach"` (25% discount)
3. Can create gift codes for clients
4. Revenue is tracked in `practitioners` collection
5. Always receives $30 per Connect client

## Security

### Admin Access Control
- Only users with `userRole: "admin"` can access admin portal
- Cloud Functions verify admin role in Firestore
- Unauthorized access attempts are logged and rejected

### Collections Used
- `users` - User profiles with roles
- `practitionerApplications` - Pending/approved/rejected applications
- `approvedPractitioners` - Active coaches
- `practitioners` - Revenue tracking
- `admins` - (Optional) Alternative admin checking collection

## Firestore Indexes Required

The admin page queries require this index:
```
Collection: practitionerApplications
Fields: status (Ascending), createdAt (Descending)
```

Create it at: https://console.firebase.google.com/project/inkwell-alpha/firestore/indexes

## Troubleshooting

### Can't Log Into Admin Portal
1. Verify your account has `userRole: "admin"` in Firestore
2. Try logging out and back in
3. Check browser console for error messages
4. Verify you're using the correct email/password

### No Pending Applications Showing
1. Check Firestore `practitionerApplications` collection
2. Verify applications have `status: "pending"`
3. Check browser console for query errors
4. Verify Firestore index is created

### Emails Not Sending
1. Verify `SENDGRID_API_KEY` secret is configured
2. Check Cloud Function logs in Firebase Console
3. Verify SendGrid account is active
4. Check SendGrid dashboard for delivery status

### Approval/Rejection Failing
1. Check browser console for errors
2. Verify Cloud Functions are deployed
3. Check Function logs in Firebase Console
4. Ensure practitioner application exists in Firestore

## Monitoring

### Firebase Console URLs
- **Functions Logs**: https://console.firebase.google.com/project/inkwell-alpha/functions
- **Firestore Data**: https://console.firebase.google.com/project/inkwell-alpha/firestore
- **Authentication**: https://console.firebase.google.com/project/inkwell-alpha/authentication

### What to Monitor
- Pending application count
- Approval/rejection success rate
- Email delivery logs (SendGrid dashboard)
- Grace period email timing
- Revenue tracking accuracy

## Next Steps

1. **Set yourself as admin** using one of the methods above
2. **Test admin login** at https://inkwell-alpha.web.app/admin.html
3. **Create test practitioner application** to verify approval flow
4. **Check SendGrid** for email delivery
5. **Monitor grace period emails** in SendGrid dashboard
6. **Review coach portal** access after approval

## Support

For issues with the admin system:
1. Check Firebase Function logs
2. Check browser console for errors
3. Verify Firestore data structure
4. Check SendGrid delivery status
5. Review this documentation

# Email Insights Integration - Mobile App

## Overview
Added Sophy Weekly and Monthly Email Insights preferences to the mobile Settings screen, matching the web app implementation.

## Changes Made

### 1. Settings Screen UI (`mobile_2/src/screens/SettingsScreen.tsx`)

Added new "Email Insights from Sophy" section with:
- **Weekly Insights Toggle**: Sends email every Monday morning
- **Monthly Insights Toggle**: Sends email on the first of every month
- Real-time save with loading indicator
- Descriptive text explaining each option

### 2. Data Structure
Preferences are saved to Firestore under `users/{userId}`:
```typescript
{
  insightsPreferences: {
    weeklyEnabled: boolean,
    monthlyEnabled: boolean,
    updatedAt: timestamp
  }
}
```

### 3. New State Variables
```typescript
const [weeklyInsightsEnabled, setWeeklyInsightsEnabled] = useState(true);
const [monthlyInsightsEnabled, setMonthlyInsightsEnabled] = useState(true);
const [savingInsights, setSavingInsights] = useState(false);
```

### 4. New Functions

#### `loadInsightsPreferences()`
- Loads user's email insights preferences from Firestore
- Defaults to `true` if not explicitly set to `false`
- Called on component mount

#### `saveInsightsPreferences(weekly, monthly)`
- Saves preferences to Firestore with merge
- Shows loading indicator during save
- Displays success/error alerts

### 5. UI Components
- **Section Header**: "📧 Email Insights from Sophy"
- **Description**: Explains what insights emails contain
- **Switch Controls**: 
  - Weekly toggle with "Every Monday morning" label
  - Monthly toggle with "First of every month" label
- **Saving Indicator**: Shows when preferences are being saved

### 6. Styling
New styles added:
- `insightsDescription`: Main description text
- `switchRow`: Container for each toggle row
- `switchLabel`: Label container with title and description
- `switchTitle`: Bold title for each toggle
- `switchDescription`: Subtitle text
- `savingIndicator`: Loading spinner container
- `savingText`: "Saving..." text style

## Backend Integration

The backend SendGrid integration is already operational in `web/functions/index.js`. The mobile app simply sets user preferences; the Cloud Functions handle:
- Scheduled weekly insights emails (Monday mornings)
- Scheduled monthly insights emails (first of month)
- Email content generation via Sophy/Claude AI
- SendGrid delivery

## Testing

1. Open mobile app
2. Navigate to Settings tab
3. Scroll to "Email Insights from Sophy" section
4. Toggle weekly/monthly switches
5. Verify preferences save to Firestore
6. Check Firestore console: `users/{userId}/insightsPreferences`

## Data Consistency

The mobile implementation matches the web app exactly:
- Same Firestore field names
- Same data structure
- Same default values (both default to `true`)
- Backend reads from same location

## Future Enhancements

Potential improvements:
- Add preview of what insights emails look like
- Show when next insight email will be sent
- Add option to send test insight email
- Display last insight email sent date
- Allow customization of email frequency

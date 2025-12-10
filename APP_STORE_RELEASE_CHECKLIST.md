# App Store Release Checklist for Big Feelings

This document outlines all the changes and steps needed to release your app for free on the iOS App Store.

## ✅ Critical Fixes (Already Completed)

1. **Deployment Target Fixed**: Changed from iOS 26.1 to iOS 17.0
   - This was preventing the app from building correctly
   - iOS 17.0 supports iPhone 12 and newer devices

2. **Privacy Manifest Created**: `PrivacyInfo.xcprivacy` file created
   - Required by Apple for all apps submitted to the App Store
   - Declares data collection and API usage

## 🔧 Required Changes in Xcode

### 1. Add Privacy Manifest to Project

1. Open your project in Xcode
2. Right-click on the `bigfeelings` folder in the Project Navigator
3. Select "Add Files to 'bigfeelings'..."
4. Navigate to and select `PrivacyInfo.xcprivacy`
5. Make sure "Copy items if needed" is **unchecked** (file is already in the right place)
6. Make sure your app target is checked
7. Click "Add"

### 2. Add Info.plist Keys (via Build Settings)

In Xcode, go to your app target's **Build Settings** and add these keys under **Info.plist Values**:

**Required Keys:**
- `NSUserTrackingUsageDescription` - Not needed (you're not tracking)
- `NSPrivacyAccessedAPITypes` - Already declared in PrivacyInfo.xcprivacy

**Recommended Keys (add in Info tab):**
- `NSHumanReadableCopyright` = "Copyright © 2025 Christopher Law. All rights reserved."
- `LSApplicationCategoryType` = "public.app-category.education"

**To add these:**
1. Select your project in Project Navigator
2. Select the `bigfeelings` target
3. Go to the **Info** tab
4. Click the **+** button to add new keys
5. Add the keys above with their values

### 3. Verify App Icons

1. Open `Assets.xcassets` → `AppIcon`
2. Ensure you have a **1024x1024** icon for App Store submission
3. The icon should:
   - Not have transparency
   - Not use rounded corners (iOS adds them automatically)
   - Be high quality and represent your app well

### 4. Update Version Numbers

In the **General** tab of your target:
- **Version**: 1.0 (already set)
- **Build**: 1 (already set)
- Increment Build number for each App Store submission

## 📋 App Store Connect Setup

### 1. Create App Record

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - **Platform**: iOS
   - **Name**: Big Feelings
   - **Primary Language**: English
   - **Bundle ID**: `com.ctlaltdev.bigfeelings` (must match exactly)
   - **SKU**: `bigfeelings-001` (any unique identifier)
   - **User Access**: Full Access

### 2. App Information

**App Privacy:**
- Go to **App Privacy** section
- Answer: "Does your app collect data?" → **No**
- Your app only stores data locally (UserDefaults), which doesn't count as "collection" for App Store purposes

**Age Rating:**
- This is a **children's app** (ages 4-12)
- Select appropriate age rating (likely 4+)
- Answer questions about content (should all be "No" for your app)

**Category:**
- Primary: **Education**
- Secondary: **Kids** (optional)

### 3. App Store Listing

**Required Information:**

**Name:** Big Feelings (30 characters max)

**Subtitle:** Helping children explore emotions through stories (30 characters max)

**Description:** (4000 characters max)
```
Big Feelings helps children ages 4-12 explore and understand their emotions through interactive stories and activities.

FEATURES:
• Interactive Stories: Engaging stories featuring animal characters facing real emotional situations
• Age-Appropriate Content: Stories tailored for ages 4-6, 7-9, and 10-12
• Feelings Journal: Daily check-ins to help children express how they're feeling
• Progress Tracking: See your child's emotional growth over time
• Achievement System: Fun rewards for completing stories and activities
• Safe & Private: All data stays on your device - no tracking, no ads

Perfect for parents, teachers, and therapists looking to help children develop emotional intelligence and healthy coping strategies.
```

**Keywords:** (100 characters max)
```
emotions,feelings,children,kids,education,emotional intelligence,stories,mental health
```

**Support URL:** (Required)
- You'll need to create a simple website or use a placeholder
- Example: `https://yourwebsite.com/support` or use a GitHub Pages site

**Marketing URL:** (Optional)
- Can be same as support URL or leave blank

**Privacy Policy URL:** (Required for apps targeting children)
- **CRITICAL**: You must create a privacy policy
- Must be accessible via URL
- Can be a simple page explaining:
  - App doesn't collect personal data
  - Data is stored locally on device
  - No third-party tracking
  - No ads
  - COPPA compliance (since it's for children)

**Promotional Text:** (170 characters, optional)
```
Help children explore emotions through interactive stories. Safe, educational, and fun!
```

### 4. App Screenshots (Required)

You need screenshots for:
- **iPhone 6.7" Display** (iPhone 14 Pro Max, 15 Pro Max) - Required
- **iPhone 6.5" Display** (iPhone 11 Pro Max, XS Max) - Optional but recommended
- **iPad Pro 12.9"** - Required if supporting iPad

**Minimum Requirements:**
- At least 3 screenshots per device size
- Show key features: Welcome screen, Story selection, Quiz/Story view, Feelings Journal, Growth view

**Screenshot Tips:**
- Use a real device or simulator
- Remove status bar personal info (Settings → General → About → Name)
- Show the app's best features
- Make them visually appealing

### 5. App Preview Video (Optional but Recommended)

- 15-30 second video showing app in action
- Can significantly improve downloads

## 🔐 Code Signing & Certificates

### 1. Apple Developer Account

- Ensure you have an **Apple Developer Program** membership ($99/year)
- Your Team ID appears to be: `8P2SA3MB4Y`

### 2. Provisioning Profile

1. In Xcode, go to **Signing & Capabilities**
2. Ensure **Automatically manage signing** is checked
3. Select your **Team** from the dropdown
4. Xcode will automatically create certificates and provisioning profiles

### 3. Build for App Store

1. Select **Any iOS Device** or **Generic iOS Device** as destination
2. Product → **Archive**
3. Once archived, click **Distribute App**
4. Select **App Store Connect**
5. Follow the wizard to upload

## 📱 Testing Requirements

### TestFlight (Recommended)

1. Upload build to App Store Connect
2. Add internal testers (yourself)
3. Test thoroughly before submitting for review
4. Can add up to 100 external testers for beta testing

### Pre-Submission Checklist

- [ ] Test on real iOS devices (iPhone and iPad if supported)
- [ ] Test all features work correctly
- [ ] Verify no crashes or bugs
- [ ] Test with different age ranges
- [ ] Verify data persistence works
- [ ] Test text-to-speech functionality
- [ ] Check all UI elements display correctly
- [ ] Verify app works in both light and dark mode (if supported)

## 🚨 Important Notes for Children's Apps

Since your app targets children (ages 4-12), you must comply with:

1. **COPPA (Children's Online Privacy Protection Act)**
   - Your app appears compliant (no data collection, no ads, no tracking)
   - Still need to declare this in App Store Connect

2. **App Store Review Guidelines for Kids**
   - No in-app purchases (you're free, so ✅)
   - No ads (you don't have ads, so ✅)
   - No external links without parental gate
   - Privacy policy required (see above)

3. **Age Rating**
   - Select appropriate age rating
   - Answer content questions honestly

## 📄 Privacy Policy Template

You'll need to create a privacy policy. Here's a basic template:

```
Privacy Policy for Big Feelings

Last Updated: [Date]

Big Feelings ("we", "our", or "us") is committed to protecting your privacy.

Data Collection:
Big Feelings does not collect, transmit, or share any personal information. All data is stored locally on your device using iOS UserDefaults.

Data Storage:
- Child profiles (names, ages, notes)
- Story progress and quiz results
- Feelings journal entries
- Achievement progress

All data remains on your device and is never transmitted to external servers.

Children's Privacy:
Big Feelings is designed for children ages 4-12. We comply with COPPA (Children's Online Privacy Protection Act) and do not collect any personal information from children.

Third-Party Services:
Big Feelings does not use any third-party analytics, advertising, or tracking services.

Contact:
If you have questions about this privacy policy, please contact us at [your email].

Changes to This Policy:
We may update this privacy policy from time to time. We will notify you of any changes by updating the "Last Updated" date.
```

Host this on a website (GitHub Pages, your own site, etc.) and provide the URL in App Store Connect.

## ✅ Final Submission Checklist

Before submitting for review:

- [ ] Deployment target set to iOS 17.0
- [ ] PrivacyInfo.xcprivacy added to project
- [ ] App icons complete (1024x1024)
- [ ] Version and build numbers set
- [ ] Code signing configured
- [ ] App Store Connect listing complete
- [ ] Screenshots uploaded
- [ ] Privacy policy URL provided
- [ ] Support URL provided
- [ ] App description and metadata complete
- [ ] Age rating configured
- [ ] App Privacy questions answered
- [ ] Build uploaded via Xcode
- [ ] TestFlight testing completed (recommended)
- [ ] Ready for App Store review

## 🎯 Submission Process

1. **Archive and Upload:**
   - Product → Archive in Xcode
   - Distribute to App Store Connect
   - Wait for processing (usually 10-30 minutes)

2. **Submit for Review:**
   - Go to App Store Connect
   - Select your build
   - Fill in "What's New" (for first version, describe the app)
   - Answer export compliance questions
   - Submit for review

3. **Review Time:**
   - Usually 24-48 hours
   - Can be longer for first submission
   - You'll receive email notifications

4. **If Rejected:**
   - Read the feedback carefully
   - Address all issues
   - Resubmit with a new build number

## 📞 Support

If you encounter issues:
- Check [Apple's App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- Review [App Store Connect Help](https://help.apple.com/app-store-connect/)
- Check Xcode build logs for errors

Good luck with your submission! 🚀

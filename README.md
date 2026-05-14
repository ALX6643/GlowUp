# GlowUp — AI Looks Analysis iOS App

SwiftUI app that uses the **Claude Vision API** to analyze your appearance and give personalized recommendations. Monetized via **StoreKit 2** subscriptions with a 3-day free trial.

---

## Setup (requires macOS + Xcode 15+)

### 1. Clone and generate the Xcode project
```bash
git clone https://github.com/ALX6643/GlowUp.git
cd GlowUp

# Install XcodeGen if you don't have it
brew install xcodegen

# Generate the .xcodeproj
xcodegen generate

# Open in Xcode
open GlowUp.xcodeproj
```

### 2. Set your Anthropic API key
Open `Services/ClaudeAPIService.swift` and replace:
```swift
private let apiKey = "YOUR_ANTHROPIC_API_KEY"
```
> **Production tip:** Never ship your API key in the binary. Instead, call your own backend endpoint that calls Claude, so you can rate-limit per user and keep the key server-side.

### 3. Configure App Store Connect subscriptions
Create three **Auto-Renewable Subscriptions** in App Store Connect:

| Display Name     | Product ID                        | Price  |
|-----------------|-----------------------------------|--------|
| Weekly Premium  | `com.glowup.premium.weekly`       | $4.99/wk |
| Monthly Premium | `com.glowup.premium.monthly`      | $14.99/mo |
| Annual Premium  | `com.glowup.premium.annual`       | $79.99/yr |

Then add the **StoreKit Configuration File** for local testing:
- Xcode → File > New > StoreKit Configuration File
- Add the same three product IDs
- Edit scheme → Run → Options → StoreKit Config → select your file

### 4. Add capabilities in Xcode
- Signing & Capabilities → **In-App Purchase**
- Signing & Capabilities → **Push Notifications** (optional, for re-engagement)

### 5. Run on a real device
Camera requires a physical iPhone — the simulator cannot use the camera.

---

## Architecture

```
GlowUpApp.swift          — App entry, SwiftData container, SubscriptionService env
ContentView.swift         — Onboarding gate
Models/
  AnalysisRecord.swift   — SwiftData persistent model
  AnalysisResult.swift   — In-memory result + ScoreCategory helpers
Services/
  ClaudeAPIService.swift — Claude Vision API integration (base64 image → JSON analysis)
  SubscriptionService.swift — StoreKit 2 wrapper, free trial logic
Views/
  OnboardingView.swift   — First-launch paged onboarding + trial CTA
  MainTabView.swift      — Tab container (Analyze / History / Settings)
  HomeView.swift         — Photo picker + Analyze button
  ResultsView.swift      — Score ring, category bars, recommendation list
  PaywallView.swift      — Subscription selection + purchase flow
  HistoryView.swift      — SwiftData query list of past analyses
  SettingsView.swift     — Subscription status, restore, links
  ImagePickerView.swift  — UIImagePickerController wrapper
ViewModels/
  HomeViewModel.swift    — Camera/library state, API call orchestration, SwiftData save
```

## Free Trial Flow
1. First launch → `recordFirstLaunch()` stamps `firstLaunchDate` in `UserDefaults`
2. `isInFreeTrial` = `daysElapsed < 3`
3. After 3 days, `canScan` is `false` unless subscribed → `PaywallView` is shown
4. Trial banner in `HomeView` shows days remaining with Upgrade shortcut

## Subscription Tiers
- **Weekly** $4.99 — good for impulse buyers
- **Monthly** $14.99 — default pre-selection
- **Annual** $79.99 — "Save 58%" badge drives best LTV

## Privacy Note
Photos are sent to Anthropic's API for analysis. Add a clear disclosure in your App Store description and Privacy Policy. Do not store photos server-side.

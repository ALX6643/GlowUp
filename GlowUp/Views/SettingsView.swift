import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = true

    var body: some View {
        NavigationStack {
            List {
                // Subscription status
                Section("Membership") {
                    if subscriptionService.isSubscribed {
                        HStack {
                            Label("Premium Active", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                            Spacer()
                            Text("Active")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else if subscriptionService.isInFreeTrial {
                        HStack {
                            Label("Free Trial", systemImage: "clock.fill")
                                .foregroundStyle(.orange)
                            Spacer()
                            Text("\(subscriptionService.trialDaysRemaining) days left")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        NavigationLink {
                            PaywallView()
                        } label: {
                            Label("Upgrade to Premium", systemImage: "sparkles")
                                .foregroundStyle(.purple)
                        }
                    } else {
                        NavigationLink {
                            PaywallView()
                        } label: {
                            Label("Subscribe to Continue", systemImage: "lock.fill")
                                .foregroundStyle(.purple)
                        }
                    }
                }

                Section("Account") {
                    Button {
                        Task { await subscriptionService.restorePurchases() }
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                }

                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://yourapp.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }

                    Link(destination: URL(string: "https://yourapp.com/terms")!) {
                        Label("Terms of Use", systemImage: "doc.text")
                    }
                }

                #if DEBUG
                Section("Debug") {
                    Button("Reset Onboarding") {
                        hasSeenOnboarding = false
                    }
                    .foregroundStyle(.red)
                }
                #endif
            }
            .navigationTitle("Settings")
        }
    }
}

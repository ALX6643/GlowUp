import SwiftUI

struct ContentView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView()
        } else {
            MainTabView()
        }
    }
}

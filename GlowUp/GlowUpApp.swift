import SwiftUI
import SwiftData

@main
struct GlowUpApp: App {
    @StateObject private var subscriptionService = SubscriptionService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionService)
        }
        .modelContainer(for: AnalysisRecord.self)
    }
}

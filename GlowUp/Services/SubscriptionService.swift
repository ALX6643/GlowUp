import Foundation
import StoreKit

// Product IDs — configure these in App Store Connect
enum ProductID: String, CaseIterable {
    case weekly  = "com.glowup.premium.weekly"
    case monthly = "com.glowup.premium.monthly"
    case annual  = "com.glowup.premium.annual"
}

@MainActor
final class SubscriptionService: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var isSubscribed = false
    @Published private(set) var isLoading = false

    // Free trial window — 3 days from first launch
    private let trialDurationDays = 3
    @AppStorage("firstLaunchDate") private var firstLaunchTimestamp: Double = 0

    var isInFreeTrial: Bool {
        if firstLaunchTimestamp == 0 { return true }
        let firstLaunch = Date(timeIntervalSince1970: firstLaunchTimestamp)
        let elapsed = Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
        return elapsed < trialDurationDays
    }

    var trialDaysRemaining: Int {
        if firstLaunchTimestamp == 0 { return trialDurationDays }
        let firstLaunch = Date(timeIntervalSince1970: firstLaunchTimestamp)
        let elapsed = Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
        return max(0, trialDurationDays - elapsed)
    }

    var canScan: Bool { isSubscribed || isInFreeTrial }

    func recordFirstLaunch() {
        if firstLaunchTimestamp == 0 {
            firstLaunchTimestamp = Date().timeIntervalSince1970
        }
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: ProductID.allCases.map(\.rawValue))
            products.sort { $0.price < $1.price }
        } catch {
            print("StoreKit product load failed: \(error)")
        }
    }

    func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               ProductID(rawValue: transaction.productID) != nil {
                isSubscribed = true
                return
            }
        }
        isSubscribed = false
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                isSubscribed = true
            }
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            print("Restore failed: \(error)")
        }
    }
}

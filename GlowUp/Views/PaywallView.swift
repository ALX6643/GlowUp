import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProductID: String?
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color(red: 0.1, green: 0, blue: 0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Dismiss handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)

                    // Hero
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 52))
                            .foregroundStyle(
                                LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
                            )

                        Text("GlowUp Premium")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)

                        Text("Unlock unlimited AI-powered looks analysis\nand personalized improvement plans.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    // Feature list
                    VStack(spacing: 14) {
                        FeatureRow(icon: "camera.fill",      text: "Unlimited daily scans")
                        FeatureRow(icon: "chart.bar.fill",   text: "Detailed category scoring")
                        FeatureRow(icon: "clock.fill",       text: "Full scan history")
                        FeatureRow(icon: "lightbulb.fill",   text: "5 personalized tips per scan")
                        FeatureRow(icon: "arrow.up.circle",  text: "Priority AI model access")
                    }
                    .padding()
                    .background(Color.white.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)

                    // Product options
                    if subscriptionService.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(subscriptionService.products, id: \.id) { product in
                                ProductOptionRow(
                                    product: product,
                                    isSelected: selectedProductID == product.id,
                                    onSelect: { selectedProductID = product.id }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Error
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Subscribe CTA
                    Button {
                        guard let id = selectedProductID,
                              let product = subscriptionService.products.first(where: { $0.id == id })
                        else { return }
                        Task { await purchase(product) }
                    } label: {
                        HStack {
                            if isPurchasing { ProgressView().tint(.black) }
                            Text(isPurchasing ? "Processing…" : "Subscribe Now")
                                .font(.headline)
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(isPurchasing || selectedProductID == nil)
                    .padding(.horizontal)

                    // Restore + legal
                    VStack(spacing: 8) {
                        Button("Restore Purchases") {
                            Task {
                                await subscriptionService.restorePurchases()
                                if subscriptionService.isSubscribed { dismiss() }
                            }
                        }
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.5))

                        Text("Subscription auto-renews. Cancel anytime in Settings.")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .task {
            await subscriptionService.loadProducts()
            // Pre-select the monthly plan
            selectedProductID = subscriptionService.products
                .first(where: { $0.id == ProductID.monthly.rawValue })?.id
                ?? subscriptionService.products.first?.id
        }
    }

    private func purchase(_ product: Product) async {
        isPurchasing = true
        errorMessage = nil
        do {
            try await subscriptionService.purchase(product)
            if subscriptionService.isSubscribed { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
        }
        isPurchasing = false
    }
}

// MARK: - Subviews

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(.purple)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white)
            Spacer()
        }
    }
}

private struct ProductOptionRow: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void

    var savingsBadge: String? {
        if product.id == ProductID.annual.rawValue { return "Save 58%" }
        if product.id == ProductID.weekly.rawValue { return nil }
        return nil
    }

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(product.displayName)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                        if let badge = savingsBadge {
                            Text(badge)
                                .font(.caption2.bold())
                                .foregroundStyle(.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.yellow)
                                .clipShape(Capsule())
                        }
                    }
                    Text(product.displayPrice)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .purple : .white.opacity(0.3))
                    .font(.title3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.purple : Color.white.opacity(0.15), lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isSelected ? Color.purple.opacity(0.15) : Color.white.opacity(0.05))
                    )
            )
        }
    }
}

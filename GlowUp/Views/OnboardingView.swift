import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @EnvironmentObject var subscriptionService: SubscriptionService
    @State private var currentPage = 0

    private let pages: [(title: String, subtitle: String, icon: String, gradient: [String])] = [
        (
            "Discover Your Best Self",
            "AI-powered analysis reveals exactly what makes you shine — and how to shine brighter.",
            "sparkles",
            ["purple", "pink"]
        ),
        (
            "Personalized Recommendations",
            "Get actionable tips for your skin, hair, and style tailored specifically to you.",
            "list.bullet.clipboard",
            ["blue", "cyan"]
        ),
        (
            "Track Your Progress",
            "Save analyses over time and watch your glow-up journey unfold.",
            "chart.line.uptrend.xyaxis",
            ["green", "mint"]
        ),
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                // Page dots
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: currentPage == index ? 10 : 6, height: currentPage == index ? 10 : 6)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 32)

                // CTA
                VStack(spacing: 12) {
                    Text("3 Days Free — Then $14.99/mo")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.6))

                    Button {
                        subscriptionService.recordFirstLaunch()
                        hasSeenOnboarding = true
                    } label: {
                        Text("Start Free Trial")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 24)

                    Button("Restore Purchases") {
                        Task { await subscriptionService.restorePurchases() }
                    }
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.bottom, 40)
            }
        }
    }
}

private struct OnboardingPageView: View {
    let page: (title: String, subtitle: String, icon: String, gradient: [String])

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(page.gradient[0]), Color(page.gradient[1])],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                    .opacity(0.6)

                Image(systemName: page.icon)
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(.white)
            }

            Text(page.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.horizontal, 32)

            Text(page.subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }
}

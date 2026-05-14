import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @Environment(\.modelContext) var modelContext
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Trial banner
                        if !subscriptionService.isSubscribed && subscriptionService.isInFreeTrial {
                            TrialBannerView(daysRemaining: subscriptionService.trialDaysRemaining) {
                                viewModel.showPaywall = true
                            }
                        }

                        // Photo picker area
                        PhotoPickerCard(
                            selectedImage: viewModel.selectedImage,
                            onCamera: {
                                viewModel.sourceType = .camera
                                viewModel.showImagePicker = true
                            },
                            onLibrary: {
                                viewModel.sourceType = .photoLibrary
                                viewModel.showImagePicker = true
                            }
                        )

                        // Analyze button
                        if viewModel.selectedImage != nil {
                            Button {
                                viewModel.analyze(canScan: subscriptionService.canScan)
                            } label: {
                                HStack(spacing: 10) {
                                    if viewModel.isAnalyzing {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "sparkles")
                                    }
                                    Text(viewModel.isAnalyzing ? "Analyzing…" : "Analyze My Look")
                                        .font(.headline)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .disabled(viewModel.isAnalyzing)
                            .padding(.horizontal)
                        }

                        if let error = viewModel.error {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("GlowUp")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePickerView(image: $viewModel.selectedImage, sourceType: viewModel.sourceType)
            }
            .sheet(isPresented: $viewModel.showPaywall) {
                PaywallView()
            }
            .navigationDestination(isPresented: $viewModel.showResults) {
                if let result = viewModel.analysisResult, let image = viewModel.selectedImage {
                    ResultsView(result: result, image: image) {
                        viewModel.reset()
                    }
                }
            }
            .onAppear {
                viewModel.modelContext = modelContext
            }
        }
    }
}

// MARK: - Subviews

private struct TrialBannerView: View {
    let daysRemaining: Int
    let onUpgrade: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Free Trial")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("\(daysRemaining) day\(daysRemaining == 1 ? "" : "s") remaining")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            Button("Upgrade", action: onUpgrade)
                .font(.subheadline.bold())
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(Capsule())
        }
        .padding()
        .background(
            LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

private struct PhotoPickerCard: View {
    let selectedImage: UIImage?
    let onCamera: () -> Void
    let onLibrary: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 340)

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 340)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.rectangle")
                        .font(.system(size: 56, weight: .light))
                        .foregroundStyle(.secondary)

                    Text("Add your photo to get started")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        PickerButton(title: "Camera", icon: "camera", action: onCamera)
                        PickerButton(title: "Library", icon: "photo.on.rectangle", action: onLibrary)
                    }
                }
            }
        }
        .padding(.horizontal)
        .onTapGesture {
            if selectedImage != nil { onLibrary() }
        }
    }
}

private struct PickerButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline.bold())
            .foregroundStyle(.purple)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.purple.opacity(0.12))
            .clipShape(Capsule())
        }
    }
}

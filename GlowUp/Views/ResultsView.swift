import SwiftUI

struct ResultsView: View {
    let result: AnalysisResult
    let image: UIImage
    let onDone: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header photo + score
                ZStack(alignment: .bottom) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 280)
                        .clipped()

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    ScoreRingView(score: result.overallScore)
                        .padding(.bottom, 20)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)

                // Summary
                VStack(alignment: .leading, spacing: 8) {
                    Label("Overall Impression", systemImage: "quote.bubble")
                        .font(.headline)
                        .foregroundStyle(.purple)

                    Text(result.summary)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Category scores
                VStack(alignment: .leading, spacing: 12) {
                    Text("Category Breakdown")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(result.categories) { category in
                        CategoryScoreRow(category: category)
                    }
                }

                // Recommendations
                VStack(alignment: .leading, spacing: 12) {
                    Label("Your Personalized Tips", systemImage: "lightbulb.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                        .padding(.horizontal)

                    ForEach(Array(result.recommendations.enumerated()), id: \.offset) { index, tip in
                        RecommendationRow(number: index + 1, text: tip)
                    }
                }

                // Done button
                Button {
                    dismiss()
                    onDone()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.purple)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.top)
        }
        .navigationTitle("Your Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Subviews

private struct ScoreRingView: View {
    let score: Int
    @State private var animatedScore: Double = 0

    var scoreColor: Color {
        switch score {
        case 85...100: return .green
        case 65..<85:  return .yellow
        default:       return .orange
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: animatedScore / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.2), value: animatedScore)

                VStack(spacing: 0) {
                    Text("\(score)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                    Text("/ 100")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            Text("Overall Score")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.9))
        }
        .onAppear { animatedScore = Double(score) }
    }
}

private struct CategoryScoreRow: View {
    let category: ScoreCategory

    var barColor: Color {
        switch category.score {
        case 85...100: return .green
        case 65..<85:  return .yellow
        default:       return .orange
        }
    }

    @State private var progress: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                Text(category.name)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(category.score)")
                    .font(.subheadline.bold())
                    .foregroundStyle(barColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.tertiarySystemBackground))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geo.size.width * progress, height: 8)
                        .animation(.easeOut(duration: 1.0), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal)
        .onAppear { progress = Double(category.score) / 100 }
    }
}

private struct RecommendationRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Color.purple)
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

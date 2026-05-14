import SwiftUI
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var analysisResult: AnalysisResult?
    @Published var isAnalyzing = false
    @Published var error: String?
    @Published var showPaywall = false
    @Published var showResults = false
    @Published var showImagePicker = false
    @Published var sourceType: UIImagePickerController.SourceType = .camera

    private let apiService = ClaudeAPIService()
    var modelContext: ModelContext?

    func analyze(canScan: Bool) {
        guard canScan else {
            showPaywall = true
            return
        }
        guard selectedImage != nil else { return }
        Task { await runAnalysis() }
    }

    private func runAnalysis() async {
        guard let image = selectedImage else { return }
        isAnalyzing = true
        error = nil
        do {
            let result = try await apiService.analyze(image: image)
            analysisResult = result
            saveRecord(image: image, result: result)
            showResults = true
        } catch {
            self.error = error.localizedDescription
        }
        isAnalyzing = false
    }

    private func saveRecord(image: UIImage, result: AnalysisResult) {
        guard let context = modelContext,
              let imageData = image.jpegData(compressionQuality: 0.6) else { return }
        let record = AnalysisRecord(
            imageData: imageData,
            overallScore: result.overallScore,
            skinScore: result.skinScore,
            hairScore: result.hairScore,
            styleScore: result.styleScore,
            symmetryScore: result.symmetryScore,
            summary: result.summary,
            recommendations: result.recommendations
        )
        context.insert(record)
        try? context.save()
    }

    func reset() {
        selectedImage = nil
        analysisResult = nil
        error = nil
        showResults = false
    }
}

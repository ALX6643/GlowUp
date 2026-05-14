import Foundation
import SwiftData

@Model
final class AnalysisRecord {
    var id: UUID
    var date: Date
    var imageData: Data
    var overallScore: Int
    var skinScore: Int
    var hairScore: Int
    var styleScore: Int
    var symmetryScore: Int
    var summary: String
    var recommendations: [String]

    init(
        imageData: Data,
        overallScore: Int,
        skinScore: Int,
        hairScore: Int,
        styleScore: Int,
        symmetryScore: Int,
        summary: String,
        recommendations: [String]
    ) {
        self.id = UUID()
        self.date = Date()
        self.imageData = imageData
        self.overallScore = overallScore
        self.skinScore = skinScore
        self.hairScore = hairScore
        self.styleScore = styleScore
        self.symmetryScore = symmetryScore
        self.summary = summary
        self.recommendations = recommendations
    }
}

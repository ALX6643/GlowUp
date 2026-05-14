import Foundation

struct AnalysisResult {
    let overallScore: Int
    let skinScore: Int
    let hairScore: Int
    let styleScore: Int
    let symmetryScore: Int
    let summary: String
    let recommendations: [String]
}

// Parsed from Claude's JSON response
struct ClaudeAnalysisResponse: Decodable {
    let overall_score: Int
    let skin_score: Int
    let hair_score: Int
    let style_score: Int
    let symmetry_score: Int
    let summary: String
    let recommendations: [String]

    func toAnalysisResult() -> AnalysisResult {
        AnalysisResult(
            overallScore: overall_score,
            skinScore: skin_score,
            hairScore: hair_score,
            styleScore: style_score,
            symmetryScore: symmetry_score,
            summary: summary,
            recommendations: recommendations
        )
    }
}

struct ScoreCategory: Identifiable {
    let id = UUID()
    let name: String
    let score: Int
    let icon: String

    var color: String {
        switch score {
        case 85...100: return "green"
        case 65..<85:  return "yellow"
        default:       return "red"
        }
    }
}

extension AnalysisResult {
    var categories: [ScoreCategory] {
        [
            ScoreCategory(name: "Skin", score: skinScore, icon: "sparkles"),
            ScoreCategory(name: "Hair", score: hairScore, icon: "scissors"),
            ScoreCategory(name: "Style", score: styleScore, icon: "tshirt"),
            ScoreCategory(name: "Symmetry", score: symmetryScore, icon: "face.smiling"),
        ]
    }
}

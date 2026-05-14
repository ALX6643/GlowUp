import Foundation
import UIKit

final class ClaudeAPIService {
    // Replace with your key — store in a server-side proxy for production
    private let apiKey = "YOUR_ANTHROPIC_API_KEY"
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-opus-4-7"

    private let systemPrompt = """
    You are a professional image consultant and aesthetics expert. Analyze the provided photo \
    and evaluate the person's appearance across four categories. Be constructive, kind, and specific.

    Respond ONLY with valid JSON matching exactly this schema:
    {
      "overall_score": <integer 0-100>,
      "skin_score": <integer 0-100>,
      "hair_score": <integer 0-100>,
      "style_score": <integer 0-100>,
      "symmetry_score": <integer 0-100>,
      "summary": "<2-3 sentence overall impression>",
      "recommendations": ["<tip 1>", "<tip 2>", "<tip 3>", "<tip 4>", "<tip 5>"]
    }

    Scoring guide:
    - skin_score: clarity, hydration, evenness, visible blemishes or concerns
    - hair_score: condition, style, cleanliness, suitability for face shape
    - style_score: clothing fit, colour coordination, grooming, overall presentation
    - symmetry_score: facial balance and proportions
    - overall_score: holistic impression (not just the average)

    Recommendations must be actionable, specific, and positive in tone. \
    Avoid generic advice — tailor to what you observe in the photo.
    """

    func analyze(image: UIImage) async throws -> AnalysisResult {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw AnalysisError.imageEncodingFailed
        }
        let base64Image = imageData.base64EncodedString()

        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "system": systemPrompt,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": "Please analyze my appearance and provide your expert assessment."
                        ]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AnalysisError.networkError
        }
        guard httpResponse.statusCode == 200 else {
            throw AnalysisError.apiError(statusCode: httpResponse.statusCode)
        }

        return try parseResponse(data: data)
    }

    private func parseResponse(data: Data) throws -> AnalysisResult {
        struct MessageResponse: Decodable {
            struct Content: Decodable {
                let type: String
                let text: String?
            }
            let content: [Content]
        }

        let messageResponse = try JSONDecoder().decode(MessageResponse.self, from: data)
        guard let text = messageResponse.content.first(where: { $0.type == "text" })?.text else {
            throw AnalysisError.invalidResponse
        }

        // Extract JSON from the response (Claude may wrap it in markdown)
        let jsonText = extractJSON(from: text)
        guard let jsonData = jsonText.data(using: .utf8) else {
            throw AnalysisError.invalidResponse
        }

        let analysisResponse = try JSONDecoder().decode(ClaudeAnalysisResponse.self, from: jsonData)
        return analysisResponse.toAnalysisResult()
    }

    private func extractJSON(from text: String) -> String {
        // Strip ```json ... ``` if present
        if let start = text.range(of: "{"),
           let end = text.range(of: "}", options: .backwards) {
            return String(text[start.lowerBound...end.upperBound])
        }
        return text
    }
}

enum AnalysisError: LocalizedError {
    case imageEncodingFailed
    case networkError
    case apiError(statusCode: Int)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed: return "Could not process the image. Please try again."
        case .networkError:        return "Network error. Check your connection and try again."
        case .apiError(let code): return "API error (\(code)). Please try again later."
        case .invalidResponse:    return "Unexpected response. Please try again."
        }
    }
}

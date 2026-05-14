import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \AnalysisRecord.date, order: .reverse)
    private var records: [AnalysisRecord]

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    EmptyHistoryView()
                } else {
                    List {
                        ForEach(records) { record in
                            HistoryRow(record: record)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("History")
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(records[index])
        }
        try? modelContext.save()
    }
}

private struct HistoryRow: View {
    let record: AnalysisRecord

    var scoreColor: Color {
        switch record.overallScore {
        case 85...100: return .green
        case 65..<85:  return .yellow
        default:       return .orange
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            if let image = UIImage(data: record.imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(record.summary)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("\(record.overallScore)")
                    .font(.title2.bold())
                    .foregroundStyle(scoreColor)
                Text("score")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(.secondary)
            Text("No analyses yet")
                .font(.headline)
            Text("Scan your look from the Analyze tab\nto build your history.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

import SwiftUI
import SwiftData
import UIKit
import Charts

struct ExerciseDetailView: View {
    let exercise: ExerciseDefinition
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab = 0
    @State private var allSets: [ExerciseSet] = []
    @State private var exerciseImageURL: URL?
    @State private var isLoadingImage = false

    private let tabs = ["About", "History", "Charts", "Records"]

    /// Local pixel art asset name derived from exercise ID (e.g. "bench-press" → "exercise_bench_press")
    private var localExerciseImageName: String {
        "exercise_\(exercise.id.replacingOccurrences(of: "-", with: "_"))"
    }

    private var hasLocalExerciseImage: Bool {
        UIImage(named: localExerciseImageName) != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            Picker("Tab", selection: $selectedTab) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Text(tabs[index]).tag(index)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Theme.spacingLG)
            .padding(.vertical, Theme.spacingSM)

            // Tab content
            ScrollView {
                switch selectedTab {
                case 0: aboutTab
                case 1: historyTab
                case 2: chartsTab
                case 3: recordsTab
                default: EmptyView()
                }
            }
        }
        .screenBackground()
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
        }
        .onAppear { loadAllSets() }
        .task {
            isLoadingImage = true
            exerciseImageURL = await ExerciseAPIService.shared.fetchExerciseImageURL(for: exercise.name)
            isLoadingImage = false
        }
    }

    // MARK: - About Tab

    @ViewBuilder
    private var aboutTab: some View {
        VStack(alignment: .leading, spacing: Theme.spacingLG) {
            // Exercise demonstration image — prefer local pixel art, then API, then placeholder
            if hasLocalExerciseImage {
                Image(localExerciseImageName)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 250)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
            } else if isLoadingImage {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            } else if let exerciseImageURL {
                AsyncImage(url: exerciseImageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
                    case .failure:
                        exercisePlaceholder
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                exercisePlaceholder
            }

            HStack(spacing: Theme.spacingMD) {
                Label(exercise.muscleGroup, systemImage: "figure.strengthtraining.traditional")
                Label {
                    Text(exercise.equipment)
                } icon: {
                    Image("icon_dumbbell")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 20, height: 20)
                }
            }
            .font(.system(size: Theme.captionSize))
            .foregroundStyle(Color.appTextSecondary)

            VStack(alignment: .leading, spacing: Theme.spacingMD) {
                Text("Instructions")
                    .font(.system(size: Theme.headlineSize, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)

                let steps = exercise.instructions
                    .components(separatedBy: ". ")
                    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

                ForEach(steps.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: Theme.spacingSM) {
                        Text("\(index + 1).")
                            .font(.system(size: Theme.bodySize, weight: .semibold))
                            .foregroundStyle(Color.appTextPrimary)
                            .frame(width: 24, alignment: .leading)

                        let step = steps[index].trimmingCharacters(in: .whitespaces)
                        Text(step.hasSuffix(".") ? step : step + ".")
                            .font(.system(size: Theme.bodySize))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
        }
        .padding(Theme.spacingLG)
    }

    private var exercisePlaceholder: some View {
        VStack(spacing: Theme.spacingSM) {
            Image("icon_dumbbell")
                .resizable()
                .renderingMode(.original)
                .frame(width: 48, height: 48)
            Text("No image available")
                .font(.system(size: Theme.captionSize))
                .foregroundStyle(Color.appTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(Color.appCardSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMD))
    }

    // MARK: - History Tab

    @ViewBuilder
    private var historyTab: some View {
        let grouped = groupSetsByDate()

        if grouped.isEmpty {
            emptyState("No workout history for this exercise.")
        } else {
            VStack(alignment: .leading, spacing: Theme.spacingLG) {
                ForEach(grouped, id: \.month) { monthGroup in
                    Text(monthGroup.month)
                        .font(.system(size: Theme.captionSize, weight: .semibold))
                        .foregroundStyle(Color.appTextTertiary)
                        .textCase(.uppercase)
                        .padding(.horizontal, Theme.spacingLG)

                    ForEach(monthGroup.workouts, id: \.date) { workout in
                        VStack(alignment: .leading, spacing: Theme.spacingSM) {
                            Text(workout.date.formatted(.dateTime.hour().minute().weekday(.wide).month(.abbreviated).day().year()))
                                .font(.system(size: Theme.captionSize))
                                .foregroundStyle(Color.appTextSecondary)

                            // Column headers
                            HStack(spacing: 0) {
                                Text("").frame(width: 24)
                                Text("Sets Performed")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("1RM")
                                    .frame(width: 50, alignment: .trailing)
                            }
                            .font(.system(size: Theme.captionSize, weight: .bold))
                            .foregroundStyle(Color.appTextTertiary)

                            ForEach(workout.sets.indices, id: \.self) { i in
                                let set = workout.sets[i]
                                VStack(spacing: Theme.spacingXS) {
                                    HStack(spacing: 0) {
                                        Text("\(i + 1)")
                                            .frame(width: 24, alignment: .leading)
                                        Text("\(Int(set.weight)) lb × \(set.reps)")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(Int(set.estimated1RM))")
                                            .frame(width: 50, alignment: .trailing)
                                    }
                                    .font(.system(size: Theme.captionSize))
                                    .foregroundStyle(Color.appTextPrimary)

                                    if set.isPersonalRecord {
                                        HStack(spacing: Theme.spacingXS) {
                                            PRBadge(type: .oneRM)
                                            PRBadge(type: .volume)
                                            PRBadge(type: .weight)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                        .cardStyle()
                        .padding(.horizontal, Theme.spacingLG)
                    }
                }
            }
            .padding(.vertical, Theme.spacingLG)
        }
    }

    // MARK: - Charts Tab

    @ViewBuilder
    private var chartsTab: some View {
        let dailyBest = computeDailyBest()

        if dailyBest.isEmpty {
            emptyState("No chart data available yet.")
        } else {
            VStack(spacing: Theme.spacingLG) {
                chartCard(
                    subtitle: "Best Set (Est. 1RM)",
                    data: dailyBest.map { ($0.date, $0.e1rm) }
                )

                chartCard(
                    subtitle: "Best Set (Max Weight)",
                    data: dailyBest.map { ($0.date, $0.maxWeight) }
                )

                chartCard(
                    subtitle: "Total Volume",
                    data: dailyBest.map { ($0.date, $0.totalVolume) }
                )
            }
            .padding(Theme.spacingLG)
        }
    }

    private func chartCard(subtitle: String, data: [(date: Date, value: Double)]) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    Text(exercise.name)
                        .font(.system(size: Theme.bodySize, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(subtitle)
                        .font(.system(size: Theme.captionSize))
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
                if let latest = data.last {
                    Text("\(Int(latest.value)) lb")
                        .font(.system(size: Theme.captionSize, weight: .semibold))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Chart(data, id: \.date) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(Color.appAccent)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", item.date),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(Color.appAccent)
                .symbolSize(30)
            }
            .chartYAxis {
                AxisMarks(position: .trailing) { value in
                    AxisValueLabel {
                        if let v = value.as(Int.self) {
                            Text("\(v) lb")
                                .font(.system(size: Theme.miniSize))
                                .foregroundStyle(Color.appTextTertiary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date.formatted(.dateTime.month(.abbreviated)))
                                .font(.system(size: Theme.miniSize))
                                .foregroundStyle(Color.appTextTertiary)
                        }
                    }
                }
            }
            .frame(height: 180)
        }
        .cardStyle()
    }

    // MARK: - Records Tab

    @ViewBuilder
    private var recordsTab: some View {
        let records = computePersonalRecords()

        VStack(alignment: .leading, spacing: Theme.spacingLG) {
            // Personal Records
            VStack(alignment: .leading, spacing: Theme.spacingSM) {
                Text("PERSONAL RECORDS")
                    .font(.system(size: Theme.captionSize, weight: .semibold))
                    .foregroundStyle(Color.appTextTertiary)
                    .padding(.horizontal, Theme.spacingLG)

                VStack(spacing: 0) {
                    recordRow(label: "1RM", value: records.best1RM > 0 ? "\(Int(records.best1RM)) lb" : "—")
                    Divider().padding(.horizontal, Theme.spacingLG)
                    recordRow(label: "Weight", value: records.bestWeight > 0 ? "\(Int(records.bestWeight)) lb (×\(records.bestWeightReps))" : "—")
                    Divider().padding(.horizontal, Theme.spacingLG)
                    recordRow(label: "Max Volume", value: records.maxVolume > 0 ? "\(Int(records.maxVolume)) lb" : "—")
                }
                .cardStyle()
                .padding(.horizontal, Theme.spacingLG)
            }

            // Predicted 1RM table
            if !records.predictions.isEmpty {
                VStack(alignment: .leading, spacing: Theme.spacingMD) {
                    HStack(spacing: 0) {
                        Text("REPS")
                            .frame(width: 50, alignment: .leading)
                        Text("BEST PERFORMANCE")
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("PREDICTED")
                            .frame(width: 80, alignment: .trailing)
                    }
                    .font(.system(size: Theme.miniSize, weight: .bold))
                    .foregroundStyle(Color.appTextTertiary)
                    .padding(.horizontal, Theme.spacingLG)

                    ForEach(records.predictions, id: \.reps) { prediction in
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text("\(prediction.reps)")
                                    .font(.system(size: Theme.headlineSize, weight: .bold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .frame(width: 50, alignment: .leading)

                                VStack(spacing: 2) {
                                    Text("\(Int(prediction.bestWeight)) lb (×\(prediction.bestReps))")
                                        .font(.system(size: Theme.captionSize))
                                        .foregroundStyle(Color.appTextPrimary)
                                    if let date = prediction.date {
                                        Text(date.shortFormatted)
                                            .font(.system(size: Theme.miniSize))
                                            .foregroundStyle(Color.appTextTertiary)
                                    }
                                }
                                .frame(maxWidth: .infinity)

                                Text("\(Int(prediction.predicted1RM)) lb")
                                    .font(.system(size: Theme.captionSize, weight: .semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .frame(width: 80, alignment: .trailing)
                            }
                            .padding(.vertical, Theme.spacingSM)

                            Divider()
                        }
                    }
                    .padding(.horizontal, Theme.spacingLG)
                }
            }
        }
        .padding(.vertical, Theme.spacingLG)
    }

    // MARK: - Helpers

    private func recordRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: Theme.bodySize, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Text(value)
                .font(.system(size: Theme.bodySize))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.vertical, Theme.spacingXS)
    }

    private func emptyState(_ message: String) -> some View {
        Text(message)
            .font(.system(size: Theme.captionSize))
            .foregroundStyle(Color.appTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.top, Theme.spacingHuge)
    }

    // MARK: - Data

    private func loadAllSets() {
        let name = exercise.name
        let descriptor = FetchDescriptor<ExerciseSet>(
            predicate: #Predicate { $0.exerciseName == name && $0.isCompleted && !$0.isWarmup },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        allSets = (try? modelContext.fetch(descriptor)) ?? []
    }

    struct MonthGroup {
        let month: String
        let workouts: [WorkoutDay]
    }

    struct WorkoutDay {
        let date: Date
        let sets: [ExerciseSet]
    }

    private func groupSetsByDate() -> [MonthGroup] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: allSets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        let sortedDays = byDay.sorted { $0.key > $1.key }

        let byMonth = Dictionary(grouping: sortedDays) { entry in
            entry.key.formatted(.dateTime.month(.wide).year())
        }

        return byMonth
            .sorted { $0.value.first?.key ?? Date() > $1.value.first?.key ?? Date() }
            .map { month, days in
                MonthGroup(
                    month: month,
                    workouts: days.map {
                        WorkoutDay(date: $0.key, sets: $0.value.sorted { $0.setNumber < $1.setNumber })
                    }
                )
            }
    }

    struct DailyBest {
        let date: Date
        let e1rm: Double
        let maxWeight: Double
        let totalVolume: Double
    }

    private func computeDailyBest() -> [DailyBest] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: allSets) { set in
            calendar.startOfDay(for: set.timestamp)
        }

        return byDay.map { day, sets in
            DailyBest(
                date: day,
                e1rm: sets.map(\.estimated1RM).max() ?? 0,
                maxWeight: sets.map(\.weight).max() ?? 0,
                totalVolume: sets.reduce(0) { $0 + $1.volume }
            )
        }
        .sorted { $0.date < $1.date }
    }

    struct PersonalRecords {
        let best1RM: Double
        let bestWeight: Double
        let bestWeightReps: Int
        let maxVolume: Double
        let predictions: [RepPrediction]
    }

    struct RepPrediction {
        let reps: Int
        let bestWeight: Double
        let bestReps: Int
        let date: Date?
        let predicted1RM: Double
    }

    private func computePersonalRecords() -> PersonalRecords {
        guard !allSets.isEmpty else {
            return PersonalRecords(best1RM: 0, bestWeight: 0, bestWeightReps: 0, maxVolume: 0, predictions: [])
        }

        let best1RMSet = allSets.max(by: { $0.estimated1RM < $1.estimated1RM })
        let bestWeightSet = allSets.max(by: { $0.weight < $1.weight })

        let calendar = Calendar.current
        let dailyVolumes = Dictionary(grouping: allSets) { set in
            calendar.startOfDay(for: set.timestamp)
        }.mapValues { sets in sets.reduce(0.0) { $0 + $1.volume } }
        let maxVolume = dailyVolumes.values.max() ?? 0

        let byReps = Dictionary(grouping: allSets) { $0.reps }
        let predictions: [RepPrediction] = (1...10).compactMap { reps in
            guard let best = byReps[reps]?.max(by: { $0.weight < $1.weight }) else {
                return nil
            }
            return RepPrediction(
                reps: reps,
                bestWeight: best.weight,
                bestReps: best.reps,
                date: best.timestamp,
                predicted1RM: best.estimated1RM
            )
        }

        return PersonalRecords(
            best1RM: best1RMSet?.estimated1RM ?? 0,
            bestWeight: bestWeightSet?.weight ?? 0,
            bestWeightReps: bestWeightSet?.reps ?? 0,
            maxVolume: maxVolume,
            predictions: predictions
        )
    }
}
